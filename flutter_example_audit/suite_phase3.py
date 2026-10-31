import json
import zipfile
from audit_runner import APP, AUDIT, run_case, source_snapshot

run_case('26_cancel_native_flavors', ['12','4','0'])
run_case('27_configure_ios_flavors', ['12','2','1','0'], contains=['Completed. Staged generation and analysis passed.'])
for flavor in ['dev','uat','prod']:
    assert (APP/f'ios/Runner.xcodeproj/xcshareddata/xcschemes/{flavor}.xcscheme').exists()
run_case('28_configure_android_flavors', ['12','1','1','0'],contains=['Completed. Staged generation and analysis passed.'])
assert (APP/'android/app/flavorizr.gradle.kts').exists()
run_case('29_configure_all_flavors_again', ['12','3','1','0'],contains=['Completed. Staged generation and analysis passed.'])
config=APP/'config/flavors/uat.yaml'; previous=config.read_text()
try:
    config.write_text('environment: prod\napi_base_url: ""\n')
    result=run_case('30_invalid_flavor_preflight', ['12','2','2','0'],expected=1,contains=['Invalid config/flavors/uat.yaml'])
    assert not result['changed_files']
finally:
    config.write_text(previous)
with zipfile.ZipFile(AUDIT/'snapshots/after_lifecycle_and_flavors.zip','w',zipfile.ZIP_DEFLATED) as archive:
    for path in source_snapshot(): archive.write(APP/path,path)
(AUDIT/'snapshots/after_lifecycle_registry.json').write_text((APP/'.cleany/features.json').read_text())
print('PHASE 3 VERIFIED',flush=True)
