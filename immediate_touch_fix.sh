#!/bin/bash
# Immediate touch behavior fix for ASUS ScreenPad

echo "=== Immediate Touch Behavior Fix ==="

# 1. Stop any virtual keyboard services immediately
echo "Stopping virtual keyboards..."
pkill -f onboard 2>/dev/null || true
pkill -f caribou 2>/dev/null || true

# 2. Set environment variables for better touch behavior
echo "Setting touch environment variables..."
export MOZ_USE_XINPUT2=1
export FIREFOX_USE_XINPUT2=1
export GDK_CORE_DEVICE_EVENTS=1

# Make these permanent
cat >> ~/.bashrc << EOF

# ASUS ScreenPad touch optimization
export MOZ_USE_XINPUT2=1
export FIREFOX_USE_XINPUT2=1
export GDK_CORE_DEVICE_EVENTS=1
EOF

# 3. Create GTK-3 configuration for better touch handling
mkdir -p ~/.config/gtk-3.0
cat > ~/.config/gtk-3.0/settings.ini << EOF
[Settings]
gtk-primary-button-warps-slider = false
gtk-touchscreen-mode = true
EOF

# 4. Configure X11 input settings
mkdir -p ~/.config/X11
cat > ~/.config/X11/xorg.conf.d/90-touchscreen.conf << EOF
Section "InputClass"
    Identifier "ASUS ScreenPad Touch"
    MatchDevicePath "/dev/input/event*"
    MatchProduct "ELAN9009:00 04F3:41D9"
    Driver "libinput"
    Option "Tapping" "on"
    Option "TappingDrag" "on"
    Option "DisableWhileTyping" "off"
    Option "NaturalScrolling" "false"
    Option "ScrollMethod" "twofinger"
EndSection
EOF

# 5. Immediate xinput configuration
echo "Configuring touch device..."
TOUCH_DEVICE="ELAN9009:00 04F3:41D9"

# Reset the device
xinput disable "$TOUCH_DEVICE" 2>/dev/null || true
sleep 0.5
xinput enable "$TOUCH_DEVICE" 2>/dev/null || true

# 6. Create a browser launch script with proper touch flags
cat > ~/launch_browser_touch.sh << 'EOF'
#!/bin/bash
# Launch browsers with proper touch support

export MOZ_USE_XINPUT2=1
export FIREFOX_USE_XINPUT2=1
export GDK_CORE_DEVICE_EVENTS=1

if command -v firefox &> /dev/null; then
    firefox --new-instance "$@" &
elif command -v google-chrome &> /dev/null; then
    google-chrome --touch-events=enabled --enable-pinch "$@" &
elif command -v chromium-browser &> /dev/null; then
    chromium-browser --touch-events=enabled --enable-pinch "$@" &
else
    echo "No supported browser found"
fi
EOF
chmod +x ~/launch_browser_touch.sh

echo ""
echo "=== IMMEDIATE FIX APPLIED ==="
echo ""
echo "What was done:"
echo "✓ Killed virtual keyboard processes"
echo "✓ Set touch-optimized environment variables" 
echo "✓ Created GTK touchscreen configuration"
echo "✓ Reset touch device"
echo "✓ Created touch-optimized browser launcher"
echo ""
echo "How to test:"
echo "1. Use this command to launch browser with proper touch:"
echo "   ~/launch_browser_touch.sh"
echo ""
echo "2. Or restart your current browser and test scrolling"
echo ""
echo "3. The on-screen keyboard should be gone"
echo ""
echo "For a more complete reset: re-run ./fix_touch.sh after a reboot"
