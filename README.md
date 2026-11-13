# Glyph Plasma

A Nothing OS–inspired desktop for CachyOS and KDE Plasma 6, based on the visual design of [Nebelung-cloud/glyph-rice](https://github.com/Nebelung-cloud/glyph-rice).

- A large dot-matrix clock, greeting, calendar, and animated seconds ring.
- A left rail with KDE's application launcher, virtual desktop pager, task manager, system tray, and clock. The tray provides your installed KDE network, audio, power, and notification controls.
- A charcoal and red KDE color scheme and a dotted wallpaper.
- Matching Breeze application controls, window decorations, icons and cursor, with a Glyph color scheme for Konsole.
- The original Glyph login screen as an optional Qt 6 SDDM theme.

The original's custom media and weather cards, edge OSD, device integrations, and palette switcher are outside this port. KRunner, Spectacle, and Klipper remain available through KDE's configured shortcuts.

## Install on CachyOS

Open Konsole from your running Plasma 6 desktop. The automatic layout requires Plasma's systemd user session and the stock Plasma widgets shipped with the CachyOS KDE edition.

```bash
git clone https://github.com/MrudhuhasM/glyph-plasma.git
cd glyph-plasma
bash install.sh
```

If Git or `qdbus6` is missing, install the corresponding packages with `sudo pacman -S --needed git qt6-tools`. Run the installer itself as your normal desktop user.

The default install briefly restarts Plasma Shell, adds Glyph Home to the primary screen of the current activity, replaces that screen's panels with the floating left rail, and applies the wallpaper to all desktops. It applies Glyph's colors and red accent, selects Breeze for Qt controls and window decorations, and uses Breeze Dark icons and Breeze cursors. This switches away from active Catppuccin/Kvantum styling without removing its files or packages. Log out and back in for appearance changes to reach the whole session. Add virtual desktops in **System Settings → Virtual Desktops** to populate the pager. You can move or resize Glyph Home from desktop Edit Mode.

In Konsole, select **Glyph Plasma** under **Edit Current Profile → Appearance**. In **System Settings → Screen Locking → Appearance**, select the installed `GlyphMatrix.png` for a matching lock screen. These manual settings can be switched back in the same menus.

Use `bash install.sh --keep-panels` on the first install to keep your panels and add the left rail. Use `bash install.sh --assets-only` to install the files for manual use. Select **Glyph Plasma** under **Colors**, find **Glyph Home** under **Add Widgets**, and pick `~/.local/share/wallpapers/GlyphMatrix.png` in the wallpaper picker (adjust for `XDG_DATA_HOME` if set). Log back in if the widget picker needs to refresh.

## Restore

```bash
bash install.sh --restore
```

The automatic install saves your original KDE config under `${XDG_STATE_HOME:-$HOME/.local/state}/glyph-plasma/original`. Restore rolls back the saved Plasma layout and appearance configuration, including later edits to those files. It removes the installed Glyph assets, archives the backup, and restarts Plasma Shell. Log out and back in to refresh the session.

If you used `--assets-only` and applied assets manually, switch back to your preferred color scheme and wallpaper and remove any Glyph Home widgets before restoring. The assets-only mode has no KDE configuration snapshot.

## Glyph login screen

Check the active display manager with `systemctl status display-manager`. If it is SDDM, preview the original Glyph greeter from the cloned repository before enabling it.

```bash
sddm-greeter-qt6 --test-mode --theme "$PWD/login/glyph"
sudo bash install-login.sh
```

The second command installs the theme under `/usr/share/sddm/themes/glyph-plasma` and writes a separate SDDM configuration drop-in. It takes effect the next time SDDM starts. To switch back, run `sudo bash install-login.sh --restore`. The login installer requires Qt 6 SDDM and leaves the display manager selection to CachyOS.

The port covers the KDE session and optional SDDM greeter. Plymouth, bootloader, disk encryption, and app-specific GTK or Firefox themes are outside this install.

## License

GPL-3.0-only. The Plasma widget, installer, and wallpaper were written for this port. The layout and visual direction are credited to [Nebelung-cloud and Glyph contributors](https://github.com/Nebelung-cloud/glyph-rice). The SDDM theme is vendored from [Glyph revision 0bab656](https://github.com/Nebelung-cloud/glyph-rice/tree/0bab656abab8c77f2d3eaff48798de8420174d08/config/sddm/glyph). Its bundled fonts are licensed under the [SIL Open Font License](login/glyph/fonts/OFL.txt).
