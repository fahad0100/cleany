// Typed endpoints for the public Fake Store API. Returns raw transport JSON.
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
part 'users_api.g.dart';

@RestApi()
abstract class UsersApi {
  factory UsersApi(Dio dio, {String? baseUrl}) = _UsersApi;
  @GET('/users')
  Future<List<Object?>> fetch();
  @GET('/users/{id}')
  Future<Map<String, Object?>> getUserProfile(@Path('id') int id);
}
