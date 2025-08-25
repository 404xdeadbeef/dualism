#!/bin/bash

set -euo pipefail

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: uninstallation must be run as root."
    echo "Use: sudo ./uninstall.sh"
    exit 1
fi

# System paths
TARGET_BIN="/usr/local/bin/dualism"
CONFIG_DIR="/etc/dualism"
LOG_DIR="/var/log/dualism"
STATE_FILE="/tmp/dualism_state"
HEARTBEAT_FILE="/tmp/dualism_heartbeat"
LOCK_FILE="/tmp/dualism-check.lock"

# Check if dualism is installed
if [ ! -f "$TARGET_BIN" ] && [ ! -d "$CONFIG_DIR" ]; then
    echo "dualism is not installed."
    exit 0
fi

echo "Uninstalling dualism v1.0..."
echo

# Remove from cron
echo "Removing cron job..."
crontab -l 2>/dev/null | grep -v "dualism" | crontab - 2>/dev/null || {
    echo "Warning: failed to update crontab."
}

# Remove binary
if [ -f "$TARGET_BIN" ]; then
    echo "Removing binary: $TARGET_BIN"
    rm -f "$TARGET_BIN"
fi

# Remove configuration
if [ -d "$CONFIG_DIR" ]; then
    echo "Removing configuration: $CONFIG_DIR"
    rm -rf "$CONFIG_DIR"
fi

# Remove logs
if [ -d "$LOG_DIR" ]; then
    echo "Removing logs: $LOG_DIR"
    rm -rf "$LOG_DIR"
fi

# Remove temporary state files
echo "Cleaning up temporary files..."
rm -f "$STATE_FILE"
rm -f "$HEARTBEAT_FILE"
rm -f "$LOCK_FILE"

# Final message
echo
echo "UNINSTALLATION COMPLETED."
echo "dualism and all related data have been removed."
echo
echo "To verify, check:"
echo "  - /usr/local/bin/dualism"
echo "  - /etc/dualism/"
echo "  - /var/log/dualism/"
echo "  - crontab (run: crontab -l)"
echo
echo "Goodbye! To reinstall later, visit: https://github.com/404xdeadbeef/dualism"