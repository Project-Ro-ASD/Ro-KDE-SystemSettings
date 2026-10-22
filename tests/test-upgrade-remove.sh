#!/usr/bin/env bash
set -euo pipefail

echo "==> Testing package removal and KDE preservation..."

dnf remove -y ro-kde-systemsettings

# Ensure ro-kde-systemsettings files are removed
test ! -f /usr/bin/ro-systemsettings
test ! -d /usr/lib64/ro-kde-systemsettings
test ! -d /usr/share/ro-kde-systemsettings
test ! -f /usr/share/applications/ro-systemsettings.desktop
test ! -f /usr/lib/environment.d/50-ro-kde-systemsettings.conf
test ! -f /etc/profile.d/ro-kde-systemsettings.sh

# Ensure Fedora's systemsettings is still intact and runnable
if command -v systemsettings >/dev/null 2>&1; then
    test -x /usr/bin/systemsettings
    test -f /usr/share/applications/systemsettings.desktop
    echo "  [OK] Fedora System Settings remains fully intact after removal."
fi

echo "==> Removal test PASSED!"
