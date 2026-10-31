import json
from audit_runner import APP, AUDIT, run_case

run_case('02_invalid_menu_and_empty_lists', ['99', '٣', '٤', '0'], contains=['Choose a number from the menu.', 'No features yet.', 'No components yet.'])
result=run_case('03_cancel_feature', ['1','cancelled_feature','1','1','1','2','0'], contains=['Cancelled. No files were changed.'])
assert not result['changed_files']
run_case('04_invalid_name', ['1','../bad','2','0'], expected=1, contains=['Operation stopped:'])
run_case('05_feature_cubit_fields', ['1','home','1','1','2','3','id:string:id','n','title:string:title','y','visits:int:visits','n','1','0'], contains=['Completed. Staged generation and analysis passed.'])
run_case('06_feature_bloc_custom_path', ['1','catalog','2','2','lib/modules/shop','1','1','0'], contains=['Completed. Staged generation and analysis passed.'])
run_case('07_nested_feature', ['1','details','1','3','1','1','1','0'], contains=['Completed. Staged generation and analysis passed.'])
run_case('08_component_cubit', ['2','user_card','1','1','1','0'], contains=['Completed. Staged generation and analysis passed.'])
run_case('09_component_bloc_custom_path', ['2','status_badge','2','2','lib/shared/components','1','0'], contains=['Completed. Staged generation and analysis passed.'])
run_case('10_component_stateless_nested', ['2','empty_state','3','3','1','1','0'], contains=['Completed. Staged generation and analysis passed.'])
run_case('11_list_features_components', ['3','4','0'], contains=['home','catalog','details','user_card','status_badge','empty_state'])
result=run_case('12_duplicate_name', ['1','home','1','1','1','2','0'], expected=1, contains=['Target already exists:'])
assert not result['changed_files']
result=run_case('13_unsafe_custom_path', ['1','escape','1','2','../outside','1','2','0'], expected=1, contains=['Operation stopped:'])
assert not result['changed_files']
registry=json.loads((APP/'.cleany/features.json').read_text())
assert len(registry['features'])==6
assert registry['app_id'] == 'com.example.testCleanyProject'
assert (APP/'lib/features/home/domain/entities/home_entity.dart').exists()
assert (APP/'lib/modules/shop/catalog/presentation/bloc/catalog_bloc.dart').exists()
assert (APP/'lib/features/home/subfeatures/details').is_dir()
assert (APP/'lib/features/home/subfeatures/empty_state/widgets/empty_state_widget.dart').exists()
assert 'required int visits' in (APP/'lib/features/home/domain/entities/home_entity.dart').read_text()
(AUDIT/'phase1_registry.json').write_text(json.dumps(registry,indent=2))
print('PHASE 1 VERIFIED', flush=True)
