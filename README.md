# ☀️ MorningReporter

**Java-powered tool for sending daily Linux system and network diagnostics via email.**  
It wraps two shell scripts for gathering hardware and network info, then emails the combined report using SMTP (SMTP2Go compatible).

---

## 📦 Features

- 🖥️ Collects CPU, memory, disk, BIOS, and hardware info
- 🌐 Scans network topology, external IP, ports, and connections
- 🧠 Uses Bash scripts for real data, wrapped in Java
- 📧 Sends emails via any SMTP provider (tested with SMTP2Go)
- 🔐 Reads secrets from a `.env` file (never committed)

---

## 🛠 Project Structure

MorningReporter/
├── src/ # Java source files
│ └── dev/hexawulf/morningreporter/
│ ├── MorningReporter.java
│ └── EnvLoader.java
├── scripts/ # Bash scripts
│ ├── linuxws2_report.sh
│ └── linuxws2_netreport.sh
├── lib/ # Dependencies (jakarta.mail, activation)
├── .env # SMTP credentials (ignored via .gitignore)
├── .gitignore
├── manifest.txt # JAR manifest
└── README.md

yaml
Copy
Edit

---

## 🚀 Usage

### 1. Set Up `.env` in Project Root:

```env
SMTP_USERNAME=your-smtp2go-username
SMTP_PASSWORD=your-smtp2go-password
SMTP_FROM=
SMTP_TO=
SMTP_HOST=mail.smtp2go.com
SMTP_PORT=587
🔒 This file is ignored via .gitignore.

2. Run via Java
bash
Copy
Edit
java -cp "lib/*:src" dev.hexawulf.morningreporter.MorningReporter
Or if you've built the .jar:

bash
Copy
Edit
java -jar ~/bin/morningreporter.jar
3. Bash Scripts
Ensure your scripts are executable:

bash
Copy
Edit
chmod +x scripts/linuxws2_*.sh
Run manually if needed:

bash
Copy
Edit
sudo ./scripts/linuxws2_report.sh
sudo ./scripts/linuxws2_netreport.sh
⏰ Automation (Optional)
To run every morning at 8:00 AM:

bash
Copy
Edit
crontab -e
Add:

swift
Copy
Edit
0 8 * * * /usr/bin/java -jar /home/zk/bin/morningreporter.jar
✅ Dependencies
Java 21+

Jakarta Mail jakarta.mail-2.0.1.jar

Jakarta Activation:

jakarta.activation-api-2.1.1.jar

jakarta.activation-2.0.1.jar

msmtp (if using .sh scripts directly)

Tools used in scripts: curl, ip, ss, nmap, macchanger, etc.

🛡️ Security
No secrets in code — .env stores all sensitive data.

Scripts are safe for sharing — no hardcoded credentials or tokens.

✍️ Author
0xWulf
github.com/hexawulf

📄 License
MIT (or your choice — recommend adding one).

yaml
Copy
Edit
