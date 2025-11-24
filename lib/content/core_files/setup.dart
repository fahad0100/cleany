String setupFile() {
  return '''
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> setup() async {
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['urlSupabase'].toString(),
    anonKey: dotenv.env['keySupabase'].toString(),
  );
  await GetStorage.init();
}
''';
}
