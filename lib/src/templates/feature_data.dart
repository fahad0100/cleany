import '../project.dart';
import '../specification.dart';
import 'feature_context.dart';

Map<String, String> featureDataFiles(FeatureTemplateContext c) {
  if (!c.full) return {};
  final n = c.name;
  final t = c.type;
  final request = c.spec.hasRequest;
  final endpoint = dartLiteral(c.spec.endpoint ?? '/$n');
  final parameters = request ? '{Map<String, dynamic>? parameters}' : '';
  final apiCall = request ? 'parameters ?? const {}' : '';
  final wire = c.spec.requestEncoding == 'body' ? 'data' : 'queryParameters';
  return {
    '${c.path}/data/models/${n}_model.dart':
        '''
// Freezed forwards JSON annotations to the generated properties.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
part '${n}_model.freezed.dart';
part '${n}_model.g.dart';
@freezed
abstract class ${t}Model with _\$${t}Model {
  const factory ${t}Model({${c.fields(c.spec.fields, model: true)}}) = _${t}Model;
  factory ${t}Model.fromJson(Map<String, dynamic> json) => _\$${t}ModelFromJson(json);
}
''',
    if (c.provider == ApiProvider.retrofit)
      'lib/core/network/retrofit/${n}_api.dart':
          '''
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
part '${n}_api.g.dart';
@RestApi()
abstract class ${t}Api {
  factory ${t}Api(Dio dio, {String? baseUrl}) = _${t}Api;
  @${c.spec.method}($endpoint)
  Future<Map<String, Object?>> fetch(${request ? '${c.spec.requestEncoding == 'body' ? '@Body()' : '@Queries()'} Map<String, dynamic> parameters' : ''});
}
''',
    '${c.path}/data/datasources/${n}_remote_data_source.dart':
        c.provider == ApiProvider.retrofit
        ? '''
import '${c.core}/network/retrofit/${n}_api.dart';
class ${t}RemoteDataSource {
  const ${t}RemoteDataSource(this._api);
  final ${t}Api _api;
  // Raw JSON only. Conversion and Failure mapping belong to the repository.
  Future<Map<String, dynamic>> fetch($parameters) => _api.fetch($apiCall);
}
'''
        : '''
import 'package:dio/dio.dart';
class ${t}RemoteDataSource {
  const ${t}RemoteDataSource(this._dio);
  final Dio _dio;
  Future<Map<String, dynamic>> fetch($parameters) async {
    final response = await _dio.${c.spec.method == 'GET' ? 'get' : 'request'}<Map<String, dynamic>>($endpoint,
      ${c.spec.method == 'GET' ? '' : 'options: Options(method: ${dartLiteral(c.spec.method)}),'}
      ${request ? '$wire: parameters,' : ''}
    );
    final json = response.data;
    if (json == null) throw const FormatException('Missing response body.');
    return json;
  }
}
''',
    '${c.path}/data/repositories/${n}_repository_impl.dart':
        '''
import 'package:multiple_result/multiple_result.dart';
import '${c.core}/errors/failure.dart';
import '${c.core}/errors/error_reporter.dart';
import '${c.core}/network/failure_mapper.dart';
import '${c.imports}/domain/entities/${n}_entity.dart';
import '${c.imports}/domain/repositories/${n}_repository.dart';
${c.requestImport}
import '../datasources/${n}_remote_data_source.dart';
import '../models/${n}_model.dart';
class ${t}RepositoryImpl implements ${t}Repository {
  const ${t}RepositoryImpl(this._remote, {this.reportError = reportUnexpectedError});
  final ${t}RemoteDataSource _remote;
  final ErrorReporter reportError;
  @override
  Future<Result<${t}Entity, Failure>> fetch(${c.requestArgument}) async {
    try {
      final json = await _remote.fetch(${request ? '''parameters: {
${c.spec.requestFields.map((field) {
                final access = 'request.${field.name}';
                final value = field.type.replaceAll('?', '') == 'DateTime' ? '$access${field.nullable ? '?' : ''}.toIso8601String()' : access;
                return '${dartLiteral(field.jsonKey)}: $value,';
              }).join('\n')}
}..removeWhere((_, value) => value == null)''' : ''});
      final model = ${t}Model.fromJson(json);
      return Success(${t}Entity(${c.spec.fields.map((field) => '${field.name}: model.${field.name}').join(', ')}));
    } catch (error, stackTrace) {
      final failure = mapFailure(error);
      if (failure is UnexpectedFailure) reportError(error, stackTrace);
      return Error(failure);
    }
  }
}
''',
  };
}
