// Declares API endpoints returning raw JSON; Retrofit generates the HTTP implementation.
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
part 'users_api.g.dart';

/// Declares API endpoints returning raw JSON; Retrofit generates the HTTP implementation.
@RestApi()
abstract class UsersApi {
  factory UsersApi(Dio dio, {String? baseUrl}) = _UsersApi;
  @GET("/users")
  Future<Map<String, Object?>> fetch();
}
