import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'ast_editor.dart';
import 'project.dart';
import 'registry.dart';
import 'transaction.dart';

/// Removes obsolete generated component factories before preview/validation.
/// Components can require arbitrary constructor inputs supplied by feature UI.
/// Custom factories with their own input contracts and unrelated pages survive.
void planComponentPageCleanup(GenerationPlan plan) {
  const path = 'lib/app/composition/feature_pages.dart';
  bool available(String file) => plan.files.containsKey(file)
      ? plan.files[file]!.after != null
      : File(plan.project.file(file)).existsSync();
  if (!available(path) || !available(registryPath)) return;
  final registry = jsonDecode(plan.read(registryPath)) as Map<String, dynamic>;
  final components = (registry['features'] as List)
      .cast<Map<String, dynamic>>()
      .where((entry) => entry['kind'] == 'component');
  if (components.isEmpty) return;
  final original = plan.read(path);
  final parsed = parseString(content: original, throwIfDiagnostics: false);
  if (parsed.errors.isNotEmpty) {
    throw const GenerationException('Cannot repair invalid FeaturePages Dart.');
  }
  final unit = parsed.unit;
  final imports = unit.directives.whereType<ImportDirective>().toList();
  final factoryClass = unit.declarations
      .whereType<ClassDeclaration>()
      .where((node) => node.namePart.typeName.lexeme == 'FeaturePages')
      .singleOrNull;
  if (factoryClass?.body is! BlockClassBody) return;
  final package = plan.project.validate();
  final removed = <String>{};
  final removableImports = <String, Set<String>>{};
  final removedNodes = <String>{};
  for (final entry in components) {
    final name = entry['name'] as String;
    final type = pascalCase(name);
    final root = (entry['path'] as String).substring(4);
    final widgetUris = {
      'package:$package/$root/${name}_widget.dart',
      'package:$package/$root/widgets/${name}_widget.dart',
    };
    final widgetNames = <String>{};
    for (final directive in imports) {
      final uris = [
        directive.uri,
        ...directive.configurations.map((c) => c.uri),
      ];
      if (!uris.every(
        (uri) => widgetUris.contains(
          plan.project.dartUri(path, uri.stringValue ?? ''),
        ),
      )) {
        continue;
      }
      if (directive.combinators.isNotEmpty) continue;
      final prefix = directive.prefix?.name;
      widgetNames.add('${prefix == null ? '' : '$prefix.'}${type}Widget');
      final names = <String>{prefix ?? '${type}Widget'};
      if (prefix == null) {
        for (final uri in uris) {
          final resolved = plan.project.dartUri(path, uri.stringValue!);
          final source =
              'lib/${resolved.substring('package:$package/'.length)}';
          if (available(source)) {
            names.addAll(declaredSymbols(plan.read(source)));
          }
        }
      }
      for (final uri in uris) {
        removableImports[uri.stringValue!] = names;
      }
    }
    final method = (factoryClass!.body as BlockClassBody).members
        .whereType<MethodDeclaration>()
        .where((method) => method.name.lexeme == camelCase(name))
        .singleOrNull;
    // Old generated factories accept only GetIt. Preserve developers' explicit
    // constructor-input contracts instead of deleting arbitrary custom methods.
    if (method == null ||
        !method.isStatic ||
        method.parameters?.parameters.length != 1 ||
        method.body is! ExpressionFunctionBody) {
      continue;
    }
    final parameter = method.parameters!.parameters.single;
    if (parameter is! RegularFormalParameter ||
        parameter.type?.toSource().split('.').last != 'GetIt') {
      continue;
    }
    final expression = (method.body as ExpressionFunctionBody).expression;
    if (!_isComponentFactory(expression, widgetNames)) continue;
    removed.add(method.name.lexeme);
    removedNodes.add('FeaturePages.${method.name.lexeme}');
    final state = entry['state'] as String;
    if (state != 'none') {
      final uri = 'package:$package/$root/$state/${name}_$state.dart';
      for (final directive in imports) {
        if (directive.configurations.isNotEmpty ||
            directive.combinators.isNotEmpty) {
          continue;
        }
        if (plan.project.dartUri(path, directive.uri.stringValue ?? '') ==
            uri) {
          removableImports[directive.uri.stringValue!] = {
            directive.prefix?.name ??
                '$type${state == 'bloc' ? 'Bloc' : 'Cubit'}',
            if (directive.prefix == null &&
                available('lib/$root/$state/${name}_$state.dart'))
              ...declaredSymbols(
                plan.read('lib/$root/$state/${name}_$state.dart'),
              ),
          };
        }
      }
    }
  }
  if (removed.isEmpty) return;
  final editor = AstEditor(original)..removeMembers('FeaturePages', removed);
  final references = _References();
  for (final declaration in parseString(
    content: editor.source,
  ).unit.declarations) {
    declaration.accept(references);
  }
  editor.removeImports((uri) {
    final names = removableImports[uri];
    if (names != null && !names.any(references.names.contains)) return true;
    // Retain the package when another page uses providers or Bloc extensions.
    return uri == 'package:flutter_bloc/flutter_bloc.dart' &&
        !references.names.any(
          (name) =>
              name.contains('Bloc') ||
              name.contains('Cubit') ||
              name.contains('RepositoryProvider') ||
              {'read', 'watch', 'select'}.contains(name),
        );
  });
  plan.write(path, editor.source);
  var registryChanged = false;
  for (final entry in components) {
    final records = entry['integrations'] as List?;
    if (records == null) continue;
    final length = records.length;
    records.removeWhere(
      (record) =>
          record['path'] == path && removedNodes.contains(record['node']),
    );
    registryChanged |= records.length != length;
  }
  if (registryChanged) plan.write(registryPath, prettyJson(registry));
}

bool _isComponentFactory(Expression expression, Set<String> widgets) {
  String? constructor(Expression expression) {
    if (expression is InstanceCreationExpression) {
      final name = expression.constructorName;
      return [
        if (name.type.importPrefix != null) name.type.importPrefix!.name.lexeme,
        name.type.name.lexeme,
        if (name.name != null) name.name!.name,
      ].join('.');
    }
    if (expression is MethodInvocation) {
      return [
        if (expression.target != null) expression.target!.toSource(),
        expression.methodName.name,
      ].join('.');
    }
    return null;
  }

  if (widgets.contains(constructor(expression))) return true;
  final name = constructor(expression);
  if (name != 'BlocProvider' && name != 'BlocProvider.value') return false;
  final Iterable<AstNode> arguments = switch (expression) {
    InstanceCreationExpression() => expression.argumentList.arguments,
    MethodInvocation() => expression.argumentList.arguments,
    _ => <Expression>[],
  };
  return arguments.whereType<NamedArgument>().any(
    (argument) =>
        argument.name.lexeme == 'child' &&
        widgets.contains(constructor(argument.argumentExpression)),
  );
}

class _References extends RecursiveAstVisitor<void> {
  final names = <String>{};
  @override
  void visitNamedType(NamedType node) {
    names.add(node.name.lexeme);
    if (node.importPrefix != null) names.add(node.importPrefix!.name.lexeme);
    super.visitNamedType(node);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    names.add(node.name);
    super.visitSimpleIdentifier(node);
  }
}
