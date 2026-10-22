#!/usr/bin/env bash
set -euo pipefail
mkdir -p .work
curl --fail --location --retry 3 -o .work/previous.rpm \
  https://github.com/Project-Ro-ASD/Ro-KDE-SystemSettings/releases/download/v0.1.0/ro-kde-systemsettings-0.1.0-1.roasd1.fc44.x86_64.rpm
# Pin bytes because this historical release is mutable; never trust its tag alone.
printf '%s\n' '6860e507b6b68d04dee1e3e0514f232dbe18a87e524fc4cfb6cf394cfcbdcbcc  .work/previous.rpm' | sha256sum -c -
