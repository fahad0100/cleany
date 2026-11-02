// Declares API endpoints returning raw JSON; Retrofit generates the HTTP implementation.
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
part 'carts_api.g.dart';

/// Declares API endpoints returning raw JSON; Retrofit generates the HTTP implementation.
@RestApi()
abstract class CartsApi {
  factory CartsApi(Dio dio, {String? baseUrl}) = _CartsApi;
  @GET("/carts")
  Future<Map<String, Object?>> fetch();
}
