#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "$REPO_DIR/VERSION")"
TOPDIR="${RPMBUILD_TOPDIR:-$HOME/rpmbuild}"

echo "==> Building ro-kde-systemsettings RPM and SRPM (version: $VERSION)..."

mkdir -p "$TOPDIR"/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
tar --exclude-vcs --exclude='.work' --exclude='build' --exclude='packaging/fedora/*.rpm' \
    --transform "s,^\.,ro-kde-systemsettings-${VERSION}," \
    -czf "$TOPDIR/SOURCES/ro-kde-systemsettings-${VERSION}.tar.gz" -C "$REPO_DIR" .

cp "$REPO_DIR/packaging/fedora/ro-kde-systemsettings.spec" "$TOPDIR/SPECS/"

rpmbuild -ba --define "_topdir $TOPDIR" --define "dist .fc44" "$TOPDIR/SPECS/ro-kde-systemsettings.spec"

echo "==> Built RPMs successfully:"
ls -lh "$TOPDIR/RPMS/x86_64/"*.rpm "$TOPDIR/SRPMS/"*.rpm
