#!/bin/bash
# ASUS Zephyrus Duo ScreenPad Control Script

SCREENPAD_BRIGHTNESS="/sys/class/backlight/asus_screenpad/brightness"
SCREENPAD_MAX_BRIGHTNESS="/sys/class/backlight/asus_screenpad/max_brightness"
SCREENPAD_DISPLAY="DisplayPort-1-2"

require_brightness_write() {
    if [ ! -w "$SCREENPAD_BRIGHTNESS" ] && [ "$EUID" -ne 0 ]; then
        echo "Error: Write access to $SCREENPAD_BRIGHTNESS required. Re-run with sudo or adjust permissions manually."
        return 1
    fi
    return 0
}

# Brightness Control Functions
get_brightness() {
    if [ -f "$SCREENPAD_BRIGHTNESS" ]; then
        cat "$SCREENPAD_BRIGHTNESS"
    else
        echo "Error: ScreenPad brightness control not found"
        exit 1
    fi
}

get_max_brightness() {
    if [ -f "$SCREENPAD_MAX_BRIGHTNESS" ]; then
        cat "$SCREENPAD_MAX_BRIGHTNESS"
    else
        echo "Error: ScreenPad max brightness not found"
        exit 1
    fi
}

set_brightness() {
    local brightness="$1"
    local max_brightness
    max_brightness=$(get_max_brightness)
    
    if [ "$brightness" -lt 0 ] || [ "$brightness" -gt "$max_brightness" ]; then
        echo "Error: Brightness must be between 0 and $max_brightness"
        exit 1
    fi

    if ! require_brightness_write; then
        exit 1
    fi
    
    if echo "$brightness" > "$SCREENPAD_BRIGHTNESS" 2>/dev/null; then
        echo "ScreenPad brightness set to: $brightness/$max_brightness"
    else
        echo "Error: Could not set brightness. Ensure you have permission to write to $SCREENPAD_BRIGHTNESS."
        exit 1
    fi
}

set_brightness_percent() {
    local percent="$1"
    local max_brightness=$(get_max_brightness)
    local brightness=$((max_brightness * percent / 100))
    
    set_brightness "$brightness"
}

# Display Control Functions
toggle_screenpad() {
    if xrandr | grep -q "$SCREENPAD_DISPLAY connected"; then
        if xrandr | grep -q "$SCREENPAD_DISPLAY connected.*[0-9]"; then
            xrandr --output "$SCREENPAD_DISPLAY" --off
            echo "ScreenPad turned off"
        else
            xrandr --output "$SCREENPAD_DISPLAY" --auto --below DP-2
            echo "ScreenPad turned on"
        fi
    else
        echo "Error: ScreenPad display not found"
        exit 1
    fi
}

# Touch Input Functions
reset_touch() {
    echo "Resetting touch input devices..."
    xinput disable "ELAN9009:00 04F3:41D9"
    sleep 1
    xinput enable "ELAN9009:00 04F3:41D9"
    echo "Touch input reset complete"
}

get_touch_info() {
    echo "Touch devices information:"
    xinput list | grep -i elan
    echo ""
    echo "Touch device properties:"
    xinput list-props "ELAN9009:00 04F3:41D9" | head -10
}

# Main script logic
case "$1" in
    "brightness")
        case "$2" in
            "get")
                current=$(get_brightness)
                max=$(get_max_brightness)
                percent=$((current * 100 / max))
                echo "Current brightness: $current/$max ($percent%)"
                ;;
            "set")
                if [ -z "$3" ]; then
                    echo "Usage: $0 brightness set <value>"
                    echo "Value can be 0-$(get_max_brightness) or percentage with % suffix"
                    exit 1
                fi
                if [[ "$3" == *% ]]; then
                    percent="${3%?}"
                    set_brightness_percent "$percent"
                else
                    set_brightness "$3"
                fi
                ;;
            "up")
                current=$(get_brightness)
                max=$(get_max_brightness)
                new=$((current + max / 10))
                if [ "$new" -gt "$max" ]; then
                    new="$max"
                fi
                set_brightness "$new"
                ;;
            "down")
                current=$(get_brightness)
                max=$(get_max_brightness)
                new=$((current - max / 10))
                if [ "$new" -lt 0 ]; then
                    new=0
                fi
                set_brightness "$new"
                ;;
            *)
                echo "Usage: $0 brightness {get|set|up|down} [value]"
                exit 1
                ;;
        esac
        ;;
    "display")
        case "$2" in
            "toggle")
                toggle_screenpad
                ;;
            "status")
                echo "Display information:"
                xrandr --listmonitors
                ;;
            *)
                echo "Usage: $0 display {toggle|status}"
                exit 1
                ;;
        esac
        ;;
    "touch")
        case "$2" in
            "reset")
                reset_touch
                ;;
            "info")
                get_touch_info
                ;;
            *)
                echo "Usage: $0 touch {reset|info}"
                exit 1
                ;;
        esac
        ;;
    *)
        echo "ASUS Zephyrus Duo ScreenPad Control"
        echo "Usage: $0 {brightness|display|touch} [options]"
        echo ""
        echo "Brightness commands:"
        echo "  brightness get           Get current brightness"
        echo "  brightness set <value>   Set brightness (0-235 or percentage with %)"
        echo "  brightness up            Increase brightness by 10%"
        echo "  brightness down          Decrease brightness by 10%"
        echo ""
        echo "Display commands:"
        echo "  display toggle           Turn ScreenPad on/off"
        echo "  display status           Show display information"
        echo ""
        echo "Touch commands:"
        echo "  touch reset              Reset touch input"
        echo "  touch info               Show touch device information"
        echo ""
        echo "Examples:"
        echo "  $0 brightness set 50%    # Set brightness to 50%"
        echo "  $0 brightness up         # Increase brightness"
        echo "  $0 display toggle        # Toggle ScreenPad on/off"
        echo "  $0 touch reset           # Reset touch input"
        ;;
esac
