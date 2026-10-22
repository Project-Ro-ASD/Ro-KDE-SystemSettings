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
    "/usr/lib64/ro-kde-systemsettings/libsystemsettings_override.so"
    "/usr/share/ro-kde-systemsettings/overrides.rcc"
    "/usr/share/ro-kde-systemsettings/tabs.qss"
    "/usr/share/ro-kde-systemsettings/applications/systemsettings.desktop"
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

# 3. Check categories in payload
CAT_COUNT="$(echo "$PAYLOAD" | grep -c '/usr/share/ro-kde-systemsettings/systemsettings/categories/.*\.desktop$' || true)"
if [ "$CAT_COUNT" -lt 15 ]; then
    echo "FAIL: Expected at least 15 category desktop files, found $CAT_COUNT" >&2
    exit 1
fi
echo "  [OK] Payload contains $CAT_COUNT category desktop files"

# 4. Check translations in payload
MO_COUNT="$(echo "$PAYLOAD" | grep -c '/usr/share/ro-kde-systemsettings/locale/tr/LC_MESSAGES/.*\.mo$' || true)"
if [ "$MO_COUNT" -lt 4 ]; then
    echo "FAIL: Expected at least 4 compiled translation files, found $MO_COUNT" >&2
    exit 1
fi
echo "  [OK] Payload contains $MO_COUNT Turkish translation files"

echo "==> Smoke test PASSED for $RPM_FILE!"

for path in /usr/bin/systemsettings /usr/share/applications/systemsettings.desktop /usr/lib/environment.d/50-ro-kde-systemsettings.conf /etc/profile.d/ro-kde-systemsettings.sh; do
    if grep -Fxq "$path" <<< "$PAYLOAD"; then echo "Forbidden global payload: $path" >&2; exit 1; fi
done
