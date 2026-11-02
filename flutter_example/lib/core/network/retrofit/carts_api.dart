// Typed endpoints for the public Fake Store API. Returns raw transport JSON.
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
part 'carts_api.g.dart';

@RestApi()
abstract class CartsApi {
  factory CartsApi(Dio dio, {String? baseUrl}) = _CartsApi;
  @GET('/carts')
  Future<List<Object?>> fetch();
  @POST('/carts')
  Future<Map<String, Object?>> createCart(@Body() Map<String, dynamic> body);
  @DELETE('/carts/{id}')
  Future<void> deleteCart(@Path('id') int id);
}
