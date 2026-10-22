#!/usr/bin/env bash
set -euo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOPDIR="${RPMBUILD_TOPDIR:-$REPO_DIR/.work/rpmbuild}"
VERSION="$(cat "$REPO_DIR/VERSION")"
resolve_rpm() {
    if [[ -n "${1:-}" ]]; then
        RPM_FILE="$1"
    else
        shopt -s nullglob
        local files=("$TOPDIR"/RPMS/x86_64/ro-kde-systemsettings-"$VERSION"-*.x86_64.rpm)
        [[ ${#files[@]} == 1 ]] || { echo 'Expected exactly one current binary RPM' >&2; exit 1; }
        RPM_FILE="${files[0]}"
    fi
    test -f "$RPM_FILE"
}
require_disposable() {
    [[ -f /run/.containerenv || -f /.dockerenv ]] || {
        echo 'Package transactions require a disposable container.' >&2; exit 1;
    }
    [[ "$(rpm -E '%{fedora}')" == 44 && "$(uname -m)" == x86_64 ]]
    rpm -q plasma-systemsettings
}
verify_fedora() {
    rpm -q plasma-systemsettings
    test -x /usr/bin/systemsettings
    test -f /usr/share/applications/systemsettings.desktop
    [[ -z "$(rpm -V plasma-systemsettings)" ]]
    QT_QPA_PLATFORM=offscreen /usr/bin/systemsettings --help >/dev/null
}
