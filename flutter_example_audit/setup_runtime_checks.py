"""Install audit tests after preserving the unmodified generated source snapshot."""
import json
from audit_runner import APP,AUDIT

for source,target in [
    ('generated_architecture_test.dart.txt','test/generated_architecture_test.dart'),
    ('app_flow_test.dart.txt','integration_test/app_flow_test.dart'),
]:
    path=APP/target;path.parent.mkdir(exist_ok=True)
    path.write_text((AUDIT/'templates'/source).read_text())
pubspec=APP/'pubspec.yaml';text=pubspec.read_text()
text=text.replace('dev_dependencies:\n','dev_dependencies:\n  integration_test:\n    sdk: flutter\n',1)
pubspec.write_text(text)
router=APP/'lib/app/router/app_router.dart';text=router.read_text()
text=text.replace('GoRouter createRouter(GetIt container) => GoRouter(\n','GoRouter createRouter(GetIt container) => GoRouter(\n  // Example-only: open the generated HomePage when the simulator app starts.\n  initialLocation: RouteNames.home,\n',1)
router.write_text(text)
(AUDIT/'demo_adjustments.json').write_text(json.dumps({
    'generated_source_snapshot':'snapshots/final_generated_before_demo.zip',
    'app_edits':{
        'lib/app/router/app_router.dart':'Set the generated home route as the initial page for the simulator demonstration.',
        'pubspec.yaml':'Add Flutter SDK integration_test as a development dependency.',
        'test/generated_architecture_test.dart':'Add behavior tests against generated code.',
        'integration_test/app_flow_test.dart':'Add real iOS simulator flows using a local HTTP fixture.'
    }
},indent=2))
print('Runtime tests installed; generated page/controller/repository templates remain unchanged.')
