// Fetches raw JSON and propagates exceptions to the repository.
import 'package:cleany_store/core/network/retrofit/carts_api.dart';

/// Fetches raw JSON and propagates exceptions to the repository.
class CartsRemoteDataSource {
  const CartsRemoteDataSource(this._api);
  final CartsApi _api;
  // Raw JSON only. Conversion and Failure mapping belong to the repository.
  Future<Map<String, dynamic>> fetch() => _api.fetch();

  /// Connect this method to the backend contract. Return raw JSON; conversion belongs to the repository.
  /// Until connected, the repository returns a Failure without making an API call.
  Future<Map<String, dynamic>> createCart() {
    throw UnimplementedError(
      'Connect carts.createCart to its backend contract.',
    );
  }

  /// Connect this method to the backend contract. Complete only after the backend operation succeeds.
  /// Until connected, the repository returns a Failure without making an API call.
  Future<void> deleteCart() {
    throw UnimplementedError(
      'Connect carts.deleteCart to its backend contract.',
    );
  }
}
