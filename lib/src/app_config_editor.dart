import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'ast_editor.dart';
import 'config_value_spec.dart';
import 'project.dart';
import 'specification.dart';
import 'transaction.dart';
import 'use_case_editor.dart';

const appConfigPath = 'lib/app/config/app_config.dart';

ClassDeclaration _class(String source, String name) =>
    parseString(content: source).unit.declarations
        .whereType<ClassDeclaration>()
        .where((node) => node.namePart.typeName.lexeme == name)
        .single;

String _parameter(
  String source,
  FormalParameterList parameters,
  String name,
  String declaration,
) {
  if (parameters.parameters.any((p) => p.name?.lexeme == name)) return source;
  if (parameters.leftDelimiter?.lexeme == '[') {
    throw const GenerationException(
      'Optional positional config parameters need manual integration.',
    );
  }
  final last = parameters.parameters.lastOrNull;
  final separator = last == null || last.endToken.next?.lexeme == ','
      ? ''
      : ',';
  final offset =
      parameters.rightDelimiter?.offset ?? parameters.rightParenthesis.offset;
  final text = parameters.rightDelimiter == null
      ? '$separator {$declaration}'
      : '$separator $declaration,';
  return source.replaceRange(offset, offset, text);
}

String _arguments(
  String source,
  List<AstNode> calls,
  String name,
  String expression,
) {
  for (final call in calls..sort((a, b) => b.offset.compareTo(a.offset))) {
    final list = call is InstanceCreationExpression
        ? call.argumentList
        : (call as MethodInvocation).argumentList;
    if (list.arguments.whereType<NamedArgument>().any(
      (arg) => arg.name.lexeme == name,
    )) {
      continue;
    }
    final separator =
        list.arguments.isEmpty ||
            list.arguments.last.endToken.next?.lexeme == ','
        ? ''
        : ',';
    source = source.replaceRange(
      list.rightParenthesis.offset,
      list.rightParenthesis.offset,
      '$separator $name: $expression,',
    );
    if (call is InstanceCreationExpression && call.keyword?.lexeme == 'const') {
      source = source.replaceRange(call.keyword!.offset, call.keyword!.end, '');
    }
  }
  return source;
}

class _Calls extends RecursiveAstVisitor<void> {
  _Calls(this.type);
  final String type;
  final calls = <AstNode>[];
  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (node.constructorName.type.toSource() == type &&
        node.constructorName.name == null) {
      calls.add(node);
    }
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.target == null && node.methodName.name == type) calls.add(node);
    super.visitMethodInvocation(node);
  }
}

/// Adds one independent String field using AST positions, keeping custom code.
String addAppConfigField(String source, AppConfigValueSpec spec) {
  var body = _class(source, 'AppConfig').body as BlockClassBody;
  final occupied = {
    for (final member in body.members)
      ...switch (member) {
        FieldDeclaration() => member.fields.variables.map((v) => v.name.lexeme),
        MethodDeclaration() => [member.name.lexeme],
        _ => <String>[],
      },
  };
  if (occupied.contains(spec.field)) {
    throw GenerationException('AppConfig already defines ${spec.field}.');
  }
  final editor = AstEditor(source)
    ..addMembers('AppConfig', 'final String ${spec.field};');
  final constructor = UseCaseEditor(editor.source)
    ..addParameter('AppConfig', spec.field, "this.${spec.field} = ''");
  source = constructor.source;
  body = _class(source, 'AppConfig').body as BlockClassBody;
  final factory = body.members
      .whereType<ConstructorDeclaration>()
      .where(
        (node) =>
            node.factoryKeyword != null &&
            node.name?.lexeme == 'fromEnvironment',
      )
      .singleOrNull;
  if (factory == null || factory.body is! BlockFunctionBody) {
    throw const GenerationException(
      'AppConfig.fromEnvironment needs a supported block factory. Existing code was preserved.',
    );
  }
  source = _parameter(
    source,
    factory.parameters,
    'values',
    'Map<String, Object?> values = const {}',
  );
  final helper = AstEditor(source);
  if (!helper.hasMember('AppConfig', '_cleanyConfigValue')) {
    helper.addMembers('AppConfig', '''
  static String _cleanyConfigValue(Map<String, Object?> values, String key, {String fallback = ''}) {
    final value = values[key];
    if (value == null) { return fallback; }
    if (value is! String) { throw StateError('App configuration values must be strings.'); }
    return value;
  }
''');
  }
  source = helper.source;
  body = _class(source, 'AppConfig').body as BlockClassBody;
  final updated = body.members.whereType<ConstructorDeclaration>().singleWhere(
    (node) =>
        node.factoryKeyword != null && node.name?.lexeme == 'fromEnvironment',
  );
  final visitor = _Calls('AppConfig');
  updated.body.accept(visitor);
  if (visitor.calls.isEmpty) {
    throw const GenerationException(
      'Cannot locate AppConfig construction in its factory. Existing code was preserved.',
    );
  }
  return _arguments(
    source,
    visitor.calls,
    spec.field,
    "const bool.hasEnvironment(${dartLiteral(spec.key)}) ? const String.fromEnvironment(${dartLiteral(spec.key)}) : _cleanyConfigValue(values, ${dartLiteral(spec.yamlKey)})",
  );
}

