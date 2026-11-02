// Raw JSON only: no Entity mapping and no Failure conversion here.
import 'package:cleany_store/core/network/retrofit/users_api.dart';

class UsersRemoteDataSource {
  const UsersRemoteDataSource(this._api);
  final UsersApi _api;
  Future<List<Map<String, dynamic>>> fetch() async => (await _api.fetch())
      .map((value) => Map<String, dynamic>.from(value as Map))
      .toList();
  Future<Map<String, dynamic>> getUserProfile(int id) =>
      _api.getUserProfile(id);
}
