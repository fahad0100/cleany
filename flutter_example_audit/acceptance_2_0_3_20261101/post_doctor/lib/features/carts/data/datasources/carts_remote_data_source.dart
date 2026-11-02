// Raw JSON only: no Entity mapping and no Failure conversion here.
import 'package:cleany_store/core/network/retrofit/carts_api.dart';

class CartsRemoteDataSource {
  const CartsRemoteDataSource(this._api);
  final CartsApi _api;
  Future<List<Map<String, dynamic>>> fetch() async => (await _api.fetch())
      .map((value) => Map<String, dynamic>.from(value as Map))
      .toList();
  Future<Map<String, dynamic>> createCart(Map<String, dynamic> body) =>
      _api.createCart(body);
  Future<void> deleteCart(int id) async {
    await _api.deleteCart(id);
  }
}
