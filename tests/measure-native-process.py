#!/usr/bin/env python3
"""Observe actual uninstrumented KDE process RSS/PSS/CPU at a fixed age.

Not a first-frame latency benchmark or a real Plasma acceptance test. Requires
the caller to record provider exclusions and the exact installed dependency set.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import signal
import statistics
import subprocess
import tempfile
import time

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('executable', type=Path)
parser.add_argument('--output', type=Path, required=True)
parser.add_argument('--opt-in', choices=('0', '1'), default='0')
parser.add_argument('--trials', type=int, default=3)
parser.add_argument('--seconds', type=float, default=5)
args = parser.parse_args()
if not Path('/run/.containerenv').exists() and not Path('/.dockerenv').exists():
    parser.error('Disposable container required')
if not 1 <= args.trials <= 5 or not 2 <= args.seconds <= 15:
    parser.error('Use 1–5 trials and 2–15 seconds')
args.output.mkdir(parents=True, exist_ok=True)
executable = args.executable.resolve()

def descendants(pid):
    try:
        children = Path(f'/proc/{pid}/task/{pid}/children').read_text().split()
    except FileNotFoundError:
        return []
    return [int(child) for child in children] + [p for child in children for p in descendants(int(child))]

def sample(pid):
    status = Path(f'/proc/{pid}/status').read_text().splitlines()
    rollup = Path(f'/proc/{pid}/smaps_rollup').read_text().splitlines()
    stat = Path(f'/proc/{pid}/stat').read_text().split(') ', 1)[1].split()
    return dict(rss_kib=int(next(line.split()[1] for line in status if line.startswith('VmRSS:'))),
                pss_kib=int(next(line.split()[1] for line in rollup if line.startswith('Pss:'))),
                cpu_seconds=(int(stat[11]) + int(stat[12])) / os.sysconf('SC_CLK_TCK'))

rows = []
for trial in range(args.trials):
    with tempfile.TemporaryDirectory(prefix='ro-native-measure-') as temporary:
        env = dict(os.environ)
        for key in ('LD_PRELOAD', 'QML_IMPORT_PATH', 'QML2_IMPORT_PATH', 'SESSION_MANAGER'):
            env.pop(key, None)
        env.update(HOME=temporary, XDG_CONFIG_HOME=temporary + '/config',
                   XDG_DATA_HOME=temporary + '/data', XDG_CACHE_HOME=temporary + '/cache',
                   XDG_STATE_HOME=temporary + '/state', XDG_RUNTIME_DIR=temporary + '/runtime',
                   XDG_DATA_DIRS='/usr/local/share:/usr/share', QT_QPA_PLATFORM='offscreen',
                   QT_QUICK_BACKEND='software', QT_QPA_PLATFORMTHEME='generic',
                   QT_QUICK_CONTROLS_STYLE='Basic', QT_LOGGING_RULES='*.debug=false;*.info=true',
                   QT_FORCE_STDERR_LOGGING='1', RO_SYSTEMSETTINGS_SKIN=args.opt_in, KDE_DEBUG='1', LC_ALL='C.UTF-8')
        Path(env['XDG_RUNTIME_DIR']).mkdir(mode=0o700)
        with (args.output / f'trial-{trial}.log').open('w') as log:
            start = time.monotonic()
            process = subprocess.Popen(['dbus-run-session', '--', str(executable)],
                                       env=env, stdout=log, stderr=subprocess.STDOUT, start_new_session=True)
            row = dict(trial=trial, status='NOT MEASURED')
            try:
                time.sleep(args.seconds - 1)
                matching = [pid for pid in descendants(process.pid)
                            if Path(f'/proc/{pid}/exe').exists() and Path(f'/proc/{pid}/exe').resolve() == executable]
                if process.poll() is None and len(matching) == 1:
                    before = sample(matching[0])
                    time.sleep(max(0, args.seconds - (time.monotonic() - start)))
                    after = sample(matching[0])
                    row.update(status='MEASURED', sample_age_seconds=time.monotonic() - start,
                               application_pid_only=True, **after,
                               last_interval_cpu_seconds=after['cpu_seconds'] - before['cpu_seconds'])
                else:
                    row.update(status='EARLY_EXIT_OR_NO_APPLICATION_PID', returncode=process.poll())
            except (FileNotFoundError, ProcessLookupError, StopIteration) as error:
                row.update(status='NOT MEASURED', reason=type(error).__name__)
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
            row['sidebar_markers'] = [line for line in (args.output / f'trial-{trial}.log').read_text().splitlines()
                                      if 'System Settings sidebar:' in line or 'Ro sidebar unavailable' in line]
            rows.append(row)
result = dict(executable=str(executable), executable_sha256=hashlib.sha256(executable.read_bytes()).hexdigest(),
              opt_in=args.opt_in, scope='offscreen/software; application PID only; not UI latency or full-session cost', trials=rows)
if all(row['status'] == 'MEASURED' for row in rows):
    result['median'] = {key: statistics.median(row[key] for row in rows)
                        for key in ('rss_kib', 'pss_kib', 'cpu_seconds', 'last_interval_cpu_seconds')}
else:
    result['median'] = 'NOT MEASURED'
(args.output / 'measurement.json').write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result, indent=2))
