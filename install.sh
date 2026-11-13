#!/usr/bin/env bash
set -euo pipefail
umask 077

source_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
config_dir=${XDG_CONFIG_HOME:-"$HOME/.config"}
data_dir=${XDG_DATA_HOME:-"$HOME/.local/share"}
state_dir=${XDG_STATE_HOME:-"$HOME/.local/state"}/glyph-plasma
backup=$state_dir/original
widget_id=io.github.glyphplasma.home
widget_dir=$data_dir/plasma/plasmoids/$widget_id
scheme=$data_dir/color-schemes/GlyphPlasma.colors
wallpaper=$data_dir/wallpapers/GlyphMatrix.png
terminal=$data_dir/konsole/GlyphPlasma.colorscheme
config_files=(kdeglobals plasmashellrc plasma-org.kde.plasma.desktop-appletsrc)
appearance_files=(plasmarc kcminputrc kwinrc)
config_files+=("${appearance_files[@]}")

fail() { printf '%s\n' "$*" >&2; exit 1; }
require() {
    local command
    for command in "$@"; do
        command -v "$command" >/dev/null || fail "Missing command: $command"
    done
}
plasma() {
    qdbus6 org.kde.plasmashell /PlasmaShell "org.kde.PlasmaShell.$1" "${@:2}"
}
usage() {
    cat <<'EOF'
Usage: bash install.sh [--keep-panels | --assets-only | --restore]
  default        Apply the theme and replace the primary screen's panels
  --keep-panels  Apply the theme and add the left rail alongside existing panels
  --assets-only  Install the color scheme, wallpaper and widget for manual use
  --restore      Restore the pre-install KDE configuration and remove Glyph assets
EOF
}

mode=${1:---apply}
case "$mode" in
    -h|--help) usage; exit 0 ;;
    --apply|--keep-panels|--assets-only|--restore) ;;
    *) usage >&2; exit 2 ;;
