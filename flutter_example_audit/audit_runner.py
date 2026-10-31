#!/usr/bin/env python3
"""Exercise the installed local executable through its real numbered CLI."""
import hashlib
import json
import pathlib
import subprocess
import sys
import time

ROOT = pathlib.Path(__file__).resolve().parent.parent
APP = ROOT / 'flutter_example'
AUDIT = pathlib.Path(__file__).resolve().parent
DART = '/opt/homebrew/share/flutter/bin/cache/dart-sdk/bin/dart'
IGNORED = {'.git', '.dart_tool', '.idea', '.gradle', '.symlinks', '.cleany', 'build', 'Pods', 'ephemeral'}

def source_snapshot():
    result = {}
    def visit(folder):
        for file in folder.iterdir():
            if file.name in IGNORED or file.is_symlink():
                continue
            if file.is_dir():
                visit(file)
            elif file.is_file():
                result[str(file.relative_to(APP))] = hashlib.sha256(file.read_bytes()).hexdigest()
    visit(APP)
    return result

def run_case(name, answers, expected=0, contains=()):
    before = source_snapshot()
    started = time.monotonic()
    run = subprocess.run([DART, 'run', 'cleany'], input='\n'.join(answers) + '\n',
                         text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                         cwd=APP, timeout=900)
    duration = round(time.monotonic()-started, 2)
    after = source_snapshot()
    changed = sorted(path for path in before.keys() | after.keys() if before.get(path) != after.get(path))
    log = AUDIT / 'logs' / f'{name}.log'
    log.write_text(run.stdout)
    result = {'case': name, 'answers': answers, 'exit_code': run.returncode,
              'expected_exit': expected, 'duration_seconds': duration,
              'changed_files': changed, 'log': str(log.relative_to(AUDIT)),
              'passed': run.returncode == expected and all(text in run.stdout for text in contains)}
    with (AUDIT / 'results.jsonl').open('a') as output:
        output.write(json.dumps(result) + '\n')
    print(json.dumps({key: result[key] for key in ['case', 'exit_code', 'duration_seconds', 'passed']}) + f' changed={len(changed)}', flush=True)
    if not result['passed']:
        print(run.stdout[-6500:])
        raise SystemExit(1)
    return result

if __name__ == '__main__':
    name, answers_json = sys.argv[1:3]
    run_case(name, json.loads(answers_json))
