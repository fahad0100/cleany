import hashlib
import json
import pathlib
import subprocess
from audit_runner import APP, AUDIT, DART, ROOT, run_case, source_snapshot

run_case('14_doctor_healthy', ['10','0'])
subprocess.run([DART, 'run', str(AUDIT/'inject_faults.dart'),str(APP)],cwd=ROOT,check=True)
run_case('15_doctor_missing_nodes_custom_route', ['10','1','0'], contains=['Completed. Staged generation and analysis passed.'])
assert "'/sign-in'" in (APP/'lib/app/router/route_names.dart').read_text()
assert 'HomeCubit(GetHome(container<HomeRepository>()))' in (APP/'lib/app/di/injection.dart').read_text()
assert 'registerLazySingleton<GetHome>' in (APP/'lib/app/di/injection.dart').read_text()
assert 'RouteNames.home' in (APP/'lib/app/router/app_router.dart').read_text()
assert (APP/'lib/features/home/presentation/pages/home_page.dart').exists()
run_case('16_doctor_after_repair', ['10','0'],contains=['No repairable issues found.'])
run_case('17_rename_move_feature_children', ['11','1','dashboard','lib/modules','1','0'],contains=['Completed. Staged generation and analysis passed.'])
assert not (APP/'lib/features/home').exists()
assert (APP/'lib/modules/dashboard/subfeatures/details').exists()
assert "'/sign-in'" in (APP/'lib/app/router/route_names.dart').read_text()
assert "@GET('/home')" in (APP/'lib/core/network/retrofit/dashboard_api.dart').read_text().replace('"', "'")
run_case('18_rename_move_component', ['11','4','profile_card','lib/shared/widgets','1','0'],contains=['Completed. Staged generation and analysis passed.'])
assert (APP/'lib/shared/widgets/profile_card/cubit/profile_card_cubit.dart').exists()
run_case('19_move_only_feature', ['11','2','','lib/features','1','0'],contains=['Completed. Staged generation and analysis passed.'])
assert (APP/'lib/features/catalog').exists()
result=run_case('20_rename_collision', ['11','1','catalog','lib/modules','2','0'],expected=1,contains=['already registered: catalog'])
assert not result['changed_files']
run_case('21_recovery_without_pending_operation', ['8','1','0'],contains=['Recovery completed.'])
cache=APP/'.cleany/cache/orphan_audit'
cache.mkdir(); (cache/'.cleany-stage').write_text(str(APP.resolve())); (cache/'leftover.txt').write_text('discardable staged copy')
unknown=APP/'.cleany/cache/not_owned_by_cleany'; unknown.mkdir(); (unknown/'keep.txt').write_text('preserve')
run_case('22_maintenance_clean_cache', ['9','1','1','0'],contains=['Removed 1 abandoned workspaces.'])
assert not cache.exists() and (unknown/'keep.txt').exists()
run_case('23_maintenance_timeout_arabic_digits', ['9','3','٦٠٠','1','0'],contains=['Settings updated.'])
assert json.loads((APP/'.cleany/settings.json').read_text())['command_timeout_seconds']==600
run_case('24_maintenance_invalid_timeout', ['9','3','0','2','0'],expected=1,contains=['Enter a timeout from 5 to 3600 seconds.'])
run_case('25_maintenance_cancel_reset', ['9','2','2','0'],contains=['Cancelled. No files were changed.'])
print('PHASE 2 VERIFIED',flush=True)
