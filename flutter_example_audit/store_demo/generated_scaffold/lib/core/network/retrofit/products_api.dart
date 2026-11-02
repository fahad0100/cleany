// Declares API endpoints returning raw JSON; Retrofit generates the HTTP implementation.
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
part 'products_api.g.dart';

/// Declares API endpoints returning raw JSON; Retrofit generates the HTTP implementation.
@RestApi()
abstract class ProductsApi {
  factory ProductsApi(Dio dio, {String? baseUrl}) = _ProductsApi;
  @GET("/products")
  Future<Map<String, Object?>> fetch();
}
