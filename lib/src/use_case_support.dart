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
        parameter.type == null ||
        !parameter.isNamed) {
      throw GenerationException(
        'An explicit model/entity mapper is required for customized $type constructors.',
      );
    }
    result[parameter.name!.lexeme] = parameter.type!.toSource();
  }
  return result;
}

/// Source identity of an existing Domain Entity; no new Entity is generated.
class ExistingEntity {
  const ExistingEntity(this.type, this.path);
  final String type;
  final String path;
}

/// Finds a public Entity class in Domain. Ambiguous names require a source path.
ExistingEntity resolveExistingEntity(
  Project project,
  String name, {
  String? preferredPath,
}) {
  final requested = name.trim();
  final isPath = requested.startsWith('lib/') && requested.endsWith('.dart');
  if (isPath) project.file(requested);
  final matches = <ExistingEntity>[];
  final lib = Directory(project.file('lib'));
  for (final file
      in lib.listSync(recursive: true, followLinks: false).whereType<File>()) {
    final path = file.path
        .substring(project.root.length + 1)
        .replaceAll('\\', '/');
    if (!path.contains('/domain/entities/') ||
        !path.endsWith('.dart') ||
        path.endsWith('.freezed.dart') ||
        path.endsWith('.g.dart') ||
        (isPath && path != requested)) {
      continue;
    }
    final parsed = parseString(
      content: file.readAsStringSync(),
      throwIfDiagnostics: false,
    );
    if (parsed.errors.isNotEmpty ||
        parsed.unit.directives.any((d) => d is PartOfDirective)) {
      continue;
    }
    final type = isPath
        ? null
        : (requested.contains('_') ? pascalCase(requested) : requested);
    for (final declaration
        in parsed.unit.declarations.whereType<ClassDeclaration>()) {
      final className = declaration.namePart.typeName.lexeme;
      if (!className.startsWith('_') && (type == null || className == type)) {
        matches.add(ExistingEntity(className, path));
      }
    }
  }
  final preferred = matches
      .where((entity) => entity.path == preferredPath)
      .toList();
  if (preferred.length == 1) return preferred.single;
  if (matches.length != 1) {
    throw GenerationException(
      matches.isEmpty
          ? 'Existing Domain Entity not found: $name.'
          : 'Ambiguous Entity $name. Enter its lib/.../domain/entities/...dart source path.',
    );
  }
  return matches.single;
}

/// Compatible flat fields retain their mapping; customized shapes get a typed
/// developer connection hook rather than a guessed conversion or blocked plan.
List<String>? existingEntityMappingFields(
  Project project,
  FeatureTemplateContext c, {
  ExistingEntity? selected,
}) {
  try {
    final entity = _fields(
      project.read(
        selected?.path ?? '${c.path}/domain/entities/${c.name}_entity.dart',
      ),
      selected?.type ?? '${c.type}Entity',
    );
    final model = _fields(
      project.read('${c.path}/data/models/${c.name}_model.dart'),
      '${c.type}Model',
    );
    if (entity.isEmpty ||
        entity.entries.any((field) => model[field.key] != field.value)) {
      return null;
    }
    return entity.keys.toList();
  } on GenerationException {
    return null;
  }
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
        ExistingEntity? entity;
        if (value != 'void') {
          try {
            entity = resolveExistingEntity(
              project,
              value,
              preferredPath: '$path/domain/entities/${featureName}_entity.dart',
            );
          } on GenerationException {
            continue;
          }
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
            entityType: entity?.type,
            entityPath: entity?.path,
            mappingPending:
                entity != null &&
                File(
                  project.file(
                    '$path/data/repositories/${featureName}_repository_impl.dart',
                  ),
                ).existsSync() &&
                project
                    .read(
                      '$path/data/repositories/${featureName}_repository_impl.dart',
                    )
                    .contains('_map${pascalCase(operationName)}Entity('),
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
