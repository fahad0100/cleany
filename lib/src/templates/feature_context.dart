import '../project.dart';
import '../specification.dart';

class FeatureTemplateContext {
  FeatureTemplateContext({
    required this.name,
    required this.path,
    required this.package,
    required this.kind,
    required this.state,
    required this.provider,
    FeatureSpec? specification,
    this.legacyComponentWidgets = false,
  }) : spec = specification ?? FeatureSpec();
  final String name;
  final String path;
  final String package;
  final GenerationKind kind;
  final StateManagement state;
  final ApiProvider provider;
  final FeatureSpec spec;
  final bool legacyComponentWidgets;
  String get type => pascalCase(name);
  bool get full => kind == GenerationKind.feature;
  bool get stateful => state != StateManagement.none;
  bool get bloc => state == StateManagement.bloc;
  String get mode => state.name;
  String get controller => '$type${bloc ? 'Bloc' : 'Cubit'}';
  String get imports => 'package:$package/${path.substring(4)}';
  String get core => 'package:$package/core';
  String get widgetLocation => full
      ? 'presentation/pages/'
      : legacyComponentWidgets
      ? 'widgets/'
      : '';
  String get widgetStatePrefix => full || legacyComponentWidgets ? '../' : '';
  String get stateFolder => full ? 'presentation/$mode' : mode;
  String get requestImport => full && spec.hasRequest
      ? "import '$imports/domain/entities/${name}_request.dart';"
      : '';
  String get requestArgument =>
      spec.hasRequest ? '{required ${type}Request request}' : '';
  String fields(List<FieldSpec> fields, {bool model = false}) => fields
      .map(
        (field) =>
            '${model && field.jsonKey != field.name ? '@JsonKey(name: ${dartLiteral(field.jsonKey)}) ' : ''}${field.nullable ? '' : 'required '}${field.type} ${field.name},',
      )
      .join('\n');
}
