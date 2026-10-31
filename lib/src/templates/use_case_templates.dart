import '../ast_editor.dart';
import '../specification.dart';
import '../use_case_editor.dart';
import 'feature_context.dart';

const useCaseStatePath = 'lib/core/state/use_case_state.dart';

/// Typed action progress shared by every variant of a feature's main state.
/// Additional actions do not add union variants or break existing page switches.
String useCaseStateTemplate() => r'''
import 'package:freezed_annotation/freezed_annotation.dart';
import '../errors/failure.dart';
part 'use_case_state.freezed.dart';

/// Tracks one operation independently of the feature's primary loading state.
@freezed
sealed class UseCaseState<T> with _$UseCaseState<T> {
  const factory UseCaseState.initial() = UseCaseInitial<T>;
  const factory UseCaseState.loading() = UseCaseLoading<T>;
  const factory UseCaseState.success(T value) = UseCaseSuccess<T>;
  const factory UseCaseState.failure(Failure failure) = UseCaseFailure<T>;
}
''';

/// Generates the use case and, only for legacy metadata, a dedicated repository.
/// New operations extend the feature's existing Domain and Data repositories.
Map<String, String> useCaseFiles(
  FeatureTemplateContext c,
  UseCaseSpec operation,
) {
  final valueType = operation.returnType == UseCaseReturnType.entity
      ? '${c.type}Entity'
      : 'void';
  final repository = operation.usesFeatureRepository
      ? '${c.type}Repository'
      : operation.repository;
  final repositoryFile = operation.usesFeatureRepository
      ? c.name
      : operation.name;
  final entityImport = operation.returnType == UseCaseReturnType.entity
      ? "import '${c.imports}/domain/entities/${c.name}_entity.dart';"
      : '';
  return {
    if (!operation.usesFeatureRepository)
      '${c.path}/domain/repositories/${operation.name}_repository.dart':
          '''
import 'package:multiple_result/multiple_result.dart';
import '${c.core}/errors/failure.dart';
$entityImport

/// Legacy single-operation contract retained for existing projects.
abstract interface class ${operation.repository} {
  Future<Result<$valueType, Failure>> ${operation.method}();
}
''',
    '${c.path}/domain/usecases/${operation.name}.dart':
        '''
import 'package:multiple_result/multiple_result.dart';
import '${c.core}/errors/failure.dart';
import '../repositories/${repositoryFile}_repository.dart';
$entityImport

/// Runs ${operation.method} through the feature's transport-independent contract.
class ${operation.type} {
  const ${operation.type}(this._repository);
  final $repository _repository;
  Future<Result<$valueType, Failure>> call() => _repository.${operation.method}();
}
''',
    if (!operation.usesFeatureRepository)
      '${c.path}/data/repositories/${operation.name}_repository_impl.dart':
          '''
import 'package:multiple_result/multiple_result.dart';
import '${c.core}/errors/failure.dart';
import '${c.core}/errors/error_reporter.dart';
import '${c.core}/network/failure_mapper.dart';
import '${c.imports}/domain/repositories/${operation.name}_repository.dart';
import '../datasources/${c.name}_remote_data_source.dart';
$entityImport
${operation.returnType == UseCaseReturnType.entity ? "import '../models/${c.name}_model.dart';" : ''}

/// Legacy adapter retained without rewriting existing custom implementations.
class ${operation.repository}Impl implements ${operation.repository} {
  const ${operation.repository}Impl(this._remote, {this.reportError = reportUnexpectedError});
  final ${c.type}RemoteDataSource _remote;
  final ErrorReporter reportError;
  ${useCaseRepositoryMethod(c, operation)}
}
''',
  };
}

/// Repository-owned JSON mapping and Failure conversion for one operation.
String useCaseRepositoryMethod(
  FeatureTemplateContext c,
  UseCaseSpec operation, {
  String remoteName = '_remote',
  String reporterName = 'reportError',
}) {
  final valueType = operation.returnType == UseCaseReturnType.entity
      ? '${c.type}Entity'
      : 'void';
  final mapping =
      (operation.entityFields ?? c.spec.fields.map((field) => field.name))
          .map((name) => '$name: model.$name')
          .join(', ');
  return '''
  /// Executes ${operation.method}; maps transport data and errors at this boundary.
  @override
  Future<Result<$valueType, Failure>> ${operation.method}() async {
    try {
${operation.returnType == UseCaseReturnType.entity ? '''
      final json = await $remoteName.${operation.method}();
      final model = ${c.type}Model.fromJson(json);
      return Success(${c.type}Entity($mapping));
''' : '''
      await $remoteName.${operation.method}();
      return const Success<void, Failure>(null);
'''}
    } catch (error, stackTrace) {
      final failure = mapFailure(error);
      if (failure is UnexpectedFailure) {
        // Reporting is observational and must preserve the original Result.
        try { $reporterName(error, stackTrace); } catch (_) { /* Keep the original failure. */ }
      }
      return Error(failure);
    }
  }
''';
}

