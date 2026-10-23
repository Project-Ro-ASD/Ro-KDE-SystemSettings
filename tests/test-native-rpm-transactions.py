#!/usr/bin/env python3
"""Real DNF/RPM transitions in a DISPOSABLE container; never a host test."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys

parser = argparse.ArgumentParser(description=__doc__)
for name in ('older-rpm', 'patched-rpm', 'stock-rpm', 'skin-rpm', 'output'):
    parser.add_argument('--' + name, type=Path, required=True)
args = parser.parse_args()
if not Path('/run/.containerenv').exists() and not Path('/.dockerenv').exists():
    parser.error('Disposable container required; this test changes installed KDE RPMs')
root = Path(__file__).resolve().parents[1]
args.output.mkdir(parents=True, exist_ok=True)
steps = []

def run(command):
    result = subprocess.run(command, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    steps.append(dict(command=command, returncode=result.returncode, output=result.stdout))
    (args.output / 'transactions.json').write_text(json.dumps(steps, indent=2) + '\n')
    if result.returncode:
        raise RuntimeError(f'Command failed: {command}; see transactions.json')
    return result.stdout

def verify():
    run(['rpm', '-V', 'plasma-systemsettings', 'ro-systemsettings-native-skin-prototype'])
    owner = run(['rpm', '-qf', '--qf', '%{NAME}\n', '/usr/bin/systemsettings']).strip()
    assert owner == 'plasma-systemsettings', owner
    for filename in run(['rpm', '-ql', 'ro-systemsettings-native-skin-prototype']).splitlines():
        if not Path(filename).is_dir():
            assert run(['rpm', '-qf', '--qf', '%{NAME}\n', filename]).strip() == 'ro-systemsettings-native-skin-prototype'
        assert not filename.startswith(('/etc/', '/usr/bin/', '/usr/lib/systemd/'))
        assert not filename.endswith(('.so', '.service'))

def smoke(name, expected):
    output = args.output / name
    run([sys.executable, str(root / 'tests/measure-native-process.py'), '/usr/bin/systemsettings',
         '--output', str(output), '--opt-in', '1', '--trials', '1', '--seconds', '2'])
    record = json.loads((output / 'measurement.json').read_text())
    trial = record['trials'][0]
    assert trial['status'] == 'MEASURED', trial
    markers = '\n'.join(trial['sidebar_markers'])
    if expected == 'ro':
        assert 'file:///usr/share/ro-kde-systemsettings/native/Main.qml' in markers, markers
    elif expected == 'fallback':
        assert 'qrc:/qt/qml/org/kde/systemsettings/Main.qml' in markers, markers
    else:
        assert not markers, markers

skin_path = Path('/usr/share/ro-kde-systemsettings/native/Main.qml')
installed = subprocess.run(['rpm', '-q', 'ro-systemsettings-native-skin-prototype'],
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0
run(['dnf', '--disablerepo=*', 'reinstall' if installed else 'install', '-y', str(args.skin_rpm)])
run(['dnf', '--disablerepo=*', 'downgrade', '-y', str(args.older_rpm)])
verify()
skin_digest = hashlib.sha256(skin_path.read_bytes()).hexdigest()
smoke('older-patched-ro', 'ro')

# A real, newer Fedora package wins normal RPM ordering over an older Ro build.
run(['dnf', '--disablerepo=*', 'upgrade', '-y', str(args.stock_rpm)])
verify()
assert hashlib.sha256(skin_path.read_bytes()).hexdigest() == skin_digest
stock_digest = hashlib.sha256(Path('/usr/bin/systemsettings').read_bytes()).hexdigest()
run(['rpm', '-q', 'plasma-systemsettings'])
smoke('newer-fedora-stock', 'stock')

# The next matching rebuild restores the opt-in visual layer without changing it.
run(['dnf', '--disablerepo=*', 'upgrade', '-y', str(args.patched_rpm)])
verify()
assert hashlib.sha256(skin_path.read_bytes()).hexdigest() == skin_digest
smoke('matching-rebuild-ro', 'ro')

run(['dnf', '--disablerepo=*', 'remove', '--no-autoremove', '-y', 'ro-systemsettings-native-skin-prototype'])
assert not skin_path.exists()
assert not Path('/usr/share/locale/tr/LC_MESSAGES/ro-systemsettings-native-skin.mo').exists()
run(['rpm', '-V', 'plasma-systemsettings'])
smoke('skin-uninstalled-stock-fallback', 'fallback')

# Removing resources alone does not restore the Fedora executable. Do that explicitly.
run(['dnf', '--disablerepo=*', 'downgrade', '-y', str(args.stock_rpm)])
run(['rpm', '-V', 'plasma-systemsettings'])
assert hashlib.sha256(Path('/usr/bin/systemsettings').read_bytes()).hexdigest() == stock_digest
smoke('fedora-binary-restored', 'stock')
print('Native prototype RPM ownership/update/remove/stock-restore PASS')
