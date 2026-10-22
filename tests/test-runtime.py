#!/usr/bin/env python3
"""Exercise the event loop; --help alone does not load the shell QML."""
import os
from pathlib import Path
import subprocess
import tempfile

with tempfile.TemporaryDirectory() as tmp:
    Path(tmp).chmod(0o700)
    env = dict(os.environ, QT_QPA_PLATFORM='offscreen', QT_QUICK_BACKEND='software',
               XDG_RUNTIME_DIR=tmp, XDG_CONFIG_HOME=tmp + '/config', XDG_CACHE_HOME=tmp + '/cache')
    for program in ('/usr/bin/systemsettings', '/usr/bin/ro-systemsettings'):
        result = subprocess.run(['timeout', '--signal=TERM', '12s', 'dbus-run-session', '--', program],
                                env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        print(program, result.returncode, result.stdout, flush=True)
        assert result.returncode == 124, f'{program} exited before event-loop smoke completed'
        for failure in ('failed to load', 'is not installed', 'is not a type', 'Cannot load library',
                        'undefined symbol', 'Segmentation fault', 'QQmlApplicationEngine failed'):
            assert failure.lower() not in result.stdout.lower(), result.stdout
