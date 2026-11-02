// Declares API endpoints returning raw JSON; Retrofit generates the HTTP implementation.
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
part 'auth_api.g.dart';

/// Declares API endpoints returning raw JSON; Retrofit generates the HTTP implementation.
@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio, {String? baseUrl}) = _AuthApi;
  @GET("/auth")
  Future<Map<String, Object?>> fetch();
}
