#!/usr/bin/env python3
"""Run one instrumented ORIGINAL KDE application case in a disposable container."""
import argparse
import json
import os
from pathlib import Path
import signal
import subprocess
import tempfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('executable', type=Path)
parser.add_argument('--output', type=Path, required=True)
parser.add_argument('--expect', choices=('ro', 'stock'), required=True)
parser.add_argument('--case', choices=('root', 'ui'), default='root')
parser.add_argument('--opt-in', choices=('0', '1'), default='1')
parser.add_argument('--platform', choices=('offscreen', 'wayland'), default='offscreen')
parser.add_argument('--platform-theme', default='generic')
parser.add_argument('--controls-style', default='Basic')
parser.add_argument('--language', choices=('en', 'tr'), default='en')
args = parser.parse_args()
if not Path('/run/.containerenv').exists() and not Path('/.dockerenv').exists():
    parser.error('Disposable container required')
output = args.output.resolve()
output.mkdir(parents=True, exist_ok=True)
with tempfile.TemporaryDirectory(prefix='ro-native-case-') as temporary:
    env = dict(os.environ)
    for key in ('LD_PRELOAD', 'QML_IMPORT_PATH', 'QML2_IMPORT_PATH', 'SESSION_MANAGER'):
        env.pop(key, None)
    env.update(HOME=temporary, XDG_CONFIG_HOME=temporary + '/config',
               XDG_DATA_HOME=temporary + '/data', XDG_CACHE_HOME=temporary + '/cache',
               XDG_STATE_HOME=temporary + '/state', XDG_RUNTIME_DIR=temporary + '/runtime',
               XDG_DATA_DIRS='/usr/local/share:/usr/share',
               QT_QPA_PLATFORM=args.platform, QT_QUICK_BACKEND='software',
               QT_QPA_PLATFORMTHEME=args.platform_theme, QT_QUICK_CONTROLS_STYLE=args.controls_style,
               QT_LOGGING_RULES='*.debug=false;*.info=true',
               QT_FORCE_STDERR_LOGGING='1',
               RO_SYSTEMSETTINGS_SKIN=args.opt_in, RO_NATIVE_TEST_CASE=args.case,
               RO_NATIVE_TEST_EXPECT=args.expect,
               RO_NATIVE_TEST_LANGUAGE=args.language,
               RO_NATIVE_TEST_RESULT=str(output / 'checks.json'),
               RO_NATIVE_TEST_SCREENSHOT=str(output / 'window.png'),
               KDE_DEBUG='1', LC_ALL='en_US.UTF-8')
    Path(env['XDG_RUNTIME_DIR']).mkdir(mode=0o700)
    command = ['dbus-run-session', '--', str(args.executable.resolve())]
    with (output / 'runtime.log').open('w') as log:
        process = subprocess.Popen(command, env=env, stdout=log,
                                   stderr=subprocess.STDOUT, start_new_session=True)
        try:
            code = process.wait(timeout=45)
        except subprocess.TimeoutExpired:
            code = 124
        finally:
            try:
                os.killpg(process.pid, signal.SIGTERM)
            except ProcessLookupError:
                pass
            try:
                process.wait(timeout=3)
            except subprocess.TimeoutExpired:
                os.killpg(process.pid, signal.SIGKILL)
                process.wait()
    config = Path(temporary + '/config/kdeglobals')
    if config.exists():
        (output / 'kdeglobals').write_bytes(config.read_bytes())
    (output / 'execution.json').write_text(json.dumps(dict(command=command,
        case=args.case, expected_root=args.expect, opt_in=args.opt_in, exit_code=code,
        platform=args.platform, theme=args.platform_theme, controls=args.controls_style,
        language=args.language, real_plasma_acceptance='NOT VERIFIED'), indent=2) + '\n')
print(f'{output}: exit {code}', flush=True)
raise SystemExit(code)
