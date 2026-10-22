#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"
resolve_rpm
[[ ! -e release-rpms ]] || { echo 'Bundle directory must be fresh' >&2; exit 1; }
mkdir release-rpms
shopt -s nullglob
sources=("$TOPDIR"/SRPMS/*.src.rpm)
[[ ${#sources[@]} == 1 ]]
cp "$RPM_FILE" "${sources[0]}" release-rpms/
rpmlint release-rpms/*.rpm | tee /tmp/ro-systemsettings-rpmlint.log
# Fedora scoring can return success despite low-scoring E diagnostics.
if grep -E ': E: ' /tmp/ro-systemsettings-rpmlint.log; then exit 1; fi
python3 "$REPO_DIR/tests/test-manifest.py" release-rpms
export GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-Project-Ro-ASD/Ro-KDE-SystemSettings}"
export GITHUB_SHA="${GITHUB_SHA:-$(git -C "$REPO_DIR" rev-parse HEAD)}"
export TAG=dry-run RELEASE_ID=0 GITHUB_RUN_ID="${GITHUB_RUN_ID:-0}"
python3 "$REPO_DIR/scripts/generate-manifest.py" release-rpms
(cd release-rpms && sha256sum -c SHA256SUMS)
