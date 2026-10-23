#!/usr/bin/env python3
"""A QML-only edit must relink the actual executable's embedded resources."""
import hashlib
from pathlib import Path
import shutil
import subprocess
import tempfile
root = Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix='ro-qml-rebuild-') as directory:
    source, build = Path(directory) / 'source', Path(directory) / 'build'
    source.mkdir()
    shutil.copy(root / 'CMakeLists.txt', source)
    shutil.copytree(root / 'src', source / 'src')
    subprocess.run(['cmake', '-S', str(source), '-B', str(build), '-DBUILD_TESTING=OFF'], check=True)
    command = ['cmake', '--build', str(build), '-j2']
    subprocess.run(command, check=True)
    resource = build / 'ro-systemsettings'
    before = hashlib.sha256(resource.read_bytes()).hexdigest()
    qml = source / 'src/qml/Main.qml'
    qml.write_text(qml.read_text().replace('text: "Ro"', 'text: "Ro rebuild probe"'))
    subprocess.run(command, check=True)
    after = hashlib.sha256(resource.read_bytes()).hexdigest()
    assert after != before, 'QML edit left a stale embedded resource'
    subprocess.run(command, check=True)
    assert hashlib.sha256(resource.read_bytes()).hexdigest() == after
print('QML-only executable resource rebuild PASS')
