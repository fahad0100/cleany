import json
import os
import shutil
import signal
import subprocess
import time
from audit_runner import APP, AUDIT, DART, run_case, source_snapshot


def record(name, started, code, expected, passed, **details):
    result={'case':name,'duration_seconds':round(time.monotonic()-started,2),'exit_code':code,'expected_exit':expected,'passed':passed,**details}
    with (AUDIT/'results.jsonl').open('a') as output: output.write(json.dumps(result)+'\n')
    print(json.dumps(result),flush=True)
    assert passed

baseline=source_snapshot()
baseline_registry=(APP/'.cleany/features.json').read_bytes()
safe_original=(APP/'lib/app/di/injection.dart').read_bytes()
journal=APP/'.cleany/transaction'
log=AUDIT/'logs/31_interrupt_commit.log'
started=time.monotonic()
with log.open('w') as output:
    process=subprocess.Popen([DART,'run','cleany'],cwd=APP,stdin=subprocess.PIPE,stdout=output,stderr=subprocess.STDOUT,text=True,start_new_session=True)
    process.stdin.write('1\nrecovery_probe\n1\n1\n1\n1\n0\n');process.stdin.close()
    while process.poll() is None and time.monotonic()-started<600:
        states=journal/'states.jsonl'
        if states.exists():
            events=[json.loads(line) for line in states.read_text().splitlines() if line]
            applied=[event['path'] for event in events if event['state']=='applied']
            if len(applied)>=2 and 'lib/app/di/injection.dart' in applied:
                manifest=json.loads((journal/'manifest.json').read_text())
                target=applied[0]; safe='lib/app/di/injection.dart'
                expected=(APP/target).read_bytes()
                os.killpg(process.pid,signal.SIGKILL)
                process.wait(timeout=15)
                break
        time.sleep(.003)
    else:
        if process.poll() is None: os.killpg(process.pid,signal.SIGKILL)
        raise RuntimeError('Failed to interrupt a partially committed operation.')
record('31_interrupt_commit',started,process.returncode,-9,process.returncode==-9 and journal.exists(),partial_applied_files=applied)
# Lose the primary manifest while retaining the independent snapshot.
(journal/'manifest.json').unlink()
manual=expected+b'\n// Developer edit deliberately preserved by recovery.\n'
(APP/target).write_bytes(manual)
run_case('32_recovery_secondary_manifest_conflict',['8','1','2','0'],expected=1,contains=['Safe files were restored','preserved'])
assert (APP/target).read_bytes()==manual
assert (APP/safe).read_bytes()==safe_original
assert (journal/'manifest.backup.json').exists()
(APP/target).write_bytes(expected)
run_case('33_recovery_resolved_conflict',['8','1','0'],contains=['Recovery completed.'])
assert source_snapshot()==baseline
assert (APP/'.cleany/features.json').read_bytes()==baseline_registry
assert not journal.exists()

(journal/'backups').mkdir(parents=True)
(journal/'backups/0').write_text('Unknown-state backup: keep this copy.')
run_case('34_recovery_unknown_state_keeps_backups',['8','1','2','0'],expected=1,contains=['All backups were preserved'])
assert (journal/'backups/0').read_text()=='Unknown-state backup: keep this copy.'
faults=AUDIT/'fault_fixtures';faults.mkdir(exist_ok=True)
shutil.move(str(journal),str(faults/'unknown_state_recovery'))

# Cooperatively interrupt a builder via the actual Cleany process, not its launcher.
log=AUDIT/'logs/35_cancel_build.log'
started=time.monotonic()
with log.open('w') as output:
    process=subprocess.Popen([DART,'run','cleany'],cwd=APP,stdin=subprocess.PIPE,stdout=output,stderr=subprocess.STDOUT,text=True,start_new_session=True)
    process.stdin.write('1\ncancel_probe\n1\n1\n1\n1\n2\n0\n');process.stdin.close()
    while process.poll() is None and time.monotonic()-started<600:
        if 'dart run build_runner build' in log.read_text():
            metadata=json.loads((APP/'.cleany/lock').read_text())
            os.kill(metadata['pid'],signal.SIGINT)
            break
        time.sleep(.03)
    else:
        if process.poll() is None: os.killpg(process.pid,signal.SIGKILL)
        raise RuntimeError('Builder cancellation was not reached.')
    process.wait(timeout=30)
record('35_cancel_build',started,process.returncode,0,process.returncode==0 and source_snapshot()==baseline,log='logs/35_cancel_build.log')
assert not (APP/'lib/features/cancel_probe').exists()
assert not journal.exists()
(APP/'.cleany/lock').write_text('999999999')
run_case('36_dead_legacy_lock_reclaimed',['8','1','0'],contains=['Recovery completed.'])
assert not (APP/'.cleany/lock').exists()
print('FAULT SCENARIOS VERIFIED',flush=True)
