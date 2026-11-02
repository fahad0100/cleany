// Fetches raw JSON and propagates exceptions to the repository.
import 'package:cleany_store/core/network/retrofit/products_api.dart';

/// Fetches raw JSON and propagates exceptions to the repository.
class ProductsRemoteDataSource {
  const ProductsRemoteDataSource(this._api);
  final ProductsApi _api;
  // Raw JSON only. Conversion and Failure mapping belong to the repository.
  Future<Map<String, dynamic>> fetch() => _api.fetch();

  /// Connect this method to the backend contract. Return raw JSON; conversion belongs to the repository.
  /// Until connected, the repository returns a Failure without making an API call.
  Future<Map<String, dynamic>> getFeaturedProduct() {
    throw UnimplementedError(
      'Connect products.getFeaturedProduct to its backend contract.',
    );
  }
}
