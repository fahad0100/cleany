import 'feature_context.dart';

Map<String, String> featurePresentationFiles(FeatureTemplateContext c) {
  final n = c.name;
  final t = c.type;
  final state = c.stateFolder;
  final files = <String, String>{};
  void add(String relative, String text) => files['${c.path}/$relative'] = text;
  if (c.full) add('presentation/widgets/.gitkeep', '');
  if (c.stateful) {
    add('$state/${n}_state.dart', '''
import 'package:freezed_annotation/freezed_annotation.dart';
${c.full ? "import '${c.imports}/domain/entities/${n}_entity.dart';\nimport '${c.core}/errors/failure.dart';" : ''}
part '${n}_state.freezed.dart';
@freezed
sealed class ${t}State with _\$${t}State {
  const factory ${t}State.initial() = ${t}Initial;
${c.full ? '''
  const factory ${t}State.loading() = ${t}Loading;
  const factory ${t}State.success(${t}Entity entity) = ${t}Success;
  const factory ${t}State.failure(Failure failure) = ${t}Failure;
''' : '  const factory ${t}State.updated(int value) = ${t}Updated;'}
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
    final result =
        '''
    if (${c.bloc ? '' : 'isClosed || '}state is ${t}Loading) return;
    emit(const ${t}State.loading());
    final result = await _get$t(${c.spec.hasRequest ? 'request: ${c.bloc ? 'event.request' : 'request'}' : ''});
    if (${c.bloc ? 'emit.isDone' : 'isClosed'}) return;
    result.when((entity) => emit(${t}State.success(entity)),
      (failure) => emit(${t}State.failure(failure)));
''';
    add('$state/${n}_${c.mode}.dart', '''
import 'package:flutter_bloc/flutter_bloc.dart';
${c.full ? "import '${c.imports}/domain/usecases/get_$n.dart';" : ''}
${c.bloc ? '' : c.requestImport}
import '${n}_state.dart';
${c.bloc ? "import '${n}_event.dart';" : ''}
class ${c.controller} extends ${c.bloc ? 'Bloc<${t}Event, ${t}State>' : 'Cubit<${t}State>'} {
${c.full ? '  final Get$t _get$t;' : ''}
  ${c.controller}(${c.full ? 'this._get$t' : ''}) : super(const ${t}State.initial())${c.bloc ? ' {\n    on<${t}Requested>(_onRequested);\n  }' : ';'}
${c.bloc && !c.full ? '''
  // Component actions after disposal are ignored, matching Cubit.update.
  @override
  void add(${t}Event event) { if (!isClosed) super.add(event); }
''' : ''}
${c.bloc
        ? '''
  Future<void> _onRequested(${t}Requested event, Emitter<${t}State> emit) async {
${c.full ? result : '    if (!emit.isDone) emit(const ${t}State.updated(1));'}
  }
'''
        : c.full
        ? '''
  Future<void> load(${c.requestArgument}) async {
$result
  }
'''
        : '  void update(int value) { if (!isClosed) emit(${t}State.updated(value)); }'}
}
''');
  }
  final body = c.full
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
  add('${c.widgetLocation}${n}_${c.full ? 'page' : 'widget'}.dart', '''
${!c.full && !c.legacyComponentWidgets ? '// Cleany component layout: flat. Widget lives at the component root.' : ''}
import 'package:flutter/material.dart';
${c.stateful ? "import 'package:flutter_bloc/flutter_bloc.dart';\nimport '${c.widgetStatePrefix}${c.mode}/${n}_${c.mode}.dart';\nimport '${c.widgetStatePrefix}${c.mode}/${n}_state.dart';" : ''}
class $t${c.full ? 'Page' : 'Widget'} extends StatelessWidget {
  const $t${c.full ? 'Page' : 'Widget'}({super.key});
  @override
  Widget build(BuildContext context) {
${c.stateful ? '    final _ = context.read<${c.controller}>();' : ''}
    return ${c.full ? "Scaffold(appBar: AppBar(title: const Text('$t')), body: " : ''}${c.stateful ? 'BlocBuilder<${c.controller}, ${t}State>(builder: (context, state) => $body)' : 'const SizedBox.shrink()'}${c.full ? ')' : ''};
  }
}
''');
  return files;
}
