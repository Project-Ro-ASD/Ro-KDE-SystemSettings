#!/usr/bin/env python3
"""Check the wrapper environment/argv boundary without launching a desktop session."""
import json
import os
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1]
original_env = dict(os.environ)
with tempfile.TemporaryDirectory(prefix='ro-launcher-') as directory:
    tmp = Path(directory)
    data, lib = tmp / 'data', tmp / 'lib'
    data.mkdir()
    lib.mkdir()
    target = tmp / 'systemsettings'
    target.write_text('#!/usr/bin/python3\nimport json, os, sys\n'
                      'print(json.dumps(dict(argv=sys.argv[1:], env=dict(os.environ))))\n')
    target.chmod(0o755)
    wrapper = tmp / 'ro-systemsettings'
    source = (root / 'bin/ro-systemsettings').read_text()
    source = source.replace('/usr/share/ro-kde-systemsettings', str(data))
    source = source.replace('/usr/lib64/ro-kde-systemsettings/qml', str(lib))
    source = source.replace('/usr/bin/systemsettings', str(target))
    wrapper.write_text(source)
    wrapper.chmod(0o755)
    for present, xdg in ((False, None), (True, '/custom/share:/usr/share'),
                         (True, f'/custom/share:{data}:/usr/share')):
        if present:
            (data / 'tabs.qss').write_text('/* fixture */')
        env = {key: value for key, value in os.environ.items()
               if key not in ('XDG_DATA_DIRS', 'LD_PRELOAD', 'QML_IMPORT_PATH', 'QML2_IMPORT_PATH')}
        if xdg is not None:
            env['XDG_DATA_DIRS'] = xdg
        env['QML_IMPORT_PATH'] = '/existing/qml'
        env['QML2_IMPORT_PATH'] = '/existing/qml2'
        args = ['--help', 'argument with spaces', 'literal;$value']
        result = json.loads(subprocess.check_output([str(wrapper), *args], env=env, text=True))
        expected = ['-stylesheet', str(data / 'tabs.qss')] if present else []
        assert result['argv'] == expected + args, result
        child = result['env']
        assert 'LD_PRELOAD' not in child
        assert child['XDG_DATA_DIRS'].split(':').count(str(data)) == 1
        assert child['XDG_DATA_DIRS'].endswith(xdg or '/usr/local/share:/usr/share')
        assert child['QML_IMPORT_PATH'] == f'{lib}:/existing/qml'
        assert child['QML2_IMPORT_PATH'] == f'{lib}:/existing/qml2'
assert dict(os.environ) == original_env
print('Launcher argv, stylesheet, process-local paths and no-preload boundary PASS')
