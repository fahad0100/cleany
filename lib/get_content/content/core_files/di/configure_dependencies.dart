import 'package:cleany/utils/file_modifier.dart';

String configureDependencies() {
  final projectName = FileModifier.getProjectName();
  return '''
import 'package:get_it/get_it.dart';
import 'package:$projectName/core/di/configure_dependencies.config.dart';
import 'package:injectable/injectable.dart';

@InjectableInit(
  initializerName: 'init', 
  preferRelativeImports: true,
  asExtension: true, 
)

Future<void> configureDependencies() async {
  final getIt = GetIt.instance;
  getIt.init();
}
''';
}
