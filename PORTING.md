# Glyph on KDE Plasma

The reference is [Nebelung-cloud/glyph-rice](https://github.com/Nebelung-cloud/glyph-rice). Plasma, KWin and the KDE session services are the base for this port.

| Original feature | Current Plasma behavior |
| --- | --- |
| Bar | Floating left rail with launcher, workspaces, task switcher, centered clock and system tray. |
| Home | Dot clock, greeting, date, calendar card, seconds ring, MPRIS playback and system stats. The media dots animate with playback state. Weather, disk readings and audio-reactive visualization are pending. |
| Glyph | Stock Plasma volume and brightness indicators. Custom screen-edge indicators are pending. |
| Launcher | Kickoff for apps and KRunner for search and calculations. A Glyph launcher with integrated windows and styles is pending. |
| Quick | `Meta+A` opens a Glyph panel with volume, mute, brightness, playback, and focus countdown. KDE's tray handles connectivity, battery and notifications. The custom edge gesture and game mode are pending. |
| Deck and Prefs | Pending. KDE System Settings handles audio devices and desktop configuration. |
| Shot, Clip and Charms | KDE Spectacle, Klipper and Emoji Selector provide the stock capture, clipboard and emoji workflows. Glyph's editor and custom interfaces are pending. |
| Walls and Style | Glyph's dot wallpaper and fixed monochrome/red palette. The wallpaper picker, color extraction and live palette switching are pending. |
| VPN and Buds | KDE's NetworkManager and Bluetooth integration. Clash Verge and Nothing/CMF-specific controls are pending. |
| Cal | Browsable Glyph month view and a persistent 25-minute deadline in Quick. The rail clock also opens Plasma's calendar. |
| Power and Lock | KDE session and lock screens, with an optional matching wallpaper for the lock screen. Custom Glyph interactions are pending. |
| Login | Original Glyph SDDM theme, installed separately on Qt 6 SDDM. |
| Terminal | Glyph Konsole color scheme. Shell prompt, system info and CAVA integration are pending. |

The widget uses KDE's private MPRIS, audio and brightness QML modules. Verify these on the target Plasma release after major upgrades. The port has yet to be exercised end to end on a CachyOS Plasma session.
