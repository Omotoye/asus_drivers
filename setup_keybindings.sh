#!/bin/bash
# ASUS Zephyrus Duo Keyboard Shortcuts Setup

# Check if we're in a desktop environment with keybinding support
if ! command -v gsettings &> /dev/null; then
    echo "This script requires GNOME/Ubuntu desktop environment"
    exit 1
fi

echo "Setting up ASUS Zephyrus Duo keyboard shortcuts..."

# Function to add custom keybinding
add_keybinding() {
    local name="$1"
    local command="$2"
    local binding="$3"
    local index="$4"
    
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom$index/ name "$name"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom$index/ command "$command"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom$index/ binding "$binding"
}

# Get existing custom keybindings
existing=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)
if [ "$existing" = "[]" ] || [ "$existing" = "@as []" ]; then
    new_list="['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/']"
else
    echo "Custom keybindings already exist. Please check your keyboard shortcuts settings."
    echo "You can manually add these shortcuts:"
    echo "Ctrl+Alt+R: Toggle rainbow keyboard effect"
    echo "Ctrl+Alt+B: ScreenPad brightness up"
    echo "Ctrl+Alt+Shift+B: ScreenPad brightness down"
    echo "Ctrl+Alt+S: Toggle ScreenPad display"
    echo "Ctrl+Alt+T: Reset touch input"
    exit 0
fi

# Set the list of custom keybindings
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$new_list"

# Add keybindings
add_keybinding "RGB Rainbow Mode" "/home/omotoye/asus_drivers/rgb_control.sh mode rainbow" "<Ctrl><Alt>r" 0
add_keybinding "ScreenPad Brightness Up" "/home/omotoye/asus_drivers/screenpad_control.sh brightness up" "<Ctrl><Alt>b" 1
add_keybinding "ScreenPad Brightness Down" "/home/omotoye/asus_drivers/screenpad_control.sh brightness down" "<Ctrl><Alt><Shift>b" 2
add_keybinding "Toggle ScreenPad" "/home/omotoye/asus_drivers/screenpad_control.sh display toggle" "<Ctrl><Alt>s" 3
add_keybinding "Reset Touch Input" "/home/omotoye/asus_drivers/screenpad_control.sh touch reset" "<Ctrl><Alt>t" 4

echo "Keyboard shortcuts have been set up successfully!"
echo ""
echo "Available shortcuts:"
echo "  Ctrl+Alt+R          Toggle rainbow keyboard effect"
echo "  Ctrl+Alt+B          Increase ScreenPad brightness"
echo "  Ctrl+Alt+Shift+B    Decrease ScreenPad brightness"
echo "  Ctrl+Alt+S          Toggle ScreenPad display on/off"
echo "  Ctrl+Alt+T          Reset touch input"
echo ""
echo "You can view/modify these in Settings > Keyboard > Keyboard Shortcuts > Custom Shortcuts"