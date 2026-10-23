#!/usr/bin/env python3
"""Headless process baseline only. Run inside a disposable container under dbus-run-session.

This does NOT measure real cold starts, physical window visibility or interaction latency.
No settings changed; each trial uses an isolated profile. Crashes are recorded as FAIL.
"""
import argparse
import json
import os
from pathlib import Path
import subprocess
import tempfile
import time
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', required=True)
parser.add_argument('--trials', type=int, default=3)
args = parser.parse_args()
assert Path('/run/.containerenv').exists() or Path('/.dockerenv').exists(), 'Use disposable container'
records = []
with tempfile.TemporaryDirectory(prefix='ro-perf-') as tmp:
    Path(tmp).chmod(0o700)
    env = dict(os.environ, QT_QPA_PLATFORM='offscreen', QT_QUICK_BACKEND='software', XDG_RUNTIME_DIR=tmp)
    for key in ('DISPLAY', 'WAYLAND_DISPLAY', 'LD_PRELOAD', 'QML_IMPORT_PATH', 'QML2_IMPORT_PATH'):
        env.pop(key, None)
    for program in ('/usr/bin/systemsettings', '/usr/bin/ro-systemsettings'):
        for trial in range(args.trials):
            profile = f'{tmp}/{Path(program).name}-{trial}'
            env.update(XDG_CONFIG_HOME=profile+'/config', XDG_CACHE_HOME=profile+'/cache', XDG_DATA_HOME=profile+'/data')
            start = time.monotonic()
            with tempfile.TemporaryFile() as log:
                process = subprocess.Popen([program], env=env, stdout=log, stderr=log)
                time.sleep(3)
                record = dict(program=program, trial=trial, sample_after_ms=round((time.monotonic()-start)*1000))
                if process.poll() is None:
                    fields = dict(line.split(':', 1) for line in Path(f'/proc/{process.pid}/smaps_rollup').read_text().splitlines()[1:])
                    record.update(rss_kib=int(fields['Rss'].split()[0]), pss_kib=int(fields['Pss'].split()[0]))
                    stat = Path(f'/proc/{process.pid}/stat').read_text().split(') ',1)[1].split()
                    record['cpu_seconds'] = (int(stat[11])+int(stat[12])) / os.sysconf('SC_CLK_TCK')
                    process.terminate()
                    try: process.wait(timeout=10)
                    except subprocess.TimeoutExpired: process.kill(); process.wait(); record['forced_kill'] = True
                    record['status'] = 'PASS' if not record.get('forced_kill') else 'FAIL'
                else: record.update(status='FAIL', exit=process.returncode)
                record['process_gone'] = not Path(f'/proc/{process.pid}').exists()
                log.seek(0); record['log'] = log.read().decode(errors='replace')
                records.append(record)
versions = subprocess.check_output(['rpm','-q','plasma-systemsettings','kf6-kcmutils','qt6-qtbase'], text=True).splitlines()
Path(args.output).write_text(json.dumps(dict(conditions='offscreen/software, isolated profiles, 3s sample, no cold-cache eviction', versions=versions,
    unmeasured=['physical first window','cold-start','warm-start','KCM interactive latency','category latency'], records=records), indent=2)+'\n')
print(args.output)
