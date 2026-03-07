String configureDependencies() {
  return '''
import 'package:get_it/get_it.dart';

Future<void> configureDependencies() async {
  final getIt = GetIt.instance;
}
''';
}
