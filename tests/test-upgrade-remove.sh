#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"
require_disposable
resolve_rpm "${1:-}"
OLD_RPM="${2:?Provide an actual previous-version RPM for the upgrade test}"
[[ "$(rpm -qp --qf '%{NAME}-%{VERSION}' "$OLD_RPM")" == ro-kde-systemsettings-0.1.0 ]]
if rpm -q ro-kde-systemsettings; then echo 'Upgrade test needs a clean container' >&2; exit 1; fi
verify_fedora
dnf install -y "$OLD_RPM"
dnf upgrade -y "$RPM_FILE"
[[ "$(rpm -q --qf '%{VERSION}' ro-kde-systemsettings)" == "$VERSION" ]]
[[ -z "$(rpm -V ro-kde-systemsettings)" ]]
test ! -e /usr/lib/environment.d/50-ro-kde-systemsettings.conf
test ! -e /etc/profile.d/ro-kde-systemsettings.sh
QT_QPA_PLATFORM=offscreen /usr/bin/ro-systemsettings --help >/dev/null
verify_fedora
rpm -ql ro-kde-systemsettings > /tmp/ro-systemsettings-installed-files
dnf remove -y ro-kde-systemsettings
if rpm -q ro-kde-systemsettings; then exit 1; fi
while IFS= read -r path; do test ! -e "$path"; done < /tmp/ro-systemsettings-installed-files
verify_fedora
echo 'Actual 0.1.0 upgrade/removal and Fedora integrity passed'
