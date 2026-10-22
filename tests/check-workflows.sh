#!/usr/bin/env bash
set -euo pipefail
# Pin both release and bytes. Never execute a remote installer script.
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
curl --fail --location --retry 3 --max-time 120 \
    https://github.com/rhysd/actionlint/releases/download/v1.7.12/actionlint_1.7.12_linux_amd64.tar.gz \
    -o "$tmp/actionlint.tar.gz"
printf '%s\n' "8aca8db96f1b94770f1b0d72b6dddcb1ebb8123cb3712530b08cc387b349a3d8  $tmp/actionlint.tar.gz" | sha256sum -c -
tar -C "$tmp" -xf "$tmp/actionlint.tar.gz" actionlint
"$tmp/actionlint" .github/workflows/*.yml
