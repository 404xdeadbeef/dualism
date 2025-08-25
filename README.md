# dualism — Network Isolation Monitor

### Purpose  
`dualism` detects **accidental bridging between isolated networks**, such as:  
- **Network A** (e.g. 192.168.0.0/24 — servers)  
- **Network B** (e.g. 10.0.0.0/24 — users)  

Such connections may cause:  
- Virus spreading  
- Broadcast storms  
- Data leaks  
- Security violations  

---

### Detection Methods  

#### 1. PING Test  
- Checks reachability between networks using temporary IPs.  

#### 2. ARP Scan  
- Detects foreign MAC addresses in ARP tables.  

#### 3. Dual-Host Detection  
- Finds the same MAC address present in both networks.  

---

### Notifications  
- Sent via `swaks` directly to **SMTP server** (no authentication required)  
- Plain text emails only  
- No support for Gmail, Outlook, etc. without open relay  

> **Supports English and Russian localizations**  
> **Only for Debian/Ubuntu-based systems**

---

### Installation  
```bash
git clone https://github.com/404xdeadbeef/dualism  
cd dualism
sudo ./install.sh
```

### Configuration  
Edit: `/etc/dualism/config`

### Usage  
```bash
sudo dualism -s        # Start check
sudo dualism -n        # Dry run
dualism --help         # Help
dualism --uninstall    # Remove
```

### Uninstall  
```bash
sudo ./uninstall.sh
```

---

### Optional: Telegram Notifications  

To enable Telegram alerts:  

1. Uncomment and configure in `/etc/dualism/config`:  
   ```bash
   # TELEGRAM_BOT_TOKEN="your_bot_token"
   # TELEGRAM_CHAT_ID="your_chat_id"
   ```  

2. Add this function to `/usr/local/bin/dualism`:  
   ```bash
   # send_telegram_alert() {
   #     local message="$1"
   #     local url="https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage"
   #     curl -s -X POST "$url" \
   #         -d chat_id="$TELEGRAM_CHAT_ID" \
   #         -d text="$message" \
   #         -d parse_mode="markdown" > /dev/null
   # }
   ```  

3. Call it in `send_notification()`:  
   ```bash
   # if [ -n "$TELEGRAM_BOT_TOKEN" ]; then
   #     send_telegram_alert "$subject: $details"
   # fi
   ```  

> **Note**: Access to `api.telegram.org` may be restricted in certain regions (e.g. Nepal) due to government regulations. Ensure connectivity before enabling Telegram alerts.

---

## License  
[MIT](LICENSE) © 2025 404xdeadbeef