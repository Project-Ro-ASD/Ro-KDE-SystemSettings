#!/usr/bin/env python3
"""Manual diagnostic of unmodified KDE, never a visual acceptance gate.

Uses an isolated D-Bus session and temporary user directories. Does not install
packages or change user settings. Logs are deliberately kept for failed runs.
"""
import argparse
import json
import os
from pathlib import Path
import signal
import shutil
import subprocess
import tempfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', type=Path, required=True)
parser.add_argument('--seconds', type=float, default=5)
args = parser.parse_args()
if not shutil.which('dbus-run-session'):
    parser.error('dbus-run-session is required; install dbus-daemon in the disposable test environment')
if not 1 <= args.seconds <= 30:
    parser.error('--seconds must be between 1 and 30')
root = Path(__file__).resolve().parents[1]
args.output.mkdir(parents=True, exist_ok=True)
results = []
for name, style, extra in (
    ('stock', None, []),
    ('qss', None, ['-stylesheet', str(root / 'overrides/theme/tabs.qss')]),
    ('quick-basic', 'Basic', []),
    ('quick-fusion', 'Fusion', []),
):
    with tempfile.TemporaryDirectory(prefix='ro-native-probe-') as temporary:
        env = os.environ.copy()
        for key in ('SESSION_MANAGER', 'QT_STYLE_OVERRIDE', 'QT_QUICK_CONTROLS_STYLE',
                    'QML_IMPORT_PATH', 'QML2_IMPORT_PATH', 'LD_PRELOAD'):
            env.pop(key, None)
        env.update(HOME=temporary, XDG_CONFIG_HOME=temporary + '/config',
                   XDG_DATA_HOME=temporary + '/data', XDG_CACHE_HOME=temporary + '/cache',
                   XDG_STATE_HOME=temporary + '/state', XDG_RUNTIME_DIR=temporary + '/runtime',
                   XDG_DATA_DIRS='/usr/local/share:/usr/share',
                   QT_QPA_PLATFORM='offscreen', QT_QUICK_BACKEND='software',
                   QML_IMPORT_TRACE='1', KDE_DEBUG='1')
        Path(env['XDG_RUNTIME_DIR']).mkdir(mode=0o700)
        if style:
            env['QT_QUICK_CONTROLS_STYLE'] = style
        command = ['dbus-run-session', '--', '/usr/bin/systemsettings', *extra]
        with (args.output / (name + '.log')).open('w') as log:
            process = subprocess.Popen(command, env=env, stdout=log,
                                       stderr=subprocess.STDOUT, start_new_session=True)
            try:
                code = process.wait(timeout=args.seconds)
                status = 'EARLY_EXIT'
            except subprocess.TimeoutExpired:
                # Being alive does not prove the application reached its event
                # loop: a portal or system-bus request may still be blocking.
                status = 'PROCESS_SURVIVED'
                code = None
            finally:
                # All processes in this group belong to this disposable session.
                try:
                    os.killpg(process.pid, signal.SIGTERM)
                except ProcessLookupError:
                    pass
                try:
                    process.wait(timeout=3)
                except subprocess.TimeoutExpired:
                    os.killpg(process.pid, signal.SIGKILL)
                    process.wait()
        trace = (args.output / (name + '.log')).read_text()
        results.append(dict(mode=name, command=command, status=status, returncode=code,
                            stock_root_seen='qrc:/qt/qml/org/kde/systemsettings/Main.qml' in trace,
                            real_plasma_acceptance='NOT VERIFIED',
                            visual_activation='NOT VERIFIED', performance='NOT MEASURED'))
(args.output / 'runtime.json').write_text(json.dumps(results, indent=2) + '\n')
print(json.dumps(results, indent=2))
