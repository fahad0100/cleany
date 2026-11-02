// Raw JSON only: no Entity mapping and no Failure conversion here.
import 'package:cleany_store/core/network/retrofit/auth_api.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._api);
  final AuthApi _api;
  Future<Map<String, dynamic>> signIn(String username, String password) =>
      _api.signIn({'username': username, 'password': password});
  Future<List<Map<String, dynamic>>> users() async => (await _api.users())
      .map((value) => Map<String, dynamic>.from(value as Map))
      .toList();
}
