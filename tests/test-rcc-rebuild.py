#!/usr/bin/env python3
"""A QML-only edit must regenerate the installed binary RCC in an incremental build."""
import hashlib
from pathlib import Path
import shutil
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix='ro-rcc-') as directory:
    source, build = Path(directory) / 'source', Path(directory) / 'build'
    source.mkdir()
    shutil.copy(root / 'CMakeLists.txt', source)
    shutil.copytree(root / 'overrides', source / 'overrides')
    subprocess.run(['cmake', '-S', str(source), '-B', str(build)], check=True)
    command = ['cmake', '--build', str(build), '--target', 'generate_rcc']
    subprocess.run(command, check=True)
    resource = build / 'overrides.rcc'
    before = hashlib.sha256(resource.read_bytes()).hexdigest()
    qml = source / 'overrides/qml/systemsettings/Main.qml'
    qml.write_text(qml.read_text() + '\n// incremental resource rebuild probe\n')
    subprocess.run(command, check=True)
    after = hashlib.sha256(resource.read_bytes()).hexdigest()
    assert after != before, 'QML edit left a stale binary resource'
    subprocess.run(command, check=True)
    assert hashlib.sha256(resource.read_bytes()).hexdigest() == after
print('QML-only incremental RCC rebuild PASS')
