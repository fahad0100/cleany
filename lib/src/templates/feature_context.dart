import '../project.dart';
import '../specification.dart';

import 'package:path/path.dart' as p;

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
    this.localComponentScope = true,
    this.singleState = true,
    this.splitPrimaryState = false,
    this.primaryStatusName,
  }) : spec = specification ?? FeatureSpec();
  final String name;
  final String path;
  final String package;
  final GenerationKind kind;
  final StateManagement state;
  final ApiProvider provider;
  final FeatureSpec spec;
  final bool legacyComponentWidgets;
  final bool localComponentScope;
  final bool singleState;
  final bool splitPrimaryState;
  final String? primaryStatusName;
  String get primaryStatus => primaryStatusName ?? '${camelCase(name)}Status';
  String get type => pascalCase(name);
  bool get full => kind == GenerationKind.feature;
  bool get stateful => state != StateManagement.none;
  bool get bloc => state == StateManagement.bloc;
  String get mode => state.name;
  String get controller => '$type${bloc ? 'Bloc' : 'Cubit'}';
  String get imports => 'package:$package/${path.substring(4)}';
  String get core => 'package:$package/core';

  /// Treats package and relative imports of the same source as one library.
  String canonicalImport(String from, String uri) {
    if (uri.contains(':')) return uri;
    final path = p.posix.normalize(p.posix.join(p.posix.dirname(from), uri));
    return path.startsWith('lib/')
        ? 'package:$package/${path.substring(4)}'
        : path;
  }

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
