#!/bin/bash
set -euo pipefail

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: installation must be run as root."
    echo "Use: sudo ./install.sh"
    exit 1
fi

# Check for Debian/Ubuntu (presence of 'apt')
if ! command -v apt &> /dev/null; then
    echo "Error: package manager 'apt' not found."
    echo "This installer supports Debian/Ubuntu-based systems only."
    exit 1
fi

echo "Installing dualism v1.0..."
echo

# System paths
CONFIG_DIR="/etc/dualism"
LOG_DIR="/var/log/dualism"
TARGET_BIN="/usr/local/bin/dualism"

# Create directories
echo "Creating system directories..."
mkdir -p "$CONFIG_DIR"
mkdir -p "$LOG_DIR"

# Copy main binary
echo "Copying main script..."
if [ -f "dualism" ]; then
    cp "dualism" "$TARGET_BIN"
    chmod +x "$TARGET_BIN"
else
    echo "Error: 'dualism' script not found in current directory."
    echo "Please run this installer from the project root."
    exit 1
fi

# Copy configuration
echo "Copying configuration file..."
if [ -f "config/config.example" ]; then
    cp "config/config.example" "$CONFIG_DIR/config"
    chmod 644 "$CONFIG_DIR/config"
else
    echo "Error: 'config/config.example' not found."
    exit 1
fi

# Copy localization files
echo "Searching for localization files..."
local_count=0
for msg_file in config/messages-*.conf; do
    if [ -f "$msg_file" ]; then
        cp "$msg_file" "$CONFIG_DIR/"
        chmod 644 "$CONFIG_DIR/$(basename "$msg_file")"
        lang_code=$(basename "$msg_file" | sed 's/messages-\(.*\)\.conf/\1/')
        echo "  • Language '$lang_code' installed"
        local_count=$((local_count + 1))
    fi
done

if [ $local_count -eq 0 ]; then
    echo "  • No language files found."
else
    echo "  Localizations installed: $local_count"
fi

# Check or install dependencies
echo
echo "Checking for required packages: swaks, arping..."

if command -v swaks &> /dev/null && command -v arping &> /dev/null; then
    echo "Dependencies are already installed. Skipping package installation."
else
    echo "Dependencies not fully installed. Attempting to install via apt..."
    
    if timeout 30 apt-get update -y > /dev/null 2>&1; then
        echo "Package list updated successfully."
    else
        echo "Warning: failed to update package list (timeout or no internet)."
        echo "Ensure 'swaks' and 'arping' are installed manually."
        echo "Error: required packages 'swaks' or 'arping' are not installed and cannot be installed without internet."
        exit 1
    fi

    if apt-get install -y swaks arping > /dev/null 2>&1; then
        echo "Dependencies installed successfully."
    else
        echo "Error: failed to install 'swaks' and 'arping'."
        echo "Check your internet connection or install them manually:"
        echo "  sudo apt install swaks arping"
        exit 1
    fi
fi

# Set permissions
echo
echo "Setting permissions on log directory..."
chown -R root:root "$LOG_DIR"
chmod -R 755 "$LOG_DIR"

# Final message
echo
echo "INSTALLATION COMPLETED!"
echo
echo "Next steps:"
echo
echo "1. Edit the configuration:"
echo
echo "   sudo nano /etc/dualism/config"
echo
echo "2. Run dualism manually for the first time:"
echo
echo "   sudo dualism -s"
echo
echo "   On first successful run, dualism will:"
echo
echo "   - Create logs in /var/log/dualism/"
echo "   - Add itself to cron (*/5 * * * * dualism -s)"
echo "   - Send a manual check report"
echo
echo "Tool: dualism"
echo
echo "Binary: $TARGET_BIN"
echo "Config: $CONFIG_DIR/config"
echo "Logs: $LOG_DIR/current.log"
echo
echo "Repository: https://github.com/404xdeadbeef/dualism"
echo
echo
echo "Run 'dualism --help' for help."