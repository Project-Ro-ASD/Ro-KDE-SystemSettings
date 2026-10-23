#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"
require_disposable
resolve_rpm "${1:-}"
if rpm -q ro-kde-systemsettings; then echo 'Package already installed' >&2; exit 1; fi
verify_fedora
bash "$REPO_DIR/tests/test-file-conflicts.sh" "$RPM_FILE"
dnf install -y "$RPM_FILE"
[[ "$(rpm -q --qf '%{VERSION}' ro-kde-systemsettings)" == "$VERSION" ]]
[[ -z "$(rpm -V ro-kde-systemsettings)" ]]
linking="$(ldd -r /usr/bin/ro-systemsettings 2>&1)"
if grep -E 'not found|undefined symbol' <<< "$linking"; then exit 1; fi
QT_QPA_PLATFORM=offscreen /usr/bin/ro-systemsettings --help >/dev/null
verify_fedora
