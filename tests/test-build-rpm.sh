#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"
[[ "$(rpm -E '%{fedora}')" == 44 && "$(uname -m)" == x86_64 ]]
[[ ! -e "$TOPDIR/RPMS" && ! -e "$TOPDIR/SRPMS" ]] || {
    echo "Use a fresh RPMBUILD_TOPDIR: $TOPDIR" >&2; exit 1;
}
mkdir -p "$TOPDIR"/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
# Include tracked source only, including staged/unstaged edits for local validation.
git -C "$REPO_DIR" ls-files -z | tar -C "$REPO_DIR" --null -T - --transform "s,^,Ro-KDE-SystemSettings-${VERSION}/," \
    -czf "$TOPDIR/SOURCES/ro-kde-systemsettings-${VERSION}.tar.gz"
cp "$REPO_DIR/packaging/fedora/ro-kde-systemsettings.spec" "$TOPDIR/SPECS/"
rpmbuild -ba --define "_topdir $TOPDIR" --define 'dist .fc44' "$TOPDIR/SPECS/ro-kde-systemsettings.spec"
bash "$REPO_DIR/tests/test-smoke.sh"

python3 "$REPO_DIR/tests/test-rcc-rebuild.py"
