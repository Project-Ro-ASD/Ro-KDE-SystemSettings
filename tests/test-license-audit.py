#!/usr/bin/env python3
"""Ensure stale, added and removed payload files fail the inventory check."""
import json
from pathlib import Path
import shutil
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory() as directory:
    fixture = Path(directory)
    for name in ('scripts', '.roasd', 'bin', 'overrides', 'packaging/fedora'):
        (fixture / name).mkdir(parents=True)
    shutil.copy(root / 'scripts/check-license-audit.py', fixture / 'scripts')
    audit = fixture / '.roasd/license-audit.json'
    audit.write_text(json.dumps(dict(schema_version=1, files=[])))
    payload = fixture / 'bin/ro-systemsettings'
    payload.write_text('# SPDX-License-Identifier: GPL-3.0-or-later\n')
    command = ['python3', str(fixture / 'scripts/check-license-audit.py')]
    subprocess.run([*command, '--update'], check=True, capture_output=True)
    subprocess.run(command, check=True, capture_output=True)
    original = payload.read_text()
    payload.write_text(original + '# changed\n')
    assert subprocess.run(command, capture_output=True).returncode == 1
    payload.write_text(original)
    extra = fixture / 'overrides/added.qml'
    extra.write_text('import QtQuick\n')
    assert subprocess.run(command, capture_output=True).returncode == 1
    extra.unlink()
    payload.unlink()
    assert subprocess.run(command, capture_output=True).returncode == 1
print('License inventory drift/addition/removal rejection PASS')
