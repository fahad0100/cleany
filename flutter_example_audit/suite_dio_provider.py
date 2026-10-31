import json
import pathlib
import subprocess
import time
from audit_runner import ROOT, AUDIT, DART

fixture=AUDIT/'dio_fixture'
flutter='/opt/homebrew/share/flutter/bin/flutter'
subprocess.run([flutter,'create','--empty','--project-name','test_cleany_dio','--org','com.example','--platforms','ios','--no-pub',str(fixture)],cwd=ROOT,check=True,stdout=subprocess.DEVNULL)
pub=fixture/'pubspec.yaml';pub.write_text(pub.read_text().replace('dev_dependencies:\n','dev_dependencies:\n  cleany:\n    path: ../..\n',1))
subprocess.run([flutter,'pub','get'],cwd=fixture,check=True,stdout=subprocess.DEVNULL)
for name,answers in [
    ('53_dio_provider_initialize',['7','2','1','0']),
    ('54_dio_provider_feature_bloc',['1','probe','2','1','1','1','0']),
]:
    started=time.monotonic()
    run=subprocess.run([DART,'run','cleany'],input='\n'.join(answers)+'\n',cwd=fixture,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=600)
    (AUDIT/'logs'/f'{name}.log').write_text(run.stdout)
    row={'case':name,'fixture':'dio_fixture','answers':answers,'exit_code':run.returncode,'duration_seconds':round(time.monotonic()-started,2),'passed':run.returncode==0 and 'Completed. Staged generation and analysis passed.' in run.stdout}
    with (AUDIT/'results.jsonl').open('a') as file:file.write(json.dumps(row)+'\n')
    print(json.dumps(row),flush=True)
    if not row['passed']: print(run.stdout[-4000:]);raise SystemExit(1)
assert '  retrofit:' not in pub.read_text()
assert not (fixture/'lib/core/network/retrofit').exists()
assert 'Dio _dio' in (fixture/'lib/features/probe/data/datasources/probe_remote_data_source.dart').read_text()
tool=fixture/'tool';tool.mkdir(exist_ok=True)
(tool/'check_dio.dart').write_text('''
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
  final dio = createDio('http://127.0.0.1:${server.port}', tokenProvider: () async => 'fixture-token');
  try {
    final repo = ProbeRepositoryImpl(ProbeRemoteDataSource(dio));
    if ((await repo.fetch()).tryGetSuccess()?.id != 'dio-42') throw StateError('JSON to Entity failed.');
    if (auth != 'Bearer fixture-token') throw StateError('Trusted-origin auth missing.');
    status = 401;
    if ((await repo.fetch()).tryGetError() is! UnauthorizedFailure) throw StateError('401 mapping failed.');
    print('Dio real HTTP, Entity mapping, Failure mapping and interceptor: PASS');
  } finally { dio.close(force: true); await server.close(force: true); }
}
''')
run=subprocess.run([DART,'run','tool/check_dio.dart'],cwd=fixture,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=60)
(AUDIT/'logs/55_dio_real_http.log').write_text(run.stdout)
row={'case':'55_dio_real_http','exit_code':run.returncode,'passed':run.returncode==0,'fixture':'dio_fixture'}
with (AUDIT/'results.jsonl').open('a') as file:file.write(json.dumps(row)+'\n')
print(json.dumps(row),flush=True)
assert row['passed'],run.stdout
