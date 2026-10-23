#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
build="${1:?Build directory}"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
chmod 700 "$tmp"
export LANG="${2:-en_US.UTF-8}"
export QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software
export XDG_RUNTIME_DIR="$tmp" XDG_CONFIG_HOME="$tmp/config" XDG_CACHE_HOME="$tmp/cache" XDG_DATA_HOME="$tmp/data"
if [[ -n "${RO_SCREENSHOT_DIR:-}" ]]; then
    export RO_SCREENSHOT_DIR="$RO_SCREENSHOT_DIR/$LANG"
    mkdir -p "$RO_SCREENSHOT_DIR"
fi
export QT_PLUGIN_PATH="$build/test-plugins"
# Test-only metadata: never installed in the product or written into system paths.
mkdir -p "$XDG_DATA_HOME/systemsettings/categories"
for level in top middle leaf; do
    case "$level" in top) parent="";; middle) parent=ro-test-top;; leaf) parent=ro-test-middle;; esac
    cat > "$XDG_DATA_HOME/systemsettings/categories/ro-test-$level.desktop" <<EOF_META
[Desktop Entry]
Type=Service
Name=Ro Test $level
X-KDE-System-Settings-Category=ro-test-$level
X-KDE-System-Settings-Parent-Category=$parent
EOF_META
done
unset DBUS_SESSION_BUS_ADDRESS WAYLAND_DISPLAY DISPLAY
dbus-run-session -- "$build/ro-shell-tests" 2>&1 | tee "$tmp/test.log"
if grep -E 'TypeError:|ReferenceError:|Binding loop|Attempting to add QLayout' "$tmp/test.log"; then
    echo 'QML/host integration diagnostic found' >&2; exit 1
fi
