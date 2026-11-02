// Fetches raw JSON and propagates exceptions to the repository.
import 'package:cleany_store/core/network/retrofit/auth_api.dart';

/// Fetches raw JSON and propagates exceptions to the repository.
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._api);
  final AuthApi _api;
  // Raw JSON only. Conversion and Failure mapping belong to the repository.
  Future<Map<String, dynamic>> fetch() => _api.fetch();

  /// Connect this method to the backend contract. Return raw JSON; conversion belongs to the repository.
  /// Until connected, the repository returns a Failure without making an API call.
  Future<Map<String, dynamic>> signIn() {
    throw UnimplementedError('Connect auth.signIn to its backend contract.');
  }

  /// Connect this method to the backend contract. Complete only after the backend operation succeeds.
  /// Until connected, the repository returns a Failure without making an API call.
  Future<void> signOut() {
    throw UnimplementedError('Connect auth.signOut to its backend contract.');
  }
}
