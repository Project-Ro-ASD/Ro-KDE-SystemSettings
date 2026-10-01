#!/usr/bin/env bash
set -euo pipefail

required=(git python3 patch)
recommended=(cmake ninja rpm rpmbuild)
missing_required=0

echo "Ro-KDE-SystemSettings development environment"
echo

for cmd in "${required[@]}"; do
  if command -v "$cmd" >/dev/null 2>&1; then
    printf "  [ok]       %s\n" "$cmd"
  else
    printf "  [missing]  %s (required)\n" "$cmd"
    missing_required=1
  fi
done

for cmd in "${recommended[@]}"; do
  if command -v "$cmd" >/dev/null 2>&1; then
    printf "  [ok]       %s\n" "$cmd"
  else
    printf "  [optional] %s\n" "$cmd"
  fi
done

echo
if [[ -r /etc/os-release ]]; then
  . /etc/os-release
  echo "Host: ${PRETTY_NAME:-unknown}"
fi

if [[ "$missing_required" -ne 0 ]]; then
  echo
  echo "Required tools are missing. Install them before modifying upstream sources."
  exit 1
fi

echo
echo "Preflight OK."
