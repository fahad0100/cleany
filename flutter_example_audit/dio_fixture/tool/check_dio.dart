import 'dart:convert';
import 'dart:io';

import 'package:test_cleany_dio/core/errors/failure.dart';
import 'package:test_cleany_dio/core/network/dio/dio_client.dart';
import 'package:test_cleany_dio/features/probe/data/datasources/probe_remote_data_source.dart';
import 'package:test_cleany_dio/features/probe/data/repositories/probe_repository_impl.dart';

Future<void> main() async {
  var status = 200;
  String? auth;
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  server.listen((request) async {
    auth = request.headers.value(HttpHeaders.authorizationHeader);
    request.response.statusCode = status;
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode({'id': 'dio-42'}));
    await request.response.close();
  });
  final dio = createDio(
    'http://127.0.0.1:${server.port}',
    tokenProvider: () async => 'fixture-token',
  );
  try {
    final repo = ProbeRepositoryImpl(ProbeRemoteDataSource(dio));
    if ((await repo.fetch()).tryGetSuccess()?.id != 'dio-42') {
      throw StateError('JSON to Entity failed.');
    }
    if (auth != 'Bearer fixture-token') {
      throw StateError('Trusted-origin auth missing.');
    }
    status = 401;
    if ((await repo.fetch()).tryGetError() is! UnauthorizedFailure) {
      throw StateError('401 mapping failed.');
    }
    stdout.writeln(
      'Dio real HTTP, Entity mapping, Failure mapping and interceptor: PASS',
    );
  } finally {
    dio.close(force: true);
    await server.close(force: true);
  }
}
