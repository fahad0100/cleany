import json
import zipfile
from audit_runner import APP,AUDIT,run_case,source_snapshot

result=run_case('37_cancel_remove_feature',['5','1','2','0'],contains=['Cancelled. No files were changed.'])
assert not result['changed_files']
run_case('38_remove_feature_with_nested_entries',['5','1','1','0'],contains=['Completed. Staged generation and analysis passed.'])
assert not (APP/'lib/modules/dashboard').exists()
registry=json.loads((APP/'.cleany/features.json').read_text())
assert all(e['name'] not in ['dashboard','details','empty_state'] for e in registry['features'])
assert not (APP/'lib/core/network/retrofit/dashboard_api.dart').exists()
run_case('39_remove_component_cubit',['6','1','1','0'],contains=['Completed. Staged generation and analysis passed.'])
assert not (APP/'lib/shared/widgets/profile_card').exists()
run_case('40_remove_component_bloc',['6','1','1','0'],contains=['Completed. Staged generation and analysis passed.'])
assert not (APP/'lib/shared/components/status_badge').exists()
run_case('41_remove_last_feature',['5','1','1','0'],contains=['Completed. Staged generation and analysis passed.'])
run_case('42_lists_after_removal',['3','4','0'],contains=['No features yet.','No components yet.'])
user=APP/'lib/core/utils/user_owned_note.dart';user.write_text("const auditNote = 'archive_me';\n")
manifest=APP/'pubspec.yaml';manifest.write_text(manifest.read_text().replace('  generate: true','  generate: false').replace('    - config/flavors/\n',''))
native_before={path:sha for path,sha in source_snapshot().items() if path.startswith(('ios/','android/'))}
run_case('43_reset_archive_restore_pubspec_settings',['9','2','1','0'],contains=['Completed. Staged generation and analysis passed.'])
registry=json.loads((APP/'.cleany/features.json').read_text())
assert registry['features']==[]
backup=APP/registry['last_reset_backup']
assert (backup/'lib/core/utils/user_owned_note.dart').read_text()=="const auditNote = 'archive_me';\n"
assert not user.exists()
assert '    - config/flavors/' in manifest.read_text()
assert '  generate: true' in manifest.read_text()
assert native_before=={path:sha for path,sha in source_snapshot().items() if path.startswith(('ios/','android/'))}
run_case('44_final_home_compact_field_validation',['1','home','1','1','2','3','copyWith:string:copy_with','id:unknown:id','id:string:id','maybe','n','id:string:other','title:string:title','y','visits:int:visits','n','1','0'],contains=['conflicts with Dart, Freezed, or JSON members.','Choose string, int','Field names and JSON keys must be unique.','Completed. Staged generation and analysis passed.'])
run_case('45_final_catalog_bloc',['1','catalog','2','2','lib/modules/shop','1','1','0'],contains=['Completed. Staged generation and analysis passed.'])
run_case('46_final_user_card_cubit',['2','user_card','1','1','1','0'],contains=['Completed. Staged generation and analysis passed.'])
run_case('47_final_status_badge_bloc',['2','status_badge','2','2','lib/shared/components','1','0'],contains=['Completed. Staged generation and analysis passed.'])
run_case('48_final_stateless_nested_component',['2','empty_state','3','3','1','1','0'],contains=['Completed. Staged generation and analysis passed.'])
run_case('49_final_lists',['3','4','0'],contains=['home','catalog','user_card','status_badge','empty_state'])
run_case('50_final_doctor',['10','0'],contains=['No repairable issues found.'])
with zipfile.ZipFile(AUDIT/'snapshots/final_generated_before_demo.zip','w',zipfile.ZIP_DEFLATED) as archive:
    for path in source_snapshot(): archive.write(APP/path,path)
(AUDIT/'snapshots/final_generated_registry.json').write_text((APP/'.cleany/features.json').read_text())
print('RESET AND FINAL GENERATION VERIFIED',flush=True)
