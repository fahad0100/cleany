String configureDependencies() {
  return '''
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'configure_dependencies.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
Future<void> configureDependencies() async {
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['urlSupabase'].toString(),
    anonKey: dotenv.env['keySupabase'].toString(),
  );
  await GetStorage.init();
  getIt.init();
}
''';
}
