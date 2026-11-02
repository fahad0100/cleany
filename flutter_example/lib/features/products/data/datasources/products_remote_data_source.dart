// Raw JSON only: no Entity mapping and no Failure conversion here.
import 'package:cleany_store/core/network/retrofit/products_api.dart';

class ProductsRemoteDataSource {
  const ProductsRemoteDataSource(this._api);
  final ProductsApi _api;
  Future<List<Map<String, dynamic>>> fetch() async => (await _api.fetch())
      .map((value) => Map<String, dynamic>.from(value as Map))
      .toList();
  Future<Map<String, dynamic>> getFeaturedProduct() =>
      _api.getFeaturedProduct();
}
