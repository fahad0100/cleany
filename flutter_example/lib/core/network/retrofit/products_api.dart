// Typed endpoints for the public Fake Store API. Returns raw transport JSON.
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
part 'products_api.g.dart';

@RestApi()
abstract class ProductsApi {
  factory ProductsApi(Dio dio, {String? baseUrl}) = _ProductsApi;
  @GET('/products')
  Future<List<Object?>> fetch();
  @GET('/products/1')
  Future<Map<String, Object?>> getFeaturedProduct();
}
