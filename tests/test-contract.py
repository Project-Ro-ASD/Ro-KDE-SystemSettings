#!/usr/bin/env python3
"""Parse workflows and reject missing producer gates and version drift."""
from pathlib import Path
import re
import subprocess
import yaml

root = Path(__file__).resolve().parents[1]
version = (root / 'VERSION').read_text().strip()
assert re.fullmatch(r'\d+\.\d+\.\d+', version)
spec = (root / 'packaging/fedora/ro-kde-systemsettings.spec').read_text()
assert re.search(r'^Version:\s+' + re.escape(version) + r'$', spec, re.M)
assert f'VERSION {version} LANGUAGES' in (root / 'CMakeLists.txt').read_text()
for file in sorted((root / '.github/workflows').glob('*.yml')):
    workflow = yaml.safe_load(file.read_text())
    assert 'on' in workflow, file
    assert workflow['jobs'], file
    for job in workflow['jobs'].values():
        for step in job.get('steps', []):
            assert not step.get('continue-on-error'), step
            if 'run' in step:
                result = subprocess.run(['bash', '-n'], input=step['run'], text=True)
                assert result.returncode == 0, step
    text = file.read_text()
    for gate in ('tests/test-build-rpm.sh', 'tests/test-bundle.sh', 'tests/run-fedora44.sh'):
        assert gate in text, (file, gate)
    assert 'advisory' not in text
assert 'LD_PRELOAD=' not in (root / 'bin/ro-systemsettings').read_text()
print('Workflow YAML, shell syntax, producer gates and version consistency passed')
