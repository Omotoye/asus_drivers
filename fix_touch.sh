#!/bin/bash
# Fix ASUS Zephyrus Duo ScreenPad touch input issues

# Disable on-screen keyboard for touch events
echo "Configuring touch input to prevent on-screen keyboard popup..."

# Method 1: Disable automatic on-screen keyboard via gsettings
gsettings set org.gnome.desktop.a11y.applications screen-keyboard-enabled false
gsettings set org.gnome.shell.keyboard enabled false

# Method 2: Configure the touch device to not trigger virtual keyboard
xinput set-prop "ELAN9009:00 04F3:41D9" "Device Enabled" 0
sleep 1
xinput set-prop "ELAN9009:00 04F3:41D9" "Device Enabled" 1

# Method 3: Set the device as a touchscreen (not tablet) to prevent keyboard popup
if command -v xsetwacom &> /dev/null; then
    echo "Wacom tools detected, configuring tablet settings..."
    # This usually helps with stylus/tablet detection
    xsetwacom --set "ELAN9009:00 04F3:41D9 Stylus" TabletPCButton off 2>/dev/null || true
fi

# Method 4: Disable caribou (GNOME on-screen keyboard) from auto-starting
if pgrep -f caribou > /dev/null; then
    echo "Stopping caribou on-screen keyboard..."
    pkill -f caribou
fi

# Disable ibus virtual keyboard trigger
gsettings set org.freedesktop.ibus.panel show-icon-on-systray false 2>/dev/null || true
gsettings set org.freedesktop.ibus.panel use-system-keyboard-layout true 2>/dev/null || true

echo "Touch input configuration updated."
echo "Please test the ScreenPad touch - it should no longer trigger the on-screen keyboard."
echo ""
echo "If issues persist, you can:"
echo "1. Go to Settings > Accessibility > Screen Keyboard and ensure it's OFF"
echo "2. Go to Settings > Region & Language > Input Sources and check keyboard settings"
echo "3. Run this script again: ./fix_touch.sh"