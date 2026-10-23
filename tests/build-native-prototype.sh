#!/usr/bin/env bash
# Build only in a disposable container. No installation, signing or publication.
set -euo pipefail
[[ -e /run/.containerenv || -e /.dockerenv ]] || { echo 'Disposable container required' >&2; exit 1; }
root="$(cd "$(dirname "$0")/.." && pwd)"
top="${1:?Usage: build-native-prototype.sh PREPARED_TOPDIR}"
top="$(realpath "$top")"
[[ "$top" == "$root/.work/"* ]] || { echo 'Topdir must be under .work/' >&2; exit 1; }
rpmbuild -ba --define "_topdir $top" --define 'dist .fc44' --define '_smp_mflags -j4' \
    "$top/SPECS/plasma-systemsettings.spec"
rpmbuild -ba --define "_topdir $top" --define 'dist .fc44' \
    "$top/SPECS/ro-systemsettings-native-skin-prototype.spec"