/// Additive feature edits used both by the planner and canonical Doctor output.
Map<String, String> addUseCaseToFeature(
  FeatureTemplateContext c,
  UseCaseSpec operation,
  List<UseCaseSpec> operations,
  Map<String, String> sources,
) {
  final valueType = operation.returnType == UseCaseReturnType.entity
      ? '${c.type}Entity'
      : 'void';
  final statePath = '${c.path}/${c.stateFolder}/${c.name}_state.dart';
  final controllerPath = '${c.path}/${c.stateFolder}/${c.name}_${c.mode}.dart';
  final remotePath =
      '${c.path}/data/datasources/${c.name}_remote_data_source.dart';
  final result = <String, String>{...useCaseFiles(c, operation)};

  if (operation.usesFeatureRepository) {
    final contractPath =
        '${c.path}/domain/repositories/${c.name}_repository.dart';
    final implementationPath =
        '${c.path}/data/repositories/${c.name}_repository_impl.dart';
    final contract = AstEditor(sources[contractPath]!);
    contract.addMembers('${c.type}Repository', '''
  /// Runs ${operation.method}, returning domain data or a Failure.
  Future<Result<$valueType, Failure>> ${operation.method}();
''');
    result[contractPath] = contract.source;
    final implementation = AstEditor(sources[implementationPath]!);
    final dependencies = UseCaseEditor(implementation.source);
    implementation.addMembers(
      '${c.type}RepositoryImpl',
      useCaseRepositoryMethod(
        c,
        operation,
        remoteName: dependencies.dependencyField(
          '${c.type}RepositoryImpl',
          '${c.type}RemoteDataSource',
        ),
        reporterName: dependencies.dependencyField(
          '${c.type}RepositoryImpl',
          'ErrorReporter',
        ),
      ),
    );
    result[implementationPath] = implementation.source;
  }

  final state = UseCaseEditor(sources[statePath]!);
  state.addParameter(
    '${c.type}State',
    operation.statusField,
    '@Default(UseCaseState<$valueType>.initial()) UseCaseState<$valueType> ${operation.statusField}',
    factories: true,
  );
  final stateImports = AstEditor(state.source)
    ..addImports(['${c.core}/state/use_case_state.dart']);
  result[statePath] = stateImports.source;

  final controller = AstEditor(sources[controllerPath]!);
  controller.addImports([
    '${c.imports}/domain/usecases/${operation.name}.dart',
    '${c.core}/state/use_case_state.dart',
    '${c.core}/errors/failure.dart',
    if (operation.returnType == UseCaseReturnType.entity)
      '${c.imports}/domain/entities/${c.name}_entity.dart',
  ]);
  final actionBody =
      '''
    if (${c.bloc ? '' : 'isClosed || '}state.${operation.statusField} is UseCaseLoading<$valueType>) {
      return;
    }
    emit(state.copyWith(${operation.statusField}: const UseCaseState<$valueType>.loading()));
    final useCase = ${operation.dependency};
    if (useCase == null) {
      emit(state.copyWith(${operation.statusField}: const UseCaseState<$valueType>.failure(UnexpectedFailure('This action is unavailable.'))));
      return;
    }
    final result = await useCase();
    if (${c.bloc ? 'emit.isDone' : 'isClosed'}) {
      return;
    }
    result.when(
      (${operation.returnType == UseCaseReturnType.entity ? 'entity' : '_'}) => emit(state.copyWith(${operation.statusField}: ${operation.returnType == UseCaseReturnType.entity ? 'UseCaseState<$valueType>.success(entity)' : 'const UseCaseState<void>.success(null)'})),
      (failure) => emit(state.copyWith(${operation.statusField}: UseCaseState<$valueType>.failure(failure))),
    );
''';
  controller.addMembers(c.controller, '''
  /// Optional for existing manual construction; central DI always supplies this action.
  final ${operation.type}? ${operation.dependency};

  /// Updates only ${operation.statusField}; other actions keep their current state.
  Future<void> ${c.bloc ? '_on${operation.type}Requested(${c.type}${operation.type}Requested event, Emitter<${c.type}State> emit)' : '${operation.method}()'} async {
$actionBody
  }
''');
  final controllerEdits = UseCaseEditor(controller.source);
  controllerEdits.addParameter(
    c.controller,
    operation.dependency,
    'this.${operation.dependency}',
  );
  if (c.bloc) {
    final eventPath = '${c.path}/${c.stateFolder}/${c.name}_event.dart';
    final event = AstEditor(sources[eventPath]!);
    event.addMembers('${c.type}Event', '''
  /// Requests ${operation.method}; observe its status on the feature State.
  const factory ${c.type}Event.${operation.method}Requested() = ${c.type}${operation.type}Requested;
''');
    result[eventPath] = event.source;
    controllerEdits.addConstructorStatement(
      c.controller,
      'on<${c.type}${operation.type}Requested>(_on${operation.type}Requested);',
    );
  }
  controllerEdits.preserveStatuses(
    c.controller,
    '${c.type}State',
    operations.map((op) => op.statusField).toList(),
  );
  result[controllerPath] = controllerEdits.source;

  final remote = AstEditor(sources[remotePath]!);
  remote.addMembers('${c.type}RemoteDataSource', '''
  /// Connect this method to the backend contract. ${operation.returnType == UseCaseReturnType.entity ? 'Return raw JSON; conversion belongs to the repository.' : 'Complete only after the backend operation succeeds.'}
  /// Until connected, the repository returns a Failure without making an API call.
  Future<${operation.returnType == UseCaseReturnType.entity ? 'Map<String, dynamic>' : 'void'}> ${operation.method}() {
    throw UnimplementedError('Connect ${c.name}.${operation.method} to its backend contract.');
  }
''');
  result[remotePath] = remote.source;
  return result;
}
