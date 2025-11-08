#!/bin/bash
# Test and validate ASUS ScreenPad touch configuration

echo "=== ASUS ScreenPad Touch Configuration Test ==="
echo ""

# Check on-screen keyboard status
echo "1. ON-SCREEN KEYBOARD STATUS:"
if pgrep -f "onboard\|caribou" > /dev/null; then
    echo "❌ Virtual keyboard processes are running:"
    pgrep -f "onboard\|caribou" | xargs ps -p
else
    echo "✓ No virtual keyboard processes running"
fi

echo ""
echo "GNOME keyboard settings:"
echo "  - Screen keyboard enabled: $(gsettings get org.gnome.desktop.a11y.applications screen-keyboard-enabled)"
echo "  - A11y keyboard enabled: $(gsettings get org.gnome.desktop.a11y.keyboard enable)"

# Check touch device configuration
echo ""
echo "2. TOUCH DEVICE CONFIGURATION:"
TOUCH_DEVICE="ELAN9009:00 04F3:41D9"

if xinput list | grep -q "$TOUCH_DEVICE"; then
    echo "✓ Touch device detected: $TOUCH_DEVICE"
    
    echo ""
    echo "Touch device properties:"
    echo "  - Device enabled: $(xinput list-props "$TOUCH_DEVICE" | grep "Device Enabled" | cut -d: -f2 | tr -d ' \t')"
    
    # Check libinput properties
    if xinput list-props "$TOUCH_DEVICE" | grep -q "libinput"; then
        echo "✓ Using libinput driver"
        echo "  - Tapping: $(xinput list-props "$TOUCH_DEVICE" | grep "libinput Tapping Enabled" | cut -d: -f2 | tr -d ' \t' || echo 'N/A')"
        echo "  - Natural scrolling: $(xinput list-props "$TOUCH_DEVICE" | grep "libinput Natural Scrolling Enabled" | cut -d: -f2 | tr -d ' \t' || echo 'N/A')"
        echo "  - Scroll method: $(xinput list-props "$TOUCH_DEVICE" | grep "libinput Scroll Method Enabled" | cut -d: -f2 | tr -d ' \t' || echo 'N/A')"
    else
        echo "⚠ Not using libinput driver"
    fi
    
    # Check coordinate transformation
    echo ""
    echo "Coordinate transformation matrix:"
    xinput list-props "$TOUCH_DEVICE" | grep "Coordinate Transformation Matrix" | head -1
else
    echo "❌ Touch device not found"
fi

# Check display mapping
echo ""
echo "3. DISPLAY CONFIGURATION:"
echo "Active displays:"
xrandr --listmonitors

echo ""
echo "ScreenPad display:"
if xrandr | grep -q "DisplayPort-1-2 connected"; then
    echo "✓ ScreenPad display detected (DisplayPort-1-2)"
    xrandr | grep "DisplayPort-1-2"
else
    echo "❌ ScreenPad display not found"
fi

# Check udev rules
echo ""
echo "4. UDEV RULES:"
if [ -f "/etc/udev/rules.d/99-asus-screenpad-touch.rules" ]; then
    echo "✓ Custom udev rule exists"
    cat /etc/udev/rules.d/99-asus-screenpad-touch.rules
else
    echo "⚠ No custom udev rule found"
fi

echo ""
echo "=== TEST INSTRUCTIONS ==="
echo ""
echo "To test if the fixes work:"
echo "1. Open a browser and navigate to a long webpage"
echo "2. Try scrolling on the ScreenPad with your finger"
echo "   ✓ Should scroll up/down smoothly"
echo "   ❌ Should NOT select text"
echo ""
echo "3. Click on a text input field (terminal, search box)"
echo "   ✓ Should focus the field normally"
echo "   ❌ Should NOT show on-screen keyboard"
echo ""
echo "If tests fail, run: ./fix_touch.sh (and reboot if needed)"
