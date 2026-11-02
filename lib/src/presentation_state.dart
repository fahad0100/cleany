import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

import 'project.dart';

/// Preserves existing state contracts; metadata restores missing files in kind.
/// An unnamed Freezed factory is a single state, named factories form a union.
String presentationStateStyle(Project project, Map entry) {
  if (entry['state'] == 'none') return 'union';
  final prefix = entry['kind'] == 'feature' ? 'presentation/' : '';
  final path =
      '${entry['path']}/$prefix${entry['state']}/${entry['name']}_state.dart';
  final file = File(project.file(path));
  if (file.existsSync()) {
    final unit = parseString(
      content: file.readAsStringSync(),
      throwIfDiagnostics: false,
    ).unit;
    final type = '${pascalCase(entry['name'] as String)}State';
    final declaration = unit.declarations
        .whereType<ClassDeclaration>()
        .where((node) => node.namePart.typeName.lexeme == type)
        .singleOrNull;
    if (declaration?.body is BlockClassBody) {
      final factories = (declaration!.body as BlockClassBody).members
          .whereType<ConstructorDeclaration>()
          .where(
            (node) =>
                node.factoryKeyword != null &&
                node.redirectedConstructor != null,
          )
          .toList();
      if (factories.isNotEmpty) {
        if (factories.length != 1 || factories.single.name != null) {
          return 'union';
        }
        final fields = factories.single.parameters.parameters
            .map((p) => p.name?.lexeme)
            .toSet();
        if (fields.containsAll({
          'initialState',
          'successState',
          'errorState',
        })) {
          return 'single';
        }
        return fields.any((field) => field?.endsWith('Status') == true)
            ? 'status'
            : 'single';
      }
    }
  }
  return entry['state_style'] as String? ?? 'union';
}

bool usesSinglePresentationState(Project project, Map entry) =>
    presentationStateStyle(project, entry) != 'union';

/// Preserves the earlier three-field contract while repairing existing sources.
bool usesSplitPresentationState(Project project, Map entry) =>
    presentationStateStyle(project, entry) == 'single';

/// Keeps the public primary field stable when an entry is renamed or recovered.
String primaryPresentationStatus(Project project, Map entry) {
  if (entry['primary_status'] case final String name) return name;
  final prefix = entry['kind'] == 'feature' ? 'presentation/' : '';
  final path =
      '${entry['path']}/$prefix${entry['state']}/${entry['name']}_state.dart';
  final file = File(project.file(path));
  if (file.existsSync()) {
    final unit = parseString(
      content: file.readAsStringSync(),
      throwIfDiagnostics: false,
    ).unit;
    final type = '${pascalCase(entry['name'] as String)}State';
    for (final node in unit.declarations.whereType<ClassDeclaration>()) {
      if (node.namePart.typeName.lexeme != type ||
          node.body is! BlockClassBody) {
        continue;
      }
      for (final factory
          in (node.body as BlockClassBody).members
              .whereType<ConstructorDeclaration>()) {
        if (factory.factoryKeyword == null || factory.name != null) continue;
        for (final parameter in factory.parameters.parameters) {
          final name = parameter.name?.lexeme;
          if (name != null && name.endsWith('Status')) return name;
        }
      }
    }
  }
  return '${camelCase(entry['name'] as String)}Status';
}