/// Identifies managed fields when the registry is lost, without copying values.
List<AppConfigValueSpec> discoverConfigValues(String source) {
  final body = _class(source, 'AppConfig').body as BlockClassBody;
  final factory = body.members
      .whereType<ConstructorDeclaration>()
      .where(
        (node) =>
            node.factoryKeyword != null &&
            node.name?.lexeme == 'fromEnvironment',
      )
      .singleOrNull;
  if (factory == null) return [];
  final calls = _Calls('AppConfig');
  factory.body.accept(calls);
  final specs = <String, AppConfigValueSpec>{};
  for (final call in calls.calls) {
    final args = call is InstanceCreationExpression
        ? call.argumentList
        : (call as MethodInvocation).argumentList;
    for (final argument in args.arguments.whereType<NamedArgument>()) {
      final keys = _EnvironmentKeys();
      argument.argumentExpression.accept(keys);
      if (keys.keys.length != 1) continue;
      final key = keys.keys.single;
      if ({'API_BASE_URL', 'DB_SECRET_KEY'}.contains(key)) continue;
      final spec = AppConfigValueSpec(key);
      if (spec.field == argument.name.lexeme) specs[key] = spec;
    }
  }
  return specs.values.toList();
}

/// Find existing compile-time keys even when custom fields use other names.
Set<String> configEnvironmentKeys(String source) {
  final visitor = _EnvironmentKeys();
  parseString(content: source).unit.accept(visitor);
  return visitor.keys;
}

class _EnvironmentKeys extends RecursiveAstVisitor<void> {
  final keys = <String>{};
  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.target?.toSource() == 'String' &&
        node.methodName.name == 'fromEnvironment') {
      if (node.argumentList.arguments.firstOrNull
          case final StringLiteral key) {
        if (key.stringValue != null) keys.add(key.stringValue!);
      }
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final name = node.constructorName.toSource();
    if (name == 'String.fromEnvironment') {
      if (node.argumentList.arguments.firstOrNull
          case final StringLiteral key) {
        if (key.stringValue != null) keys.add(key.stringValue!);
      }
    }
    super.visitInstanceCreationExpression(node);
  }
}

/// Makes old flavor/bootstrap files pass their value map without replacing them.
void planConfigValueInputs(GenerationPlan plan) {
  const flavorPath = 'lib/app/config/flavor_config.dart';
  var source = plan.read(flavorPath);
  final editor = AstEditor(source);
  if (!editor.hasMember('FlavorConfig', 'values')) {
    editor.addMembers('FlavorConfig', 'final Map<String, Object?> values;');
    final edits = UseCaseEditor(editor.source)
      ..addParameter('FlavorConfig', 'values', 'this.values = const {}');
    source = edits.source;
    final body = _class(source, 'FlavorConfig').body as BlockClassBody;
    final load = body.members.whereType<MethodDeclaration>().singleWhere(
      (node) => node.name.lexeme == 'load',
    );
    final vars = _YamlVariables();
    load.body.accept(vars);
    if (vars.names.length != 1) {
      throw const GenerationException(
        'Cannot locate flavor YAML in the custom loader.',
      );
    }
    final calls = _Calls('FlavorConfig');
    load.body.accept(calls);
    if (calls.calls.isEmpty) {
      throw const GenerationException(
        'Cannot locate FlavorConfig construction.',
      );
    }
    source = _arguments(
      source,
      calls.calls,
      'values',
      'Map<String, Object?>.unmodifiable(Map<String, Object?>.from(${vars.names.single}))',
    );
    plan.write(flavorPath, source);
  }
  const bootstrap = 'lib/app/bootstrap.dart';
  source = plan.read(bootstrap);
  final calls = _ConfigFactories();
  parseString(content: source).unit.accept(calls);
  for (final call
      in calls.calls..sort((a, b) => b.offset.compareTo(a.offset))) {
    final list = call is InstanceCreationExpression
        ? call.argumentList
        : (call as MethodInvocation).argumentList;
    if (list.arguments.whereType<NamedArgument>().any(
      (arg) => arg.name.lexeme == 'values',
    )) {
      continue;
    }
    final base = list.arguments
        .whereType<NamedArgument>()
        .where((arg) => arg.name.lexeme == 'fallbackBaseUrl')
        .singleOrNull;
    final expression = base?.argumentExpression.toSource();
    if (expression == null || !expression.endsWith('.apiBaseUrl')) {
      throw const GenerationException(
        'Connect flavor.values to the custom bootstrap AppConfig factory before adding values.',
      );
    }
    final target = expression.substring(
      0,
      expression.length - '.apiBaseUrl'.length,
    );
    source = _arguments(source, [call], 'values', '$target.values');
  }
  if (calls.calls.isEmpty) {
    throw const GenerationException(
      'Cannot locate AppConfig.fromEnvironment in bootstrap.',
    );
  }
  plan.write(bootstrap, source);
}

class _YamlVariables extends RecursiveAstVisitor<void> {
  final names = <String>{};
  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    final value = node.initializer;
    if (value is MethodInvocation && value.methodName.name == 'loadYaml') {
      names.add(node.name.lexeme);
    }
    super.visitVariableDeclaration(node);
  }
}

class _ConfigFactories extends RecursiveAstVisitor<void> {
  final calls = <AstNode>[];
  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (node.constructorName.toSource() == 'AppConfig.fromEnvironment') {
      calls.add(node);
    }
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.target?.toSource() == 'AppConfig' &&
        node.methodName.name == 'fromEnvironment') {
      calls.add(node);
    }
    super.visitMethodInvocation(node);
  }
}
