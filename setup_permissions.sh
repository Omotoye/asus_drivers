#!/bin/bash
# ASUS Zephyrus Duo - Permissions Setup Script
# This script installs udev rules to allow non-root access to hardware controls

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UDEV_RULES_FILE="99-asus-controls.rules"
UDEV_RULES_PATH="/etc/udev/rules.d/${UDEV_RULES_FILE}"

echo "ASUS Zephyrus Duo - Permissions Setup"
echo "======================================"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "Error: Do not run this script as root or with sudo."
    echo "The script will request sudo access when needed."
    exit 1
fi

# Create udev rules file if it doesn't exist
if [ ! -f "${SCRIPT_DIR}/${UDEV_RULES_FILE}" ]; then
    echo "Creating udev rules file..."
    cat > "${SCRIPT_DIR}/${UDEV_RULES_FILE}" << 'EOF'
# ASUS keyboard backlight control
SUBSYSTEM=="leds", KERNEL=="asus::kbd_backlight", ACTION=="add", RUN+="/bin/chmod 666 /sys/class/leds/asus::kbd_backlight/brightness"

# ASUS ScreenPad backlight control
SUBSYSTEM=="backlight", KERNEL=="asus_screenpad", ACTION=="add", RUN+="/bin/chmod 666 /sys/class/backlight/asus_screenpad/brightness"
EOF
fi

# Install udev rules
echo "Installing udev rules to ${UDEV_RULES_PATH}..."
sudo cp "${SCRIPT_DIR}/${UDEV_RULES_FILE}" "${UDEV_RULES_PATH}"

# Reload udev rules
echo "Reloading udev rules..."
sudo udevadm control --reload-rules
sudo udevadm trigger

# Apply permissions immediately for current session
echo "Applying permissions for current session..."
if [ -f "/sys/class/leds/asus::kbd_backlight/brightness" ]; then
    sudo chmod 666 /sys/class/leds/asus::kbd_backlight/brightness
    echo "✓ Keyboard backlight permissions set"
else
    echo "⚠ Keyboard backlight control not found (may not be available on this system)"
fi

if [ -f "/sys/class/backlight/asus_screenpad/brightness" ]; then
    sudo chmod 666 /sys/class/backlight/asus_screenpad/brightness
    echo "✓ ScreenPad brightness permissions set"
else
    echo "⚠ ScreenPad brightness control not found (may not be available on this system)"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "You can now run the control scripts and Electron app without sudo."
echo "These permissions will persist after reboot."
