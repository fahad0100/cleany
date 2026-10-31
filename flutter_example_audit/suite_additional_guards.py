import json
import os
import subprocess
from audit_runner import APP,AUDIT,DART,ROOT,run_case

for name,count_values,count in [('56_invalid_count_and_arabic_count',['0','31','١'],1),('57_maximum_30_fields',['30'],30)]:
 answers=['1','count_limit_probe','1','1','2',*count_values]
 for i in range(count):answers += [f'field{i+1}:string:key{i+1}','n']
 answers+=['2','0']
 result=run_case(name,answers,contains=['Cancelled. No files were changed.'])
 assert not result['changed_files']
lock=APP/'.cleany/lock'
try:
 lock.write_text(str(os.getpid()))
 result=run_case('58_live_legacy_lock_refused',['8','1','2','0'],expected=1,contains=['legacy Cleany process is still running'])
 assert lock.read_text()==str(os.getpid()) and not result['changed_files']
finally:
 lock.unlink(missing_ok=True)
ids=json.loads(subprocess.check_output([DART,'run',str(AUDIT/'inspect_native.dart'),str(APP)],cwd=ROOT,text=True))
answers=['7']
if len(ids)>1:answers += [str(ids.index('com.example.testCleanyProject')+1)]
answers += ['1','2','0']
result=run_case('59_reinitialize_existing_project_refused',answers,expected=1,contains=['Already initialized'])
assert not result['changed_files']
print('ADDITIONAL GUARDS VERIFIED',flush=True)
