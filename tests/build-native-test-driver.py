#!/usr/bin/env python3
"""Build original KDE systemsettings with a TEST-ONLY in-process QtTest driver.

This is neither a new settings host nor a distributed executable. Its source is
the pinned original KDE application. The driver is not part of the RPM patch.
"""
import argparse
import io
from pathlib import Path
import subprocess
import tarfile

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--tag', choices=('v6.6.5', 'v6.7.5'), required=True)
parser.add_argument('--patched', action='store_true')
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
if not Path('/run/.containerenv').exists() and not Path('/.dockerenv').exists():
    parser.error('Disposable container required')
output = args.output.resolve()
if not output.is_relative_to(root / '.work') or output.exists():
    parser.error('Output must be a NEW directory under .work/')
source = output / 'source'
source.mkdir(parents=True)
archive = subprocess.check_output(['git', '-C', str(root / '.work/upstream/systemsettings'),
                                   'archive', args.tag])
with tarfile.open(fileobj=io.BytesIO(archive)) as tar:
    tar.extractall(source, filter='data')
if args.patched:
    subprocess.run(['patch', '--fuzz=0', '-p1', '-i',
                    str(root / 'patches/systemsettings/0001-opt-in-native-qml-shell.patch')],
                   cwd=source, check=True)
with (source / 'app/CMakeLists.txt').open('a') as cmake:
    cmake.write('\n# Test build only; never part of the Fedora source patch.\n'
                'find_package(Qt6 REQUIRED COMPONENTS Test)\n'
                f'target_sources(systemsettings PRIVATE "{root}/tests/native-systemsettings-driver.cpp")\n'
                'target_link_libraries(systemsettings PRIVATE Qt::Test)\n')
subprocess.run(['cmake', '-S', str(source), '-B', str(output / 'build'), '-G', 'Ninja',
                '-DCMAKE_BUILD_TYPE=Release', '-DBUILD_TESTING=OFF',
                '-DCMAKE_INSTALL_PREFIX=/usr'], check=True)
subprocess.run(['cmake', '--build', str(output / 'build'), '--target', 'systemsettings', '-j4'], check=True)
print(output / 'build/bin/systemsettings')
