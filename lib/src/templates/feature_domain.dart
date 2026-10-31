import 'feature_context.dart';

Map<String, String> featureDomainFiles(FeatureTemplateContext c) {
  if (!c.full) return {};
  final n = c.name;
  final t = c.type;
  return {
    '${c.path}/domain/entities/${n}_entity.dart':
        '''
import 'package:freezed_annotation/freezed_annotation.dart';
part '${n}_entity.freezed.dart';
@freezed
abstract class ${t}Entity with _\$${t}Entity {
  const factory ${t}Entity({${c.fields(c.spec.fields)}}) = _${t}Entity;
}
''',
    if (c.spec.hasRequest)
      '${c.path}/domain/entities/${n}_request.dart':
          '''
import 'package:freezed_annotation/freezed_annotation.dart';
part '${n}_request.freezed.dart';
@freezed
abstract class ${t}Request with _\$${t}Request {
  const factory ${t}Request({${c.fields(c.spec.requestFields)}}) = _${t}Request;
}
''',
    '${c.path}/domain/repositories/${n}_repository.dart':
        '''
import 'package:multiple_result/multiple_result.dart';
import '${c.core}/errors/failure.dart';
import '../entities/${n}_entity.dart';
${c.requestImport}
abstract interface class ${t}Repository {
  Future<Result<${t}Entity, Failure>> fetch(${c.requestArgument});
}
''',
    '${c.path}/domain/usecases/get_$n.dart':
        '''
import 'package:multiple_result/multiple_result.dart';
import '${c.core}/errors/failure.dart';
import '../entities/${n}_entity.dart';
import '../repositories/${n}_repository.dart';
${c.requestImport}
class Get$t {
  const Get$t(this._repository);
  final ${t}Repository _repository;
  Future<Result<${t}Entity, Failure>> call(${c.requestArgument}) => _repository.fetch(${c.spec.hasRequest ? 'request: request' : ''});
}
''',
  };
}
