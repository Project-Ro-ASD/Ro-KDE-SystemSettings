#!/usr/bin/env python3
"""The application has its own executable/desktop identity and no environment wrapper."""
from pathlib import Path
import re
root = Path(__file__).resolve().parents[1]
cmake = (root / 'CMakeLists.txt').read_text()
main = (root / 'src/main.cpp').read_text()
desktop = (root / 'packaging/fedora/ro-systemsettings.desktop').read_text()
assert 'qt_add_executable(ro-systemsettings' in cmake
assert 'setApplicationName(QStringLiteral("ro-systemsettings"))' in main
assert 'setDesktopFileName(QStringLiteral("ro-systemsettings"))' in main
assert re.search('^Exec=ro-systemsettings$', desktop, re.M)
assert not (root / 'bin/ro-systemsettings').exists()
for path in (root / 'src').rglob('*'):
    if path.is_file():
        for forbidden in ('LD_PRELOAD', 'qputenv(', 'setenv(', 'org.kde.systemsettings'):
            assert forbidden not in path.read_text(), (path, forbidden)
print('Executable, desktop identity and no-environment-injection boundary PASS')
