#!/usr/bin/env bash
set -euo pipefail

RPM_FILE="${1:-}"
if [ -z "$RPM_FILE" ]; then
    RPM_FILE="$(find "${RPMBUILD_TOPDIR:-$HOME/rpmbuild}/RPMS/x86_64" -name "ro-kde-systemsettings-*.x86_64.rpm" | head -n1)"
fi

echo "==> Testing clean installation of $RPM_FILE..."

dnf install -y "$RPM_FILE"

# Verify installed files exist on disk
test -x /usr/bin/ro-systemsettings
test -f /usr/lib64/ro-kde-systemsettings/libsystemsettings_override.so
test -f /usr/share/ro-kde-systemsettings/overrides.rcc
test -f /usr/share/ro-kde-systemsettings/tabs.qss
test -f /usr/share/ro-kde-systemsettings/applications/systemsettings.desktop
test -f /usr/share/applications/ro-systemsettings.desktop
test -f /usr/lib/environment.d/50-ro-kde-systemsettings.conf
test -f /etc/profile.d/ro-kde-systemsettings.sh

# Verify permissions and dynamic linking
ldd /usr/lib64/ro-kde-systemsettings/libsystemsettings_override.so >/dev/null

echo "==> Clean install test PASSED!"
