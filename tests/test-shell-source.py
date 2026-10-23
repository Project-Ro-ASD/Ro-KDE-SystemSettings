#!/usr/bin/env python3
"""Independent shell contracts, including negative payload/security boundaries."""
from pathlib import Path
import re
root = Path(__file__).resolve().parents[1]
cmake = (root / 'CMakeLists.txt').read_text()
source = '\n'.join(p.read_text() for p in (root / 'src').rglob('*') if p.is_file())
assert 'URI org.ro.systemsettings' in cmake
assert 'qt_add_executable(ro-systemsettings' in cmake
for forbidden in ('overrides/', 'systemsettings_override', 'CMAKE_DL_LIBS'):
    assert forbidden not in cmake
for forbidden in ('qrc:/qt/qml/org/kde/systemsettings', 'dlsym(', 'LD_PRELOAD', 'qputenv(', 'setenv('):
    assert forbidden not in source
for public in ('KCModuleLoader::loadModule', 'KPluginMetaData::findPlugins',
               'KAuthorized::authorizeControlModule', 'KAuth::Action::AuthorizeOnlyMode',
               'needsSave()', '->defaults()', '->load()', '->save()'):
    assert public in source, public
assert 'job->error() == 0' in source
assert 'if (m_busy) return false' in source
assert not re.search(r'Requires:.*plasma-systemsettings.*[<=>]', (root / 'packaging/fedora/ro-kde-systemsettings.spec').read_text())
assert not re.search(r'^(?:Obsoletes|Conflicts):', (root / 'packaging/fedora/ro-kde-systemsettings.spec').read_text(), re.M)
for p in (root / 'src').rglob('*'):
    if p.is_file(): assert 'SPDX-License-Identifier: GPL-3.0-or-later' in p.read_text(), p
print('Independent shell source/API/namespace/security boundary PASS')
