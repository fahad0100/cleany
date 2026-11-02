from exercise_cli import *
# Retain the exact generated sources and acceptance test for inspection.
with tarfile.open(OUT/'generated_acceptance_sources.tar.gz','w:gz') as archive:
 for folder in ['lib','test']:
  archive.add(APP/folder,arcname=folder)
 archive.add(APP/'.cleany/features.json',arcname='.cleany/features.json')
test=APP/'test/cleany_203_acceptance_test.dart'
shutil.copyfile(test,OUT/'cleany_203_acceptance_test.dart.txt');test.unlink()
all_entries=entries();index=next(i+1 for i,e in enumerate(all_entries) if e['name']=='audit_label')
case('rename_and_move_component',['8',str(index),'audit_tag','lib/shared/components','1'])
index=next(i+1 for i,e in enumerate([e for e in entries() if e['kind']=='feature']) if e['name']=='contract_sample')
case('remove_sample_feature',['4',str(index),'1'])
for name in ['audit_tag','audit_caption','audit_counter']:
 index=next(i+1 for i,e in enumerate([e for e in entries() if e['kind']=='component']) if e['name']==name)
 case('remove_'+name,['5',str(index),'1'])
(OUT/'ready_to_restore_operations').write_text('ready\n')
