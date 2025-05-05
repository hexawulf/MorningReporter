#!/bin/bash
# AUTHOR: 0xWulf
# DATE: 2025-05-03
# DESCRIPTION: Sends a network traffic & local topology report to hex316aa@gmail.com

recipient="hex316aa@gmail.com"
from_address="root@sda4.org"
hostname=$(hostname)
timestamp=$(date '+%Y-%m-%d %H:%M:%S')
subject="🌐 $hostname Network Report - $timestamp"

# === Check for sudo ===
if [ "$EUID" -ne 0 ]; then
  echo "⚠️  This script must be run with sudo to capture all network info."
  exit 1
fi

# === Network Info ===
external_ip=$(curl -s https://ifconfig.me)

geo_info=$(curl -s https://ipinfo.io/$external_ip/json 2>/dev/null | grep -E 'ip|city|region|country|org')
if [[ -z "$geo_info" ]]; then
    geo_info="Geolocation lookup failed or no network connection."
fi

bandwidth=$(vnstat --oneline | awk -F';' '{print "Interface: " $1 "\nToday: " $11 "\nMonth: " $15}')
connections=$(ss -tuna)
listening=$(ss -tulnp)
top_ips=$(netstat -ntu | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -nr | head -n 10)

# === Docker networks (optional) ===
docker_networks=$(docker ps --format '{{.Names}}: {{.Ports}}' 2>/dev/null)

# === Local Topology ===
default_gateway=$(ip route | grep default)
route_table=$(ip route)
arp_table=$(arp -n || ip neigh)

# Optional live scan for devices on local subnet
local_subnet=$(ip route | awk '/src/ {print $1; exit}')
lan_scan=$(nmap -sn "$local_subnet" 2>/dev/null | grep "Nmap scan report" | awk '{print $5}')

# === MAC Vendor Lookup (requires macchanger) ===
mac_vendor_info=""
while IFS= read -r ip; do
    mac=$(arp -n "$ip" | awk '/ether/ {print $3}')
    if [[ -n "$mac" ]]; then
        vendor=$(macchanger -l | grep -i "${mac:0:8}" | cut -d' ' -f3-)
        mac_vendor_info+="IP: $ip | MAC: $mac | Vendor: ${vendor:-Unknown}\n"
    fi
done <<< "$lan_scan"

# === Compose the email body ===
email_body=$(cat <<EOF
🌐 Network Report for $hostname
🕒 Generated on: $timestamp

🌍 External IP:
$external_ip

📍 Geo Info:
$geo_info

📡 Bandwidth Usage (vnstat):
$bandwidth

🔌 Active Connections (ss -tuna):
$connections

🎧 Listening Ports (ss -tulnp):
$listening

🛑 Top Remote IPs (by connection count):
$top_ips

🐳 Docker Networks:
$docker_networks

============================
🏠 Local Network Topology
============================

🧭 Default Gateway:
$default_gateway

🛣️ Routing Table:
$route_table

📡 ARP Table (cached LAN hosts):
$arp_table

🔍 Detected LAN Devices (via nmap ping scan):
$lan_scan

🏷️ MAC Vendor Lookup:
$mac_vendor_info
EOF
)

# === Send the report ===
{
  echo "From: $from_address"
  echo "To: $recipient"
  echo "Subject: $subject"
  echo "Content-Type: text/plain; charset=UTF-8"
  echo ""
  echo -e "$email_body"
} | msmtp "$recipient"
