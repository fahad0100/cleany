from pathlib import Path
import json,subprocess,time
ROOT=Path(__file__).resolve().parents[2];APP=ROOT/'flutter_example';AUDIT=ROOT/'flutter_example_audit/store_demo'
DART='/opt/homebrew/share/flutter/bin/cache/dart-sdk/bin/dart'
def entries():return json.loads((APP/'.cleany/features.json').read_text())['features']
def case(label,answers,check):
 if check(): print(label,'already exists',flush=True);return
 for attempt in range(1,4):
  start=time.monotonic();r=subprocess.run([DART,'--suppress-analytics','run','cleany'],cwd=APP,input='\n'.join(answers+['0'])+'\n',text=True,capture_output=True,timeout=600)
  (AUDIT/'logs'/f'{label}_{attempt}.log').write_text(r.stdout+r.stderr)
  if check():print(label,'passed',round(time.monotonic()-start,1),'s',flush=True);return
  if 'Project inputs changed during validation' not in r.stdout+r.stderr:
   print((r.stdout+r.stderr)[-3000:],flush=True);raise RuntimeError(label)
  print(label,'retry after input change',flush=True)
 raise RuntimeError(label+' failed 3 attempts')
case('feature_products',['1','products','1','1','1','1'],lambda:any(e['name']=='products' for e in entries()))
for name,state in [('status_panel','3'),('quantity_stepper','1')]:
 case('component_'+name,['2',name,state,'1','1'],lambda n=name:any(e['name']==n for e in entries()))
for feature,name,kind in [('products','get_featured_product','2'),('carts','create_cart','2'),('carts','delete_cart','1'),('users','get_user_profile','2'),('auth','sign_in','2'),('auth','sign_out','1')]:
 es=[e for e in entries() if e['kind']=='feature'];idx=next(i+1 for i,e in enumerate(es) if e['name']==feature)
 case('use_case_'+name,['3',str(idx),name,kind,'1'],lambda f=feature,n=name:any(e['name']==f and any(u['name']==n for u in e.get('use_cases',[])) for e in entries()))
print('ALL REQUESTED CLI SCAFFOLDS COMPLETE',flush=True)
