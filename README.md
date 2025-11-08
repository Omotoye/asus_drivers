# ASUS Zephyrus Duo Helper Scripts

Shell tools and an optional Electron UI for managing RGB lighting, ScreenPad Plus brightness, and touch behavior on ASUS Zephyrus Duo laptops. Tested on Ubuntu 22.04 LTS and Ubuntu 24.04 LTS.

> [!WARNING]
> These scripts interact directly with hardware control interfaces. Review each file before running it and proceed entirely at your own risk.

## Supported Environment
- **Hardware**: ASUS Zephyrus Duo models with the ScreenPad Plus (ELAN9009:00 touch) and ASUS RGB keyboard.
- **OS**: Ubuntu 22.04 / 24.04 (GNOME session). Other distros may work but are not covered.
- **Runtime dependencies**: `sudo`, `xrandr`, `xinput`, `bash`, optional `openrgb` for advanced lighting.

## Key Scripts

| Script | Purpose | Elevation |
| --- | --- | --- |
| `rgb_control.sh` | Firmware backlight levels (0-3) with OpenRGB fallbacks for effects | Required only when writing `/sys/class/leds/...` |
| `screenpad_control.sh` | Get/Set ScreenPad brightness, toggle the panel, inspect/reset touch | Required for brightness writes; other subcommands run unprivileged |
| `fix_touch.sh` | Disables GNOME on-screen keyboard triggers and refreshes the ELAN device | Not required |
| `immediate_touch_fix.sh` | One-shot touch tuning plus optional launcher creation | Not required (writes to your dotfiles) |
| `test_touch.sh` | Reports ScreenPad / touch diagnostics | Not required |
| `setup_keybindings.sh` | Adds GNOME keyboard shortcuts for the helper scripts | Not required |
| `main.js` + `renderer.js` + `preload.js` + `asus_control_center.html` | Electron UI wrapper | Not required (uses the same shell scripts underneath) |

## Quick Usage

```bash
# RGB firmware levels (sudo needed for /sys writes)
sudo ./rgb_control.sh basic 2

# ScreenPad brightness
./screenpad_control.sh brightness get
sudo ./screenpad_control.sh brightness set 120

# Touch checks
./screenpad_control.sh touch info
./test_touch.sh
```

## Safety Model
> [!IMPORTANT]
> - No script alters GRUB, initramfs, kernel parameters, or sudoers rules.  
> - Writes to `/sys/class/*` happen only when you explicitly run the relevant command with `sudo`.  
> - Touch fixes operate within your home directory (`~/.bashrc`, `~/.config/gtk-3.0`, etc.); back up those files first if you keep custom tweaks.  
> - Everything else is read-only or GNOME `gsettings` updates that can be reverted via the Settings UI.

## Troubleshooting

**Keyboard lighting**
- `./rgb_control.sh list` shows OpenRGB-detected devices.
- If OpenRGB fails, the script automatically reverts to firmware level control.

**ScreenPad brightness / display**
- `./screenpad_control.sh brightness get` works without sudo; `set`, `up`, `down` require sudo.
- `./screenpad_control.sh display status` surfaces the current xrandr layout; `display toggle` can turn the ScreenPad on/off.

**Touch behavior**
- `./screenpad_control.sh touch reset` reinitializes the ELAN device.
- `./fix_touch.sh` prevents the GNOME on-screen keyboard from auto-launching when you tap the ScreenPad.
- `./immediate_touch_fix.sh` can regenerate the optional `~/launch_browser_touch.sh` for touch-aware browser launches.

## Electron Control Center

```bash
npm install
npm start
```

The Electron UI runs the same scripts through IPC; no additional privileges are required beyond whatever the script itself needs.

---

Everything in this repository stays confined to your home directory unless you explicitly run a command with `sudo`. Audit, adapt, or extend as needed for your ASUS Zephyrus Duo workflow.
