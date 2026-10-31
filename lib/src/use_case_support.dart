import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

import 'project.dart';
import 'specification.dart';
import 'templates/feature_context.dart';

Map<String, String> _fields(String source, String type) {
  final unit = parseString(content: source, throwIfDiagnostics: false).unit;
  final declaration = unit.declarations
      .whereType<ClassDeclaration>()
      .where((node) => node.namePart.typeName.lexeme == type)
      .singleOrNull;
  if (declaration?.body is! BlockClassBody) {
    throw GenerationException('Expected an existing $type class.');
  }
  final constructor = (declaration!.body as BlockClassBody).members
      .whereType<ConstructorDeclaration>()
      .where((node) => node.name == null)
      .singleOrNull;
  if (constructor == null) {
    throw GenerationException('Expected one unnamed constructor for $type.');
  }
  final result = <String, String>{};
  for (final parameter in constructor.parameters.parameters) {
    if (parameter is! RegularFormalParameter ||
        parameter.name == null ||
        parameter.type == null) {
      throw GenerationException(
        'An explicit model/entity mapper is required for customized $type constructors.',
      );
    }
    result[parameter.name!.lexeme] = parameter.type!.toSource();
  }
  return result;
}

/// Captures the current feature fields instead of recreating its Entity/Model.
/// Nonmatching types need an explicit mapper rather than a guessed conversion.
List<String> existingEntityMappingFields(
  Project project,
  FeatureTemplateContext c,
) {
  final entity = _fields(
    project.read('${c.path}/domain/entities/${c.name}_entity.dart'),
    '${c.type}Entity',
  );
  final model = _fields(
    project.read('${c.path}/data/models/${c.name}_model.dart'),
    '${c.type}Model',
  );
  for (final field in entity.entries) {
    if (model[field.key] != field.value) {
      throw GenerationException(
        'Model/Entity field ${field.key} needs an explicit mapper before adding this use case.',
      );
    }
  }
  return entity.keys.toList();
}

/// Reconstructs only recognizable generated operation contracts after registry loss.
List<UseCaseSpec> discoverUseCases(
  Project project,
  String path,
  String featureName,
) {
  final directory = Directory(project.file('$path/domain/usecases'));
  if (!directory.existsSync()) return [];
  final result = <UseCaseSpec>[];
  for (final file in directory.listSync(followLinks: false).whereType<File>()) {
    final name = file.uri.pathSegments.last;
    if (!name.endsWith('.dart') || name == 'get_$featureName.dart') continue;
    final operationName = name.substring(0, name.length - 5);
    try {
      final unit = parseString(
        content: file.readAsStringSync(),
        throwIfDiagnostics: false,
      ).unit;
      for (final declaration
          in unit.declarations.whereType<ClassDeclaration>()) {
        if (declaration.namePart.typeName.lexeme != pascalCase(operationName) ||
            declaration.body is! BlockClassBody) {
          continue;
        }
        final call = (declaration.body as BlockClassBody).members
            .whereType<MethodDeclaration>()
            .where((method) => method.name.lexeme == 'call')
            .singleOrNull;
        final returnType = call?.returnType;
        if (returnType is! NamedType ||
            returnType.name.lexeme != 'Future' ||
            returnType.typeArguments?.arguments.length != 1) {
          continue;
        }
        final wrapped = returnType.typeArguments!.arguments.single;
        if (wrapped is! NamedType ||
            wrapped.name.lexeme != 'Result' ||
            wrapped.typeArguments?.arguments.length != 2 ||
            wrapped.typeArguments!.arguments.last.toSource() != 'Failure') {
          continue;
        }
        final value = wrapped.typeArguments!.arguments.first.toSource();
        if (value != 'void' && value != '${pascalCase(featureName)}Entity') {
          continue;
        }
        // Registry recovery adopts only the fixed no-argument forwarding shape.
        // A shared feature repository's existence alone does not establish ownership.
        final body = call?.body;
        if (call == null ||
            call.parameters?.parameters.isNotEmpty != false ||
            body is! ExpressionFunctionBody ||
            body.expression is! MethodInvocation) {
          continue;
        }
        final invocation = body.expression as MethodInvocation;
        if (invocation.target?.toSource() != '_repository' ||
            invocation.methodName.name != camelCase(operationName) ||
            invocation.argumentList.arguments.isNotEmpty) {
          continue;
        }
        final repositoryTypes = (declaration.body as BlockClassBody).members
            .whereType<FieldDeclaration>()
            .where(
              (field) => field.fields.variables.any(
                (variable) => variable.name.lexeme == '_repository',
              ),
            )
            .map((field) => field.fields.type?.toSource().split('.').last)
            .toList();
        if (repositoryTypes.length != 1) continue;
        final repositoryType = repositoryTypes.single;
        final sharedType = '${pascalCase(featureName)}Repository';
        final legacyType = '${pascalCase(operationName)}Repository';
        if (repositoryType != sharedType && repositoryType != legacyType) {
          continue;
        }
        final legacy = repositoryType != sharedType;
        if (!File(
          project.file(
            '$path/domain/repositories/${legacy ? operationName : featureName}_repository.dart',
          ),
        ).existsSync()) {
          continue;
        }
        result.add(
          UseCaseSpec(
            name: operationName,
            repositoryBinding: legacy
                ? UseCaseRepositoryBinding.operation
                : UseCaseRepositoryBinding.feature,
            returnType: value == 'void'
                ? UseCaseReturnType.voidResult
                : UseCaseReturnType.entity,
          ),
        );
      }
    } on GenerationException {
      // Unknown domain files stay user-owned and are never guessed into metadata.
    }
  }
  return result;
}
