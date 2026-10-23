#!/usr/bin/env python3
"""Disposable event-loop/QML/real-KCM and concurrent stock integrity smoke.

No setting is changed. This does not accept visuals, input, Apply/Polkit or scaling.
"""
import json
import os
from pathlib import Path
import subprocess
import tempfile

failures = ('failed to load', 'is not installed', 'is not a type', 'Cannot load library',
            'undefined symbol', 'Segmentation fault', 'QQmlApplicationEngine failed',
            'ReferenceError:', 'TypeError:', 'Binding loop', 'Error loading QML file')
with tempfile.TemporaryDirectory() as tmp:
    Path(tmp).chmod(0o700)
    env = dict(os.environ, QT_QPA_PLATFORM='offscreen', QT_QUICK_BACKEND='software',
               XDG_RUNTIME_DIR=tmp, XDG_CONFIG_HOME=tmp + '/config', XDG_CACHE_HOME=tmp + '/cache', XDG_DATA_HOME=tmp + '/data')
    for key in ('DBUS_SESSION_BUS_ADDRESS', 'WAYLAND_DISPLAY', 'DISPLAY', 'QT_PLUGIN_PATH', 'QML_IMPORT_PATH', 'QML2_IMPORT_PATH', 'LD_PRELOAD'):
        env.pop(key, None)
    def run(arguments, expected=0):
        result = subprocess.run(['dbus-run-session', '--', *arguments], env=env,
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, timeout=30)
        print(arguments, result.returncode, result.stderr, flush=True)
        assert result.returncode == expected, (arguments, result.returncode, result.stderr)
        for failure in failures:
            assert failure.lower() not in result.stderr.lower(), result.stderr
        return result.stdout
    modules = json.loads(run(['/usr/bin/ro-systemsettings', '--list']))
    assert modules, 'No installed real KCM discovered'
    assert len({m['id'] for m in modules}) == len(modules), 'Duplicate discovery'
    run(['/usr/bin/ro-systemsettings', '--quit-after', '1200'])
    # Installed plugin inventory is evidence; require at least one explicit safe page.
    candidates = ('kcm_qtquicksettings', 'kcm_formats', 'kcm_fonts', 'kcm_colors')
    tested = []
    for module in candidates:
        if module in {m['id'] for m in modules}:
            run(['/usr/bin/ro-systemsettings', module, '--quit-after', '1800'])
            tested.append(module)
    assert tested, 'Install at least one known safe real KCM for the runtime gate'
    print('Real installed KCM load smoke:', tested)
    # Run both on the SAME isolated session bus; independent Ro must stay alive.
    script = '''
import subprocess, time
stock = subprocess.Popen(['/usr/bin/systemsettings'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
ro = subprocess.Popen(['/usr/bin/ro-systemsettings', '--quit-after', '3000'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
try:
    time.sleep(1)
    assert stock.poll() is None, 'Stock exited/crashed (investigate touchpad separately)'
    assert ro.poll() is None, 'Ro forwarded to stock or exited early'
    ro_out, ro_err = ro.communicate(timeout=15)
    assert ro.returncode == 0, ro_err.decode()
finally:
    for process in (ro, stock):
        if process.poll() is None: process.terminate()
        try: out, err = process.communicate(timeout=10)
        except subprocess.TimeoutExpired:
            process.kill(); out, err = process.communicate()
        print(process.args[0], process.returncode, err.decode())
'''
    output = run(['python3', '-c', script])
    for failure in failures:
        assert failure.lower() not in output.lower(), output
    print('Independent QML, metadata discovery, real KCM load, concurrent IPC and process exit PASS')
