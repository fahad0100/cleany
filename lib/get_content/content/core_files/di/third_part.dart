String thirdPartyFile() {
  return '''
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@module
abstract class ThirdPartyConfig {
  //----------------------------------------------------------------------------
  @lazySingleton
  GetStorage get storage => GetStorage();
  //----------------------------------------------------------------------------
  @lazySingleton
  SupabaseClient get supabaseClient => Supabase.instance.client;
  //----------------------------------------------------------------------------
  AndroidOptions _getAndroidOptions() =>
      const AndroidOptions(encryptedSharedPreferences: true);
  @lazySingleton
  FlutterSecureStorage get flutterSecureStorage =>
      FlutterSecureStorage(aOptions: _getAndroidOptions());
  //----------------------------------------------------------------------------
}

''';
}
