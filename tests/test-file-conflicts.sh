#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"
resolve_rpm "${1:-}"
rpm -q plasma-systemsettings
# Compare every non-directory payload path against every installed Fedora package.
# Missing Fedora prerequisites and rpm query failures must fail the test.
payload="$(rpm -qp --qf '[%{FILENAMES}\t%{FILEMODES:perms}\n]' "$RPM_FILE")"
while IFS=$'\t' read -r path mode; do
    [[ "$mode" == d* ]] && continue
    if owner="$(rpm -qf "$path" 2>/dev/null)"; then
        echo "Conflict: $path is owned by $owner" >&2; exit 1
    fi
done <<< "$payload"
[[ -z "$(rpm -qp --qf '%{OBSOLETES}%{CONFLICTS}' "$RPM_FILE" | sed 's/(none)//g')" ]]
echo 'File conflict check passed'
