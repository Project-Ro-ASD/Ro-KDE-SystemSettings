#!/usr/bin/env python3
"""Integration cases against an instrumented original KDE systemsettings build.

Requires the caller to document any provider exclusion. Edits ONLY the temporary
container's fixed skin path and restores it even when a test fails.
"""
import argparse
import json
from pathlib import Path
import subprocess
import sys

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('executable', type=Path)
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
if not Path('/run/.containerenv').exists() and not Path('/.dockerenv').exists():
    parser.error('Disposable container required')
root = Path(__file__).resolve().parents[1]
asset = Path('/usr/share/ro-kde-systemsettings/native/Main.qml')
original = asset.read_bytes()
cases = (
    ('opt-out', original, 'stock', '0'),
    ('valid', original, 'ro', '1'),
    ('missing', None, 'stock', '1'),
    ('malformed', b'import QtQuick\nItem { broken syntax }', 'stock', '1'),
    ('missing-import', b'import Does.Not.Exist\nItem {}', 'stock', '1'),
    ('wrong-root-type', b'import QtQml\nQtObject {}', 'stock', '1'),
    ('missing-header', b'import QtQuick\nItem { implicitWidth: 300 }', 'stock', '1'),
    ('invalid-width', b'import QtQuick\nItem { property real headerHeight: 40; implicitWidth: 0 }', 'stock', '1'),
    ('invalid-header', b'import QtQuick\nItem { property real headerHeight: NaN; implicitWidth: 300 }', 'stock', '1'),
)
results = []
try:
    for name, content, expected, opt_in in cases:
        if content is None:
            asset.unlink()
        else:
            asset.write_bytes(content)
        command = [sys.executable, str(root / 'tests/run-native-case.py'), str(args.executable),
                   '--output', str(args.output / name), '--expect', expected, '--opt-in', opt_in]
        result = subprocess.run(command)
        results.append(dict(case=name, exit_code=result.returncode, expected=expected))
finally:
    asset.write_bytes(original)
args.output.mkdir(parents=True, exist_ok=True)
(args.output / 'summary.json').write_text(json.dumps(results, indent=2) + '\n')
if any(result['exit_code'] for result in results):
    raise SystemExit(1)
print('Native fallback cases PASS (offscreen; provider scope must be recorded)')
