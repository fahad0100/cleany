from pathlib import Path
import subprocess,json,time,sys,fcntl
ROOT=Path(__file__).resolve().parents[2];APP=ROOT/'flutter_example';OUT=Path(__file__).resolve().parent
# Flutter regenerates platform registrants for the shared project. Serialize native commands.
lock=(OUT/'native_build.lock').open('a');fcntl.flock(lock,fcntl.LOCK_EX)
platform=sys.argv[1];results=[]
def run(label,args,timeout=900):
 start=time.monotonic()
 with (OUT/'logs'/f'{label}.log').open('w') as log:
  result=subprocess.run(['flutter',*args],cwd=APP,stdout=log,stderr=subprocess.STDOUT,timeout=timeout)
 if result.returncode: print((OUT/'logs'/f'{label}.log').read_text()[-5000:],flush=True);raise RuntimeError(label)
 item={'operation':label,'seconds':round(time.monotonic()-start,3),'status':'passed'};results.append(item);print(json.dumps(item),flush=True);(OUT/f'{platform}_results.json').write_text(json.dumps(results,indent=2)+'\n')
if platform=='ios':
 device='189091C8-6638-4DAD-94BA-0C39D8BB606C'
 run('live_flow_dev',['drive','--driver=test_driver/store_driver.dart','--target=integration_test/store_flow_test.dart','--flavor','dev','-d',device,'--dart-define=CAPTURE_SCREENSHOTS=true'])
 for flavor in ['uat','prod']:
  run('build_ios_'+flavor,['build','ios','--debug','--simulator','--flavor',flavor,'-t',f'lib/main_{flavor}.dart'])
  run('launch_ios_'+flavor,['run','--no-resident','--flavor',flavor,'-t',f'lib/main_{flavor}.dart','-d',device])
 run('leave_dev_running',['run','--no-resident','--flavor','dev','-t','lib/main_dev.dart','-d',device])
else:
 for flavor in ['dev','uat','prod']:
  run('build_android_'+flavor,['build','apk','--debug','--flavor',flavor,'-t',f'lib/main_{flavor}.dart'])
 run('build_android_prod_release',['build','apk','--release','--flavor','prod','-t','lib/main_prod.dart'])
