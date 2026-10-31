import 'project.dart';

Map<String, Map<String, Object>> packageRequirements(ApiProvider provider) => {
  'dependencies': {
    'flutter_localizations': {'sdk': 'flutter'},
    'intl': 'any',
    'flutter_bloc': '^9.1.1',
    'get_it': '^9.2.1',
    'go_router': '^18.0.0',
    'multiple_result': '^5.3.0',
    'dio': '^5.11.0',
    'freezed_annotation': '^3.1.0',
    'json_annotation': '^4.12.0',
    'yaml': '^3.1.3',
    if (provider == ApiProvider.retrofit) 'retrofit': '^4.10.0',
  },
  'dev_dependencies': {
    'build_runner': '^2.15.1',
    'freezed': '^4.0.3',
    'json_serializable': '^6.14.1',
    'flutter_flavorizr': '^2.6.0',
    'flutter_lints': '^6.0.0',
    if (provider == ApiProvider.retrofit) 'retrofit_generator': '^10.3.2',
  },
};
