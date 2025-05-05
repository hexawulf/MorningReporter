#!/bin/bash
# AUTHOR: 0xWulf
# DATE: 2025-05-03
# DESCRIPTION: Sends a full system + hardware report to hex316aa@gmail.com

# === Config ===
recipient="hex316aa@gmail.com"
from_address="root@sda4.org"
msmtp_config="/home/zk/.msmtprc"
hostname=$(hostname)
timestamp=$(date '+%Y-%m-%d %H:%M:%S')
subject="🔒 $hostname System & Hardware Report - $timestamp"

# === Check for sudo ===
if [ "$EUID" -ne 0 ]; then
  echo "⚠️  This script must be run with sudo to access protected logs and hardware info."
  exit 1
fi

# === System Info ===
uptime_info=$(uptime -p)
disk_info=$(df -h /)
mem_info=$(free -h)
who_info=$(who)
top_processes=$(ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 10)

# === Logs ===
auth_logs=$(grep -E 'sshd.*(Accepted|Failed)|sudo' /var/log/auth.log | tail -n 20)
syslog_snippet=$(tail -n 20 /var/log/syslog)
dmesg_snippet=$(dmesg | tail -n 20)

# === Hardware Info ===
cpu_info=$(lscpu | grep -E 'Model name|Socket|Thread|Core')
gpu_info=$(lspci | grep -i 'vga\|3d\|display')
memory_modules=$(lshw -C memory | grep -A5 'bank')
motherboard_info=$(dmidecode -t baseboard | grep -E 'Manufacturer|Product Name|Version')
bios_info=$(dmidecode -t bios | grep -E 'Vendor|Version|Release Date')
disks=$(lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | grep disk)

# === Email Body ===
email_body=$(cat <<EOF
📊 System & Hardware Report for $hostname
🕒 Generated on: $timestamp

🖥️ Uptime:
$uptime_info

💾 Disk Usage (/):
$disk_info

🧠 Memory Usage:
$mem_info

👤 Logged-in Users:
$who_info

🔥 Top Processes (by memory):
$top_processes

============================
🧩 Hardware Information
============================

🧠 CPU Info:
$cpu_info

🎮 GPU Info:
$gpu_info

🔋 RAM Modules:
$memory_modules

🖥️ Motherboard Info:
$motherboard_info

🧬 BIOS Info:
$bios_info

💽 Storage Devices:
$disks

============================
🛡️ Log Summaries
============================

🔐 /var/log/auth.log (last 20 entries):
$auth_logs

📄 /var/log/syslog (last 20 entries):
$syslog_snippet

🧠 Kernel dmesg (last 20 lines):
$dmesg_snippet

EOF
)

# === Send via msmtp (uses /root/.msmtprc when run with sudo) ===
{
  echo "From: $from_address"
  echo "To: $recipient"
  echo "Subject: $subject"
  echo "Content-Type: text/plain; charset=UTF-8"
  echo ""
  echo "$email_body"
} | msmtp "$recipient"
