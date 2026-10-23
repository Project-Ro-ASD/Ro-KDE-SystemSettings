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
export QT_PLUGIN_PATH="$build/test-plugins"
unset DBUS_SESSION_BUS_ADDRESS WAYLAND_DISPLAY DISPLAY
dbus-run-session -- "$build/ro-shell-tests" 2>&1 | tee "$tmp/test.log"
if grep -E 'TypeError:|ReferenceError:|Binding loop|Attempting to add QLayout' "$tmp/test.log"; then
    echo 'QML/host integration diagnostic found' >&2; exit 1
fi
