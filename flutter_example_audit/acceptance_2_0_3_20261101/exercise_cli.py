from pathlib import Path
import subprocess,json,time,shutil,tarfile
ROOT=Path(__file__).resolve().parents[2];APP=ROOT/'flutter_example';OUT=Path(__file__).resolve().parent
DART='/opt/homebrew/share/flutter/bin/cache/dart-sdk/bin/dart'
results=json.loads((OUT/'cli_results.json').read_text()) if (OUT/'cli_results.json').exists() else []
def entries():return json.loads((APP/'.cleany/features.json').read_text())['features']
def case(label,answers):
 for attempt in range(1,3):
  start=time.monotonic();r=subprocess.run([DART,'--suppress-analytics','run','cleany'],cwd=APP,input='\n'.join(answers+['0'])+'\n',capture_output=True,text=True,timeout=900)
  text=r.stdout+r.stderr;(OUT/'logs'/f'{label}_{attempt}.log').write_text(text)
  if r.returncode==0 and 'Operation stopped:' not in text:
   result={'case':label,'seconds':round(time.monotonic()-start,3),'status':'passed'};results.append(result);print(json.dumps(result),flush=True);(OUT/'cli_results.json').write_text(json.dumps(results,indent=2)+'\n');return text
  if 'Project inputs changed during validation' in text and attempt<2:continue
  print(text[-5000:],flush=True);raise RuntimeError(label)
if __name__=='__main__':
 case('doctor',['11','1'])
 registry=json.loads((APP/'.cleany/features.json').read_text());assert registry['template_version']=='2.0.3'
 post=OUT/'post_doctor';shutil.copytree(APP/'lib',post/'lib',dirs_exist_ok=True);(post/'.cleany').mkdir(parents=True,exist_ok=True);shutil.copyfile(APP/'.cleany/features.json',post/'.cleany/features.json')
 features=[e for e in entries() if e['kind']=='feature'];idx=next(i+1 for i,e in enumerate(features) if e['name']=='products')
 case('existing_feature_entity',['3',str(idx),'audit_product_entity','2','','1'])
 case('alternate_existing_entity',['3',str(idx),'audit_users_entity','2','UsersEntity','1'])
 reg=json.loads((APP/'.cleany/features.json').read_text());operations=next(e for e in reg['features'] if e['name']=='products')['use_cases'];assert operations[-2]['entity_type']=='ProductsEntity' and operations[-1]['entity_type']=='UsersEntity';assert operations[-1]['mapping_pending']
 case('clean_local_cache',['13','1','1'])
 case('component_cold',['2','audit_label','3','1','1'])
 case('component_warm',['2','audit_caption','3','1','1'])
 fields=[('id','string','n'),('count','int','n'),('price','double','n'),('enabled','bool','n'),('createdAt','datetime','n'),('values','list','n'),('tags','list<string>','n'),('integers','list<int>','n'),('numbers','list<num>','n'),('rows','list<map<string,dynamic>>','n'),('metadata','map<string,dynamic>','y'),('selection','set','n'),('payload','dynamic','n')]
 answers=['1','contract_sample','2','1','2',str(len(fields))]
 for name,kind,nullable in fields:answers += [f'{name}:{kind}:{name}',nullable]
 answers+=['1'];case('feature_all_field_types',answers)
 case('component_cubit',['2','audit_counter','1','1','1'])
 case('lists',['6','7'])
 (OUT/'phase1_ready').write_text('ready\n')
