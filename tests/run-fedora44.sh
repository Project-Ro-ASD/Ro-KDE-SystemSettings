#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"
require_disposable
resolve_rpm "${1:-}"
OLD_RPM="${2:?Provide the previous 0.1.0 RPM}"
bash "$REPO_DIR/tests/test-smoke.sh" "$RPM_FILE"
bash "$REPO_DIR/tests/test-clean-install.sh" "$RPM_FILE"
python3 "$REPO_DIR/tests/test-runtime.py"
dnf remove -y ro-kde-systemsettings
bash "$REPO_DIR/tests/test-upgrade-remove.sh" "$RPM_FILE" "$OLD_RPM"
verify_fedora
