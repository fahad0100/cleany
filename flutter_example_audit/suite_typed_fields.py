import json
import zipfile
from audit_runner import APP,AUDIT,run_case,source_snapshot

run_case('51_all_response_field_types', ['1','typed_fields','2','1','2','7','id:string:id','n','price:double:price','n','enabled:bool:enabled','n','createdAt:datetime:created_at','n','tags:list<string>:tags','y','counts:list<int>:counts','y','quantity:int:quantity','n','1','0'], contains=['Completed. Staged generation and analysis passed.'])
run_case('52_doctor_after_all_field_types',['10','0'],contains=['No repairable issues found.'])
with zipfile.ZipFile(AUDIT/'snapshots/final_generated_before_demo.zip','w',zipfile.ZIP_DEFLATED) as archive:
    for path in source_snapshot(): archive.write(APP/path,path)
(AUDIT/'snapshots/final_generated_registry.json').write_text((APP/'.cleany/features.json').read_text())
print('ALL FIELD TYPES VERIFIED',flush=True)