esac
[[ $# -le 1 ]] || fail "Pass at most one option."
[[ $EUID -ne 0 ]] || fail "Run as your desktop user without sudo."
require flock
mkdir -p -- "$state_dir"
exec 9>"$state_dir/lock"
flock -n 9 || fail "Another Glyph installer is running."

if [[ $mode != --assets-only ]]; then
    require qdbus6 systemctl
    [[ -n ${DISPLAY:-}${WAYLAND_DISPLAY:-} ]] || fail "Open a terminal inside your Plasma session."
    systemctl --user is-active --quiet plasma-plasmashell.service ||
        fail "This operation requires Plasma's systemd user session."
    plasma shell >/dev/null || fail "Could not connect to Plasma Shell."
fi

if [[ $mode == --restore ]]; then
    [[ -d $backup || -f $state_dir/assets-owned ]] || fail "No Glyph installation was found."
    systemctl --user stop plasma-plasmashell.service
    trap 'systemctl --user start plasma-plasmashell.service' EXIT
    if [[ -d $backup ]]; then
        for file in "${config_files[@]}"; do
            case "$file" in
                plasmarc|kcminputrc|kwinrc)
                    [[ -f $backup/appearance-saved ]] || continue
                    ;;
            esac
            if [[ -e $backup/$file || -L $backup/$file ]]; then
                cp -a --remove-destination -- "$backup/$file" "$config_dir/$file"
            else
                rm -f -- "$config_dir/$file"
            fi
        done
    fi
    if [[ -f $state_dir/assets-owned ]]; then
        rm -rf -- "$widget_dir"
        rm -f -- "$scheme" "$wallpaper" "$state_dir/assets-owned"
    fi
    if [[ -f $state_dir/terminal-owned ]]; then
        rm -f -- "$terminal" "$state_dir/terminal-owned"
    fi
    if [[ -d $backup ]]; then
        archive=$(mktemp -d "$state_dir/restored.XXXXXXXX")
        mv -- "$backup" "$archive/original"
        printf 'Archived the original backup at %s\n' "$archive/original"
    fi
    printf 'Log out and back in to reload the restored appearance throughout the session.\n'
    exit 0
fi

if [[ $mode != --assets-only ]]; then
    require plasma-apply-colorscheme plasma-apply-wallpaperimage kwriteconfig6
    [[ -d /usr/share/icons/breeze-dark && -d /usr/share/icons/breeze_cursors ]] ||
        fail "Install the breeze, breeze-icons and breeze-cursors packages first."
    result=$(plasma evaluateScript 'if (!locked) print("GLYPH_READY");')
    [[ $result == *GLYPH_READY* ]] || fail "Unlock Plasma widgets before installing."
fi

if [[ ! -f $state_dir/assets-owned ]]; then
    for path in "$widget_dir" "$scheme" "$wallpaper"; do
        [[ ! -e $path && ! -L $path ]] || fail "Asset already exists: $path"
    done
    touch "$state_dir/assets-owned"
fi

mkdir -p -- "$widget_dir/contents/ui" "$(dirname -- "$scheme")" "$(dirname -- "$wallpaper")"
install -m 644 -- "$source_dir/plasma/metadata.json" "$widget_dir/metadata.json"
install -m 644 -- "$source_dir/plasma/contents/ui/"*.qml "$widget_dir/contents/ui/"
install -m 644 -- "$source_dir/assets/GlyphPlasma.colors" "$scheme"
install -m 644 -- "$source_dir/assets/GlyphMatrix.png" "$wallpaper"
if [[ ! -e $terminal && ! -L $terminal ]]; then
    touch "$state_dir/terminal-owned"
fi
if [[ -f $state_dir/terminal-owned ]]; then
    mkdir -p -- "$(dirname -- "$terminal")"
    install -m 644 -- "$source_dir/assets/GlyphPlasma.colorscheme" "$terminal"
fi

if [[ $mode == --assets-only ]]; then
    printf 'Assets installed. Find Glyph Plasma in Colors and Glyph Home under Add Widgets.\n'
    printf 'Wallpaper: %s\n' "$wallpaper"
    exit 0
fi

if [[ ! -d $backup ]]; then
    staging=$(mktemp -d "$state_dir/backup.XXXXXXXX")
    systemctl --user stop plasma-plasmashell.service
    trap 'systemctl --user start plasma-plasmashell.service' EXIT
    mkdir -p -- "$config_dir"
    for file in "${config_files[@]}"; do
        if [[ -e $config_dir/$file || -L $config_dir/$file ]]; then
            cp -a -- "$config_dir/$file" "$staging/$file"
        fi
    done
    touch "$staging/appearance-saved"
    mv -- "$staging" "$backup"
    systemctl --user start plasma-plasmashell.service
    trap - EXIT
else
    # Backups made by the first release did not cover these files.
    if [[ ! -f $backup/appearance-saved ]]; then
        for file in "${appearance_files[@]}"; do
            if [[ -e $config_dir/$file || -L $config_dir/$file ]]; then
                cp -a --remove-destination -- "$config_dir/$file" "$backup/$file"
            else
                rm -f -- "$backup/$file"
            fi
        done
        touch "$backup/appearance-saved"
    fi
    systemctl --user restart plasma-plasmashell.service
fi

printf 'Original configuration saved at %s\n' "$backup"
ready=false
for ((attempt = 0; attempt < 30; attempt++)); do
    if result=$(plasma evaluateScript 'if (desktops().some(d => d.screen === 0)) print("GLYPH_READY");' 2>/dev/null) &&
       [[ $result == *GLYPH_READY* ]]; then
        ready=true
        break
    fi
    sleep 1
done
[[ $ready == true ]] || fail "Plasma did not finish starting. Run the installer again or use --restore."

replace=true
[[ $mode == --keep-panels ]] && replace=false
result=$(plasma evaluateScript "$(cat -- "$source_dir/layout.js")"$'\n'"applyGlyphLayout($replace);")
[[ $result == *GLYPH_LAYOUT_APPLIED* ]] || fail "Plasma could not apply the layout: $result. Run with --restore to revert."
plasma-apply-colorscheme GlyphPlasma
plasma-apply-colorscheme --accent-color '#e33141'
kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle Breeze
kwriteconfig6 --file kdeglobals --group Icons --key Theme breeze-dark
kwriteconfig6 --file plasmarc --group Theme --key name default
kwriteconfig6 --file kcminputrc --group Mouse --key cursorTheme breeze_cursors
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key library org.kde.breeze
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme Breeze
plasma-apply-wallpaperimage "$wallpaper"
printf 'Glyph Plasma applied. Use bash install.sh --restore to roll back.\n'
printf 'Log out and back in to apply the application style, icons, cursor and decorations throughout the session.\n'
