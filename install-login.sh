#!/usr/bin/env bash
set -euo pipefail

source_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
theme_dir=/usr/share/sddm/themes/glyph-plasma
drop_in=/etc/sddm.conf.d/zz-glyph-plasma.conf
marker=$theme_dir/.glyph-plasma-owned

fail() { printf '%s\n' "$*" >&2; exit 1; }
mode=${1:---install}
case "$mode" in
    --help|-h)
        printf 'Usage: sudo bash install-login.sh [--restore]\n'
        exit 0 ;;
    --install|--restore) ;;
    *) fail "Usage: sudo bash install-login.sh [--restore]" ;;
esac
[[ $# -le 1 ]] || fail "Pass at most one option."
[[ $EUID -eq 0 ]] || fail "Run this script with sudo."
exec 9>/run/lock/glyph-plasma-sddm.lock
flock -n 9 || fail "Another Glyph login installer is running."

if [[ $mode == --restore ]]; then
    [[ -f $marker && ! -L $theme_dir ]] || fail "No managed Glyph SDDM theme found."
    rm -f -- "$drop_in"
    rm -rf -- "$theme_dir"
    printf 'Glyph removed. Your previous SDDM settings will be used at the next login.\n'
    exit 0
fi

command -v sddm-greeter-qt6 >/dev/null || fail "The Qt 6 SDDM greeter is required."
systemctl is-active --quiet sddm.service || fail "SDDM is not the active display manager."
if [[ -f /etc/sddm.conf ]] && awk '
    /^[[:space:]]*\[/ { theme = ($0 ~ /^[[:space:]]*\[Theme\][[:space:]]*$/) }
    theme && /^[[:space:]]*Current[[:space:]]*=/ { found = 1 }
    END { exit !found }
' /etc/sddm.conf; then
    fail "/etc/sddm.conf sets [Theme] Current and takes precedence. Back up that file and remove its Current override before running this installer."
fi
if [[ -e $theme_dir || -L $theme_dir ]]; then
    [[ -f $marker && ! -L $theme_dir ]] || fail "Theme directory already exists: $theme_dir"
fi
if [[ -e $drop_in || -L $drop_in ]]; then
    [[ -f $marker && ! -L $drop_in ]] || fail "SDDM configuration already exists: $drop_in"
fi

mkdir -p -- "$theme_dir/fonts" "$(dirname -- "$drop_in")"
touch "$marker"
install -m 644 -- "$source_dir/login/glyph/"Main.qml "$source_dir/login/glyph/"metadata.desktop \
    "$source_dir/login/glyph/"theme.conf "$theme_dir/"
install -m 644 -- "$source_dir/login/glyph/fonts/"* "$theme_dir/fonts/"
staging=$(mktemp "${drop_in}.XXXXXXXX")
trap 'rm -f -- "$staging"' EXIT
printf '[Theme]\nCurrent=glyph-plasma\n' > "$staging"
chmod 644 "$staging"
mv -f -- "$staging" "$drop_in"
printf 'Glyph SDDM theme installed. Changes take effect the next time SDDM starts.\n'
