// Fetches raw JSON and propagates exceptions to the repository.
import 'package:dio/dio.dart';

/// Fetches raw JSON and propagates exceptions to the repository.
class ProbeRemoteDataSource {
  const ProbeRemoteDataSource(this._dio);
  final Dio _dio;
  Future<Map<String, dynamic>> fetch() async {
    final response = await _dio.get<Map<String, dynamic>>("/probe");
    final json = response.data;
    if (json == null) throw const FormatException('Missing response body.');
    return json;
  }
}
