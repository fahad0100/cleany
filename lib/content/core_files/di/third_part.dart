String thirdPartyConfigFile() {
  return '''
import 'package:get_storage/get_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@module
abstract class ThirdPartyConfig {
  @lazySingleton
  GetStorage get storage => GetStorage();

  @lazySingleton
  SupabaseClient get supabaseClient => Supabase.instance.client;
}

''';
}
