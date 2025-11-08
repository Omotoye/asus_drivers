#!/bin/bash
# ASUS Zephyrus Duo RGB Control Script

BACKLIGHT_PATH="/sys/class/leds/asus::kbd_backlight/brightness"
MAX_BRIGHTNESS="3"

require_backlight_write() {
    if [ ! -w "$BACKLIGHT_PATH" ] && [ "$EUID" -ne 0 ]; then
        echo "Error: Write access to $BACKLIGHT_PATH required. Re-run this command with sudo."
        exit 1
    fi
}

# Basic backlight control (fallback)
set_basic_backlight() {
    local level="$1"
    if [ "$level" -ge 0 ] && [ "$level" -le "$MAX_BRIGHTNESS" ]; then
        require_backlight_write
        echo "$level" > "$BACKLIGHT_PATH"
        echo "Basic keyboard backlight set to level: $level/$MAX_BRIGHTNESS"
    else
        echo "Error: Brightness level must be 0-$MAX_BRIGHTNESS"
    fi
}

# RGB Control Functions (with fallback to basic backlight)
set_keyboard_color() {
    local color="$1"
    # Try OpenRGB first
    if openrgb --device 0 --mode direct --color "$color" 2>/dev/null; then
        echo "RGB color set via OpenRGB"
    else
        echo "OpenRGB failed, enabling basic backlight instead"
        set_basic_backlight 3
    fi
}

set_keyboard_mode() {
    local mode="$1"
    case $mode in
        "static")
            if ! openrgb --device 0 --mode static 2>/dev/null; then
                echo "OpenRGB static mode failed, using basic backlight"
                set_basic_backlight 3
            fi
            ;;
        "rainbow")
            if ! openrgb --device 0 --mode "Rainbow Wave" 2>/dev/null; then
                echo "OpenRGB rainbow mode failed, using basic backlight"
                set_basic_backlight 3
            fi
            ;;
        "breathing")
            if ! openrgb --device 0 --mode "Breathing" 2>/dev/null; then
                echo "OpenRGB breathing mode failed, using basic backlight pulse"
                # Create breathing effect with basic backlight
                for i in {1..3}; do
                    set_basic_backlight 1
                    sleep 0.5
                    set_basic_backlight 3
                    sleep 0.5
                done
                set_basic_backlight 2
            fi
            ;;
        "reactive")
            if ! openrgb --device 0 --mode "Reactive - Fade" 2>/dev/null; then
                echo "OpenRGB reactive mode failed, using basic backlight"
                set_basic_backlight 3
            fi
            ;;
        "spectrum")
            if ! openrgb --device 0 --mode "Spectrum Cycle" 2>/dev/null; then
                echo "OpenRGB spectrum mode failed, using basic backlight"
                set_basic_backlight 3
            fi
            ;;
        "starry")
            if ! openrgb --device 0 --mode "Starry Night" 2>/dev/null; then
                echo "OpenRGB starry night mode failed, using basic backlight"
                set_basic_backlight 2
            fi
            ;;
        "rain")
            if ! openrgb --device 0 --mode "Rain" 2>/dev/null; then
                echo "OpenRGB rain mode failed, using basic backlight"
                set_basic_backlight 2
            fi
            ;;
        "comet")
            if ! openrgb --device 0 --mode "Comet" 2>/dev/null; then
                echo "OpenRGB comet mode failed, using basic backlight"
                set_basic_backlight 3
            fi
            ;;
        "flash")
            if ! openrgb --device 0 --mode "Flash N Dash" 2>/dev/null; then
                echo "OpenRGB flash mode failed, using basic backlight flash"
                # Create flash effect
                for i in {1..5}; do
                    set_basic_backlight 0
                    sleep 0.1
                    set_basic_backlight 3
                    sleep 0.1
                done
            fi
            ;;
        "ripple")
            if ! openrgb --device 0 --mode "Reactive - Ripple" 2>/dev/null; then
                echo "OpenRGB ripple mode failed, using basic backlight"
                set_basic_backlight 3
            fi
            ;;
        "laser")
            if ! openrgb --device 0 --mode "Reactive - Laser" 2>/dev/null; then
                echo "OpenRGB laser mode failed, using basic backlight"
                set_basic_backlight 3
            fi
            ;;
        "off")
            if ! openrgb --device 0 --mode off 2>/dev/null; then
                set_basic_backlight 0
            fi
            ;;
        "basic")
            echo "Available basic levels: 0 (off), 1 (dim), 2 (medium), 3 (bright)"
            echo "Usage: $0 basic <0-3>"
            exit 1
            ;;
        *)
            echo "Available modes: static, rainbow, breathing, reactive, spectrum, starry, rain, comet, flash, ripple, laser, off, basic"
            echo "Usage: $0 mode <mode_name>"
            echo "       $0 color <hex_color>"
            echo "       $0 basic <0-3>    # Basic backlight levels"
            exit 1
            ;;
    esac
}

# Main script logic
case "$1" in
    "color")
        if [ -z "$2" ]; then
            echo "Usage: $0 color <hex_color>"
            echo "Example: $0 color ff0000"
            exit 1
        fi
        set_keyboard_color "$2"
        echo "Keyboard color set to: $2"
        ;;
    "mode")
        if [ -z "$2" ]; then
            echo "Usage: $0 mode <mode_name>"
            echo "Available modes: static, rainbow, breathing, reactive, spectrum, off, basic"
            exit 1
        fi
        set_keyboard_mode "$2"
        echo "Keyboard mode set to: $2"
        ;;
    "basic")
        if [ -z "$2" ]; then
            echo "Usage: $0 basic <0-3>"
            echo "Levels: 0=off, 1=dim, 2=medium, 3=bright"
            exit 1
        fi
        set_basic_backlight "$2"
        ;;
    "list")
        echo "Available RGB devices:"
        openrgb --list-devices 2>/dev/null || echo "OpenRGB not working, using basic backlight only"
        echo ""
        echo "Basic backlight: $BACKLIGHT_PATH (levels 0-$MAX_BRIGHTNESS)"
        ;;
    *)
        echo "ASUS Zephyrus Duo RGB Control"
        echo "Usage: $0 {color|mode|basic|list} [options]"
        echo ""
        echo "Commands:"
        echo "  color <hex>     Set keyboard to specific color (e.g., ff0000 for red)"
        echo "  mode <name>     Set keyboard lighting mode"
        echo "  basic <0-3>     Set basic backlight level (0=off, 1=dim, 2=med, 3=bright)"
        echo "  list           List all RGB devices"
        echo ""
        echo "Available modes: static, rainbow, breathing, reactive, spectrum, off"
        echo ""
        echo "Examples:"
        echo "  $0 basic 3            # Turn on bright backlight"
        echo "  $0 basic 0            # Turn off backlight"
        echo "  $0 mode rainbow       # Try rainbow mode (fallback to backlight)"
        echo "  $0 color ff0000       # Try red color (fallback to backlight)"
        ;;
esac
