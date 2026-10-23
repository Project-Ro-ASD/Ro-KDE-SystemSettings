#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 Ro-ASD contributors
# SPDX-License-Identifier: GPL-3.0-or-later
"""Trace the actual Ro ELF in a disposable offscreen/private-bus session.

This proves startup does not execute stock System Settings. It does not cover
explicit stock fallback or upstream KCMLauncher links, which retain upstream behavior.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('program', type=Path)
parser.add_argument('output', type=Path)
args = parser.parse_args()
assert Path('/run/.containerenv').exists() or Path('/.dockerenv').exists(), 'Disposable container required'
program = args.program.resolve()
with program.open('rb') as stream:
    assert stream.read(4) == b'\x7fELF', 'Expected independent ELF, not a wrapper'
args.output.mkdir(parents=True, exist_ok=True)
trace = args.output.resolve() / 'ro-execve.log'
with tempfile.TemporaryDirectory(prefix='ro-independent-trace-') as tmp:
    Path(tmp).chmod(0o700)
    env = dict(os.environ, QT_QPA_PLATFORM='offscreen', QT_QUICK_BACKEND='software',
               XDG_RUNTIME_DIR=tmp, XDG_CONFIG_HOME=tmp+'/config', XDG_CACHE_HOME=tmp+'/cache', XDG_DATA_HOME=tmp+'/data')
    for key in ('DISPLAY', 'WAYLAND_DISPLAY', 'DBUS_SESSION_BUS_ADDRESS', 'LD_PRELOAD', 'QML_IMPORT_PATH', 'QML2_IMPORT_PATH', 'QT_PLUGIN_PATH'):
        env.pop(key, None)
    result = subprocess.run(['dbus-run-session', '--', 'strace', '-f', '-e', 'trace=execve', '-o', str(trace),
                             str(program), '--quit-after', '1200'], env=env, capture_output=True, text=True, timeout=20)
    (args.output/'ro-startup.log').write_text(result.stdout + result.stderr)
    assert result.returncode == 0, result.stderr
    lines = trace.read_text()
    assert f'execve("{program}"' in lines
    assert 'execve("/usr/bin/systemsettings"' not in lines
    assert 'execve("/bin/systemsettings"' not in lines
    assert 'systemsettings_override' not in lines
    discovery = subprocess.run([str(program), '--list'], env=env, capture_output=True, text=True, timeout=15)
    assert discovery.returncode == 0, discovery.stderr
    modules = json.loads(discovery.stdout)
    assert modules
    report = dict(result='PASS', elf_sha256=hashlib.sha256(program.read_bytes()).hexdigest(), module_count=len(modules),
                  stock_executed_during_ro_startup=False, scope='offscreen startup/discovery, not physical Plasma/Polkit or cross-module links')
    (args.output/'independent-executable.json').write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps(report))
