#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/lib.sh"
resolve_rpm "${1:-}"
echo "==> Running smoke tests for ro-kde-systemsettings..."

# 1. Inspect package metadata
NAME="$(rpm -qp --qf '%{NAME}' "$RPM_FILE")"
RPM_VERSION="$(rpm -qp --qf '%{VERSION}' "$RPM_FILE")"
ARCH="$(rpm -qp --qf '%{ARCH}' "$RPM_FILE")"

if [ "$NAME" != "ro-kde-systemsettings" ]; then
    echo "FAIL: Expected package name ro-kde-systemsettings, got $NAME" >&2
    exit 1
fi
if [ "$ARCH" != "x86_64" ]; then
    echo "FAIL: Expected arch x86_64, got $ARCH" >&2
    exit 1
fi

[[ "$RPM_VERSION" == "$VERSION" ]]
[[ "$(rpm -qp --qf '%{RELEASE}' "$RPM_FILE")" == 1.roasd1.fc44 ]]
[[ "$(rpm -qp --qf '%{LICENSE}' "$RPM_FILE")" == "$(sed -n 's/^License: *//p' "$REPO_DIR/packaging/fedora/ro-kde-systemsettings.spec")" ]]

# 2. Check essential files in payload
REQUIRED_FILES=(
    "/usr/bin/ro-systemsettings"
    "/usr/share/applications/ro-systemsettings.desktop"
)

PAYLOAD="$(rpm -qlp "$RPM_FILE")"
for f in "${REQUIRED_FILES[@]}"; do
    if ! echo "$PAYLOAD" | grep -qx "$f"; then
        echo "FAIL: Missing required file in RPM payload: $f" >&2
        exit 1
    fi
    echo "  [OK] Payload contains: $f"
done

# No obsolete imports, QSS, copied KDE categories/translations, RCC or hook library.
if grep -Eq '/ro-kde-systemsettings/(qml|locale|tabs.qss|overrides.rcc|systemsettings|applications)|libsystemsettings_override' <<< "$PAYLOAD"; then
    echo 'Obsolete payload is still distributed' >&2; exit 1
fi
rpm2cpio "$RPM_FILE" | cpio --quiet -i --to-stdout ./usr/bin/ro-systemsettings > /tmp/ro-elf-magic
[[ "$(od -An -N4 -tx1 /tmp/ro-elf-magic | tr -d ' \n')" == 7f454c46 ]]

echo "==> Smoke test PASSED for $RPM_FILE!"

for path in /usr/bin/systemsettings /usr/share/applications/systemsettings.desktop /usr/lib/environment.d/50-ro-kde-systemsettings.conf /etc/profile.d/ro-kde-systemsettings.sh; do
    if grep -Fxq "$path" <<< "$PAYLOAD"; then echo "Forbidden global payload: $path" >&2; exit 1; fi
done
