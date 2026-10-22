#!/usr/bin/env bash
set -euo pipefail

RPM_FILE="${1:-}"
if [ -z "$RPM_FILE" ]; then
    RPM_FILE="$(find "${RPMBUILD_TOPDIR:-$HOME/rpmbuild}/RPMS/x86_64" -name "ro-kde-systemsettings-*.x86_64.rpm" | head -n1)"
fi

if [ ! -f "$RPM_FILE" ]; then
    echo "Error: RPM file not found: $RPM_FILE" >&2
    exit 1
fi

echo "==> Checking file conflicts for $RPM_FILE..."

# Check conflicts with plasma-systemsettings
if rpm -q plasma-systemsettings >/dev/null 2>&1; then
    CONFLICTS=$(comm -12 \
        <(rpm -qlp "$RPM_FILE" | grep -vE '/usr/share/doc|/usr/share/licenses|/usr/lib/\.build-id' | sort) \
        <(rpm -ql plasma-systemsettings | sort))
    if [ -n "$CONFLICTS" ]; then
        echo "FAIL: File conflict detected with plasma-systemsettings:" >&2
        echo "$CONFLICTS" >&2
        exit 1
    fi
fi

echo "==> SUCCESS: No file conflicts detected with Fedora packages!"
