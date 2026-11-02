import 'feature_context.dart';

Map<String, String> featurePresentationFiles(FeatureTemplateContext c) {
  final n = c.name;
  final t = c.type;
  final state = c.stateFolder;
  final valueType = c.full ? '${t}Entity' : 'int';
  final status = c.primaryStatus;
  final usesStatus = c.singleState && !c.splitPrimaryState;
  final files = <String, String>{};
  void add(String relative, String text) => files['${c.path}/$relative'] = text;
  if (c.full) add('presentation/widgets/.gitkeep', '');
  if (c.stateful) {
    add('$state/${n}_state.dart', '''
import 'package:freezed_annotation/freezed_annotation.dart';
${c.full ? "import '${c.imports}/domain/entities/${n}_entity.dart';" : ''}
${c.singleState
        ? "import '${c.core}/state/use_case_state.dart';"
        : c.full
        ? "import '${c.core}/errors/failure.dart';"
        : ''}
part '${n}_state.freezed.dart';
@freezed
sealed class ${t}State with _\$${t}State {
${c.singleState ? '''
  const factory ${t}State({
${usesStatus ? '''
    @Default(UseCaseState.initial()) UseCaseState<$valueType> $status,
''' : '''
    @Default(UseCaseState<$valueType>.initial()) UseCaseState<$valueType> initialState,
    @Default(UseCaseState<$valueType>.initial()) UseCaseState<$valueType> successState,
    @Default(UseCaseState<$valueType>.initial()) UseCaseState<$valueType> errorState,
'''}
  }) = _${t}State;
''' : '''
  const factory ${t}State.initial() = ${t}Initial;
${c.full ? '''
  const factory ${t}State.loading() = ${t}Loading;
  const factory ${t}State.success(${t}Entity entity) = ${t}Success;
  const factory ${t}State.failure(Failure failure) = ${t}Failure;
''' : '  const factory ${t}State.updated(int value) = ${t}Updated;'}
'''}
}
''');
    if (c.bloc) {
      add('$state/${n}_event.dart', '''
import 'package:freezed_annotation/freezed_annotation.dart';
${c.requestImport}
part '${n}_event.freezed.dart';
@freezed
sealed class ${t}Event with _\$${t}Event {
  const factory ${t}Event.requested(${c.full && c.spec.hasRequest ? '{required ${t}Request request}' : ''}) = ${t}Requested;
}
''');
    }
    final result = usesStatus
        ? '''
    if (${c.bloc ? '' : 'isClosed || '}state.$status is UseCaseLoading<$valueType>) {
      return;
    }
    emit(state.copyWith($status: const UseCaseState.loading()));
    final result = await _get$t(${c.spec.hasRequest ? 'request: ${c.bloc ? 'event.request' : 'request'}' : ''});
    if (${c.bloc ? 'emit.isDone' : 'isClosed'}) {
      return;
    }
    result.when(
      (entity) => emit(state.copyWith($status: UseCaseState.success(entity))),
      (failure) => emit(state.copyWith($status: UseCaseState.failure(failure))),
    );
'''
        : c.singleState
        ? '''
    if (${c.bloc ? '' : 'isClosed || '}state.initialState is UseCaseLoading<$valueType>) return;
    emit(state.copyWith(
      initialState: const UseCaseState.loading(),
      successState: const UseCaseState.initial(),
      errorState: const UseCaseState.initial(),
    ));
    final result = await _get$t(${c.spec.hasRequest ? 'request: ${c.bloc ? 'event.request' : 'request'}' : ''});
    if (${c.bloc ? 'emit.isDone' : 'isClosed'}) return;
    result.when(
      (entity) => emit(state.copyWith(
        initialState: const UseCaseState.initial(),
        successState: UseCaseState.success(entity),
        errorState: const UseCaseState.initial(),
      )),
      (failure) => emit(state.copyWith(
        initialState: const UseCaseState.initial(),
        successState: const UseCaseState.initial(),
        errorState: UseCaseState.failure(failure),
      )),
    );
'''
        : '''
    if (${c.bloc ? '' : 'isClosed || '}state is ${t}Loading) return;
    emit(const ${t}State.loading());
    final result = await _get$t(${c.spec.hasRequest ? 'request: ${c.bloc ? 'event.request' : 'request'}' : ''});
    if (${c.bloc ? 'emit.isDone' : 'isClosed'}) return;
    result.when((entity) => emit(${t}State.success(entity)),
      (failure) => emit(${t}State.failure(failure)));
''';
    add('$state/${n}_${c.mode}.dart', '''
import 'package:flutter_bloc/flutter_bloc.dart';
${c.singleState ? "import '${c.core}/state/use_case_state.dart';" : ''}
${c.singleState && c.full ? "import '${c.imports}/domain/entities/${n}_entity.dart';" : ''}
${c.full ? "import '${c.imports}/domain/usecases/get_$n.dart';" : ''}
${c.bloc ? '' : c.requestImport}
import '${n}_state.dart';
${c.bloc ? "import '${n}_event.dart';" : ''}
class ${c.controller} extends ${c.bloc ? 'Bloc<${t}Event, ${t}State>' : 'Cubit<${t}State>'} {
${c.full ? '  final Get$t _get$t;' : ''}
  ${c.controller}(${c.full ? 'this._get$t' : ''}) : super(const ${t}State${c.singleState ? '' : '.initial'}())${c.bloc ? ' {\n    on<${t}Requested>(_onRequested);\n  }' : ';'}
${c.bloc && !c.full ? '''
  // Component actions after disposal are ignored, matching Cubit.update.
  @override
  void add(${t}Event event) { if (!isClosed) super.add(event); }
''' : ''}
${c.bloc
        ? '''
  Future<void> _onRequested(${t}Requested event, Emitter<${t}State> emit) async {
${c.full
              ? result
              : usesStatus
              ? '''
    if (!emit.isDone) {
      emit(state.copyWith($status: const UseCaseState.success(1)));
    }
'''
              : c.singleState
              ? '''
    if (emit.isDone) return;
    emit(state.copyWith(
      initialState: const UseCaseState.initial(),
      successState: const UseCaseState.success(1),
      errorState: const UseCaseState.initial(),
    ));
'''
              : '    if (!emit.isDone) emit(const ${t}State.updated(1));'}
  }
'''
        : c.full
        ? '''
  Future<void> load(${c.requestArgument}) async {
$result
  }
'''
        : usesStatus
        ? '''
  void update(int value) {
    if (isClosed) return;
    emit(state.copyWith($status: UseCaseState.success(value)));
  }
'''
        : c.singleState
        ? '''
  void update(int value) {
    if (isClosed) return;
    emit(state.copyWith(
      initialState: const UseCaseState.initial(),
      successState: UseCaseState.success(value),
      errorState: const UseCaseState.initial(),
    ));
  }
'''
        : '  void update(int value) { if (!isClosed) emit(${t}State.updated(value)); }'}
}
''');
  }
  final body = usesStatus
      ? '''
      state.$status.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const Center(child: CircularProgressIndicator()),
        success: (${c.full ? 'entity' : 'value'}) => ${c.full ? 'Center(child: Text(entity.${c.spec.fields.first.name}.toString()))' : "Text('\$value')"},
        failure: (failure) => ${c.full ? 'Center(child: Text(failure.message))' : 'Text(failure.message)'},
      )
'''
      : c.singleState
      ? '''
      switch ((state.initialState, state.successState, state.errorState)) {
        (UseCaseLoading(), _, _) => const Center(child: CircularProgressIndicator()),
        (_, _, UseCaseFailure(:final failure)) => ${c.full ? 'Center(child: Text(failure.message))' : 'Text(failure.message)'},
        (_, UseCaseSuccess(:final value), _) => ${c.full ? 'Center(child: Text(value.${c.spec.fields.first.name}.toString()))' : "Text('\$value')"},
        _ => const SizedBox.shrink(),
      }
'''
      : c.full
      ? '''
      switch (state) {
        ${t}Initial() => const SizedBox.shrink(),
        ${t}Loading() => const Center(child: CircularProgressIndicator()),
        ${t}Success(:final entity) => Center(child: Text(entity.${c.spec.fields.first.name}.toString())),
        ${t}Failure(:final failure) => Center(child: Text(failure.message)),
      }
'''
      : '''
      switch (state) {
        ${t}Initial() => const SizedBox.shrink(),
        ${t}Updated(:final value) => Text('\$value'),
      }
''';
  final builder = usesStatus ? '{ return $body; }' : '=> $body';
  add('${c.widgetLocation}${n}_${c.full ? 'page' : 'widget'}.dart', '''
${!c.full && !c.legacyComponentWidgets ? '// Cleany component layout: flat. Widget lives at the component root.' : ''}
${!c.full && c.localComponentScope ? '// Cleany component scope: local. State belongs to each widget instance.' : ''}
import 'package:flutter/material.dart';
${c.stateful && c.singleState ? "import '${c.core}/state/use_case_state.dart';" : ''}
${c.stateful ? "import 'package:flutter_bloc/flutter_bloc.dart';\nimport '${c.widgetStatePrefix}${c.mode}/${n}_${c.mode}.dart';\nimport '${c.widgetStatePrefix}${c.mode}/${n}_state.dart';" : ''}
class $t${c.full ? 'Page' : 'Widget'} extends StatelessWidget {
  const $t${c.full ? 'Page' : 'Widget'}({super.key});
  @override
  Widget build(BuildContext context) {
${!c.full && c.stateful && c.localComponentScope ? '''
    return BlocProvider(
      create: (context) => ${c.controller}(),
      child: Builder(
        builder: (context) {
          final _ = context.read<${c.controller}>();
          return BlocBuilder<${c.controller}, ${t}State>(
            builder: (context, state) $builder,
          );
        },
      ),
    );
''' : '''
${c.stateful && (!usesStatus || !c.full) ? '    final _ = context.read<${c.controller}>();' : ''}
    return ${c.full ? "Scaffold(appBar: AppBar(title: const Text('$t')), body: " : ''}${c.stateful ? 'BlocBuilder<${c.controller}, ${t}State>(builder: (context, state) $builder)' : 'const SizedBox.shrink()'}${c.full ? ')' : ''};
'''}
  }
}
''');
  return files;
}
