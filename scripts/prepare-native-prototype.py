#!/usr/bin/env python3
"""Prepare isolated Fedora SRPM rebuild inputs; never install or publish them."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('srpm', type=Path)
parser.add_argument('--topdir', type=Path, required=True)
args = parser.parse_args()
top = args.topdir.resolve()
if not top.is_relative_to(ROOT / '.work') or top.exists():
    parser.error('--topdir must be a NEW directory under this repository\'s .work/')
reviewed = json.loads((ROOT / '.roasd/native-prototype-bases.json').read_text())['bases']
digest = hashlib.sha256(args.srpm.read_bytes()).hexdigest()
base = next((base for base in reviewed if base['srpm_sha256'] == digest), None)
if not base:
    parser.error('SRPM differs from inspected Fedora sources; review it first')
version = base['version']
for directory in ('SOURCES', 'SPECS', 'BUILD', 'BUILDROOT', 'RPMS', 'SRPMS'):
    (top / directory).mkdir(parents=True)
converter = subprocess.Popen(['rpm2cpio', str(args.srpm.resolve())], stdout=subprocess.PIPE)
extractor = subprocess.run(['cpio', '-idm', '--quiet', '--no-absolute-filenames'],
                           stdin=converter.stdout, cwd=top / 'SOURCES', check=True)
converter.stdout.close()
if converter.wait():
    raise SystemExit('rpm2cpio failed')
archive = top / f'SOURCES/systemsettings-{version}.tar.xz'
if hashlib.sha256(archive.read_bytes()).hexdigest() != base['source_tar_sha256']:
    raise SystemExit('Unexpected upstream source archive')
spec = (top / 'SOURCES/plasma-systemsettings.spec').read_text()
if 'Patch' in spec.split('%changelog')[0] or 'Release: 1%{?dist}' not in spec:
    raise SystemExit('Unexpected Fedora patch series or release: manual review required')
spec = spec.replace('Release: 1%{?dist}', 'Release: 1%{?dist}.roasdproto1', 1)
spec = spec.replace('BuildRequires: desktop-file-utils',
                    '# ISOLATED DEVELOPMENT PROTOTYPE — NOT A PRODUCTION PACKAGE\n'
                    'Patch0: 0001-opt-in-native-qml-shell.patch\n\n'
                    'BuildRequires: desktop-file-utils', 1)
(top / 'SPECS/plasma-systemsettings.spec').write_text(spec)
shutil.copy2(ROOT / 'patches/systemsettings/0001-opt-in-native-qml-shell.patch', top / 'SOURCES')
shutil.copy2(ROOT / 'prototypes/native-skin/ro-systemsettings-native-skin-prototype.spec', top / 'SPECS')
with tarfile.open(top / 'SOURCES/ro-systemsettings-native-skin-prototype-0.0.1.tar.gz', 'w:gz') as archive:
    # Explicit allowlist: none of the 49 legacy provenance blockers enters this RPM.
    for name in ('Main.qml', 'tr.po'):
        archive.add(ROOT / 'prototypes/native-skin' / name,
                    arcname='ro-systemsettings-native-skin-prototype-0.0.1/' + name)
    archive.add(ROOT / 'LICENSE', arcname='ro-systemsettings-native-skin-prototype-0.0.1/LICENSE')
print(top)
