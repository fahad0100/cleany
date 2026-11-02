// Typed endpoints for the public Fake Store API. Returns raw transport JSON.
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
part 'auth_api.g.dart';

@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio, {String? baseUrl}) = _AuthApi;
  @POST('/auth/login')
  Future<Map<String, Object?>> signIn(@Body() Map<String, dynamic> body);
  @GET('/users')
  Future<List<Object?>> users();
}
