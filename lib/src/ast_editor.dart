import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'project.dart';

/// Resolve insertion points from parsed Dart nodes, never brace counting or
/// textual signatures. Unexpected structures fail before any project write.
class AstEditor {
  AstEditor(this.source, {String Function(String)? resolveUri})
    : _resolveUri = resolveUri ?? _identityUri;
  final String Function(String) _resolveUri;
  static String _identityUri(String uri) => uri;
  String source;

  /// Repair adds absent nodes and preserves all existing custom expressions.
  bool repairMissing = false;

  CompilationUnit get _unit {
    final parsed = parseString(content: source, throwIfDiagnostics: false);
    if (parsed.errors.isNotEmpty) {
      throw const GenerationException('Cannot integrate into invalid Dart.');
    }
    return parsed.unit;
  }

  void addImports(Iterable<String> paths) {
    final unit = _unit;
    final existing = unit.directives
        .whereType<ImportDirective>()
        .where(
          (directive) =>
              directive.prefix == null && directive.combinators.isEmpty,
        )
        .map((directive) => _resolveUri(directive.uri.stringValue ?? ''))
        .toSet();
    final added = paths
        .where((path) => !existing.contains(_resolveUri(path)))
        .toSet();
    if (added.isEmpty) return;
    final directives = unit.directives;
    if (directives.any((d) => d is PartOfDirective)) {
      throw const GenerationException('Cannot add imports to a part file.');
    }
    // Imports must precede part directives and exports. Insert after the final
    // import or library directive, preserving a leading library declaration.
    final anchors = directives.where(
      (d) => d is ImportDirective || d is LibraryDirective,
    );
    final offset = anchors.isNotEmpty
        ? anchors.last.end
        : (directives.isNotEmpty
              ? directives.first.offset
              : (unit.declarations.isNotEmpty
                    ? unit.declarations.first.offset
                    : source.length));
    _insert(offset, '\n${added.map((p) => "import '$p';").join('\n')}\n');
  }

  bool usesUnqualified(String symbol) {
    var token = _unit.beginToken;
    while (!token.isEof) {
      if (token.lexeme == symbol && token.previous?.lexeme != '.') return true;
      token = token.next!;
    }
    return false;
  }

  void addStatements(String functionName, String statements) {
    final matches = _unit.declarations
        .whereType<FunctionDeclaration>()
        .where((node) => node.name.lexeme == functionName)
        .toList();
    if (matches.length != 1) {
      throw GenerationException('Expected one function: $functionName');
    }
    final function = matches.single;
    if (repairMissing) {
      final existing = _RegistrationVisitor((_) => true);
      function.accept(existing);
      final registered = existing.calls
          .where((call) => call.methodName.name.startsWith('register'))
          .expand(
            (call) =>
                call.typeArguments?.arguments.map(
                  (type) => type.toSource().split('.').last,
                ) ??
                <String>[],
          )
          .toSet();
      final candidate =
          parseString(content: 'void candidate() { $statements }')
                  .unit
                  .declarations
                  .single
              as FunctionDeclaration;
      final body = candidate.functionExpression.body as BlockFunctionBody;
      statements = body.block.statements
          .where((statement) {
            final visitor = _RegistrationVisitor(
              (call) => call.methodName.name.startsWith('register'),
            );
            statement.accept(visitor);
            return !visitor.calls.any(
              (call) =>
                  call.typeArguments?.arguments.any(
                    (type) =>
                        registered.contains(type.toSource().split('.').last),
                  ) ??
                  false,
            );
          })
          .map((node) => node.toSource())
          .join('\n');
      if (statements.trim().isEmpty) return;
    }
    final body = function.functionExpression.body;
    if (body is BlockFunctionBody) {
      _insert(body.block.rightBracket.offset, '\n$statements\n');
    } else if (body is ExpressionFunctionBody &&
        (body.expression is MethodInvocation ||
            body.expression is AwaitExpression)) {
      final future =
          function.returnType?.toSource().startsWith('Future') == true;
      final expression = body.expression.toSource();
      source = source.replaceRange(
        body.offset,
        body.end,
        '${future ? 'async ' : ''}{ ${future && body.expression is! AwaitExpression ? 'await ' : ''}$expression;\n$statements\n}',
      );
    } else {
      throw GenerationException(
        'Unsupported function body: $functionName. No files were changed.',
      );
    }
  }

  void addMembers(String className, String members) {
    final matches = _unit.declarations
        .whereType<ClassDeclaration>()
        .where((node) => node.namePart.typeName.lexeme == className)
        .toList();
    if (matches.length != 1) {
      throw GenerationException('Expected one class: $className');
    }
    final body = matches.single.body;
    if (body is! BlockClassBody) {
      throw GenerationException('Expected a class body: $className');
    }
    final added =
        parseString(content: 'class Candidate { $members }')
                .unit
                .declarations
                .single
            as ClassDeclaration;
    Set<String> names(BlockClassBody body) => body.members.expand((node) {
      if (node is MethodDeclaration) return [node.name.lexeme];
      if (node is ConstructorDeclaration && node.name != null) {
        return [node.name!.lexeme];
      }
      if (node is FieldDeclaration) {
        return node.fields.variables.map((v) => v.name.lexeme);
      }
      return <String>[];
    }).toSet();
    final overlap = names(body)
        .intersection(names(added.body as BlockClassBody));
    if (overlap.isNotEmpty && repairMissing) return;
    if (overlap.isNotEmpty) {
      throw GenerationException(
        'Existing $className member: ${overlap.join(', ')}',
      );
    }
    _insert(body.rightBracket.offset, '\n$members\n');
  }

  void ensureFunction(String name, String declaration) {
    if (!_unit.declarations.whereType<FunctionDeclaration>().any(
      (node) => node.name.lexeme == name,
    )) {
      source = '$source\n$declaration\n';
    }
  }

  ListLiteral _routeList() {
    final functions = _unit.declarations
        .whereType<FunctionDeclaration>()
        .where((node) => node.name.lexeme == 'buildRoutes')
        .toList();
    if (functions.length != 1) {
      throw const GenerationException(
        'Expected one buildRoutes function. Doctor can recreate a missing router.',
      );
    }
    final function = functions.single;
    final body = function.functionExpression.body;
    final locals = <String, Expression>{};
    for (final declaration
        in _unit.declarations.whereType<TopLevelVariableDeclaration>()) {
      for (final variable in declaration.variables.variables) {
        if (variable.initializer != null) {
          locals[variable.name.lexeme] = variable.initializer!;
        }
      }
    }
    if (body is BlockFunctionBody) {
      for (final statement
          in body.block.statements.whereType<VariableDeclarationStatement>()) {
        for (final variable in statement.variables.variables) {
          if (variable.initializer != null) {
            locals[variable.name.lexeme] = variable.initializer!;
          }
        }
      }
    }
    Expression? expression = body is ExpressionFunctionBody
        ? body.expression
        : null;
    if (body is BlockFunctionBody) {
      final returns = body.block.statements
          .whereType<ReturnStatement>()
          .toList();
      if (returns.length == 1) expression = returns.single.expression;
    }
    final seen = <String>{};
    while (expression is SimpleIdentifier && seen.add(expression.name)) {
      expression = locals[expression.name];
    }
    if (expression is ParenthesizedExpression) {
      expression = expression.expression;
    }
    if (expression is PrefixedIdentifier || expression is PropertyAccess) {
      final owner = expression is PrefixedIdentifier
          ? expression.prefix.name
          : (expression as PropertyAccess).target?.toSource();
      final member = expression is PrefixedIdentifier
          ? expression.identifier.name
          : (expression as PropertyAccess).propertyName.name;
      for (final declaration
          in _unit.declarations.whereType<ClassDeclaration>()) {
        if (declaration.namePart.typeName.lexeme != owner ||
            declaration.body is! BlockClassBody) {
          continue;
        }
        for (final field
            in (declaration.body as BlockClassBody).members
                .whereType<FieldDeclaration>()) {
          final variable = field.fields.variables
              .where((value) => value.name.lexeme == member)
              .singleOrNull;
          if (variable?.initializer is ListLiteral) {
            expression = variable!.initializer;
          }
        }
      }
    }
    if (expression is! ListLiteral) {
      throw const GenerationException(
        'Routes must resolve to a list literal (direct, returned, or stored in a variable). No code was changed.',
      );
    }
    return expression;
  }

  void addRoutes(String routes) {
    if (repairMissing) {
      final candidate = RegExp(r'RouteNames\.(\w+)')
          .firstMatch(routes)
          ?.group(1);
      if (candidate != null &&
          _unit.toSource().contains(
            RegExp('(?:RouteNames|FeaturePages)\\.$candidate\\b'),
          )) {
        return;
      }
    }
    final list = _routeList();
    final separator =
        list.elements.isEmpty || list.elements.last.endToken.next?.lexeme == ','
        ? ''
        : ',';
    _insert(list.rightBracket.offset, '$separator\n$routes\n');
  }

  bool hasMember(String className, String name) {
    for (final declaration
        in _unit.declarations.whereType<ClassDeclaration>()) {
      if (declaration.namePart.typeName.lexeme != className ||
          declaration.body is! BlockClassBody) {
        continue;
      }
      for (final member in (declaration.body as BlockClassBody).members) {
        if (member is MethodDeclaration && member.name.lexeme == name) {
          return true;
        }
        if (member is FieldDeclaration &&
            member.fields.variables.any((v) => v.name.lexeme == name)) {
          return true;
        }
      }
    }
    return false;
  }

  /// Stable node ownership records; a differing digest denotes user customization.
  Map<String, String> integrationNodes() {
    final nodes = <String, String>{};
    for (final declaration in _unit.declarations) {
      if (declaration is ClassDeclaration &&
          declaration.body is BlockClassBody) {
        for (final member in (declaration.body as BlockClassBody).members) {
          if (member is MethodDeclaration) {
            nodes['${declaration.namePart.typeName.lexeme}.${member.name.lexeme}'] =
                member.toSource();
          }
          if (member is FieldDeclaration) {
            for (final v in member.fields.variables) {
              nodes['${declaration.namePart.typeName.lexeme}.${v.name.lexeme}'] =
                  member.toSource();
            }
          }
        }
      }
    }
    final routesFunction = _unit.declarations
        .whereType<FunctionDeclaration>()
        .where((f) => f.name.lexeme == 'buildRoutes');
    if (routesFunction.isNotEmpty) {
      for (final element in _routeList().elements) {
        final match = RegExp(r'(?:RouteNames|FeaturePages)\.(\w+)')
            .firstMatch(element.toSource());
        if (match != null) nodes['Router.${match[1]}'] = element.toSource();
      }
    }
    final visitor = _RegistrationVisitor(
      (call) => call.methodName.name.startsWith('register'),
    );
    _unit.accept(visitor);
    for (final call in visitor.calls) {
      for (final type in call.typeArguments?.arguments ?? <TypeAnnotation>[]) {
        nodes['DI.${type.toSource().split('.').last}'] = call.toSource();
      }
    }
    return nodes;
  }

  void requireUnusedRoutePath(String path) {
    final visitor = _RoutePathVisitor(path);
    _unit.accept(visitor);
    if (visitor.found) {
      throw GenerationException('Route path already exists: $path');
    }
  }

  /// Removes only imports owned by the selected registry entries.
  void removeImports(bool Function(String uri) matches) {
    final nodes = <ImportDirective>[];
    for (final node in _unit.directives.whereType<ImportDirective>()) {
      final uris = [
        node.uri.stringValue ?? '',
        ...node.configurations.map((c) => c.uri.stringValue ?? ''),
      ];
      if (!uris.any(matches)) continue;
      if (!uris.every(matches)) {
        throw const GenerationException(
          'A conditional import mixes owned and unrelated libraries; split it before removing the entry.',
        );
      }
      nodes.add(node);
    }
    _removeNodes(nodes);
  }

  void removeRegistrations(Set<String> types) {
    final function = _unit.declarations
        .whereType<FunctionDeclaration>()
        .where((node) => node.name.lexeme == 'registerFeatureDependencies')
        .singleOrNull;
    if (function == null) return;
    final body = function.functionExpression.body;
    bool owned(MethodInvocation call) =>
        {
          'registerFactory',
          'registerLazySingleton',
          'registerSingleton',
        }.contains(call.methodName.name) &&
        call.typeArguments?.arguments.any(
              (type) => types.contains(type.toSource()),
            ) ==
            true;
    if (body is ExpressionFunctionBody) {
      if (body.expression is MethodInvocation &&
          owned(body.expression as MethodInvocation)) {
        final async =
            function.returnType?.toSource().startsWith('Future') == true
            ? 'async '
            : '';
        source = source.replaceRange(body.offset, body.end, '$async{}');
      }
      return;
    }
    if (body is! BlockFunctionBody) {
      throw const GenerationException('Unsupported DI body.');
    }
    final statements = body.block.statements
        .whereType<ExpressionStatement>()
        .where(
          (node) =>
              node.expression is MethodInvocation &&
              owned(node.expression as MethodInvocation),
        )
        .toList();
    final visitor = _RegistrationVisitor(owned);
    body.accept(visitor);
    if (visitor.calls.length != statements.length) {
      throw const GenerationException(
        'Conditional or nested DI registrations require manual review; their conditions were preserved.',
      );
    }
    _removeNodes(statements);
  }

  void removeMembers(String className, Set<String> members) {
    final declaration = _unit.declarations
        .whereType<ClassDeclaration>()
        .where((node) => node.namePart.typeName.lexeme == className)
        .single;
    final body = declaration.body;
    if (body is! BlockClassBody) {
      throw const GenerationException('Cannot safely remove class members.');
    }
    final selected = <AstNode>[];
    for (final node in body.members) {
      if (node is MethodDeclaration && members.contains(node.name.lexeme)) {
        selected.add(node);
      }
      if (node is FieldDeclaration &&
          node.fields.variables.any((v) => members.contains(v.name.lexeme))) {
        if (node.fields.variables.length != 1) {
          throw const GenerationException(
            'Split combined route declarations before removing a feature.',
          );
        }
        selected.add(node);
      }
    }
    _removeNodes(selected);
  }

  void removeRoutes(Set<String> members) {
    final list = _routeList();
    final nodes = list.elements.where((element) {
      final arguments = switch (element) {
        InstanceCreationExpression() => element.argumentList,
        MethodInvocation() when element.methodName.name == 'GoRoute' =>
          element.argumentList,
        _ => null,
      };
      if (arguments == null) return false;
      return arguments.arguments.whereType<NamedArgument>().any((argument) {
        if (argument.name.lexeme != 'path') return false;
        final expression = argument.argumentExpression;
        return (expression is PrefixedIdentifier &&
                expression.prefix.name == 'RouteNames' &&
                members.contains(expression.identifier.name)) ||
            (expression is PropertyAccess &&
                expression.target is SimpleIdentifier &&
                (expression.target as SimpleIdentifier).name == 'RouteNames' &&
                members.contains(expression.propertyName.name));
      });
    }).toList();
    _removeNodes(nodes, commas: true);
  }

  void _removeNodes(List<AstNode> nodes, {bool commas = false}) {
    for (final node in nodes..sort((a, b) => b.offset.compareTo(a.offset))) {
      final start = node is AnnotatedNode && node.documentationComment != null
          ? node.documentationComment!.offset
          : node.offset;
      final end = commas && node.endToken.next?.lexeme == ','
          ? node.endToken.next!.end
          : node.end;
      source = source.replaceRange(start, end, '');
    }
  }

  void _insert(int offset, String text) {
    source = source.replaceRange(offset, offset, text);
  }
}

class _RoutePathVisitor extends RecursiveAstVisitor<void> {
  _RoutePathVisitor(this.path);
  final String path;
  bool found = false;
  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    if (node.value == path) found = true;
  }
}

class _RegistrationVisitor extends RecursiveAstVisitor<void> {
  _RegistrationVisitor(this.owned);
  final bool Function(MethodInvocation) owned;
  final calls = <MethodInvocation>[];
  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (owned(node)) calls.add(node);
    super.visitMethodInvocation(node);
  }
}

/// Shared public declaration policy used by generation and rename collisions.
Set<String> declaredSymbols(String source) =>
    parseString(content: source, throwIfDiagnostics: false).unit.declarations
        .expand(
          (node) => switch (node) {
            ClassDeclaration() => [node.namePart.typeName.lexeme],
            EnumDeclaration() => [node.namePart.typeName.lexeme],
            MixinDeclaration() => [node.name.lexeme],
            GenericTypeAlias() => [node.name.lexeme],
            FunctionTypeAlias() => [node.name.lexeme],
            FunctionDeclaration() => [node.name.lexeme],
            TopLevelVariableDeclaration() => node.variables.variables.map(
              (v) => v.name.lexeme,
            ),
            _ => <String>[],
          },
        )
        .where((name) => !name.startsWith('_'))
        .toSet();

/// Public Freezed redirect targets participate in additional-operation collisions.
Set<String> redirectedSymbols(String source) =>
    parseString(content: source, throwIfDiagnostics: false).unit.declarations
        .whereType<ClassDeclaration>()
        .where((node) => node.body is BlockClassBody)
        .expand(
          (node) => (node.body as BlockClassBody).members
              .whereType<ConstructorDeclaration>(),
        )
        .map(
          (node) =>
              node.redirectedConstructor?.type.toSource().split('<').first,
        )
        .whereType<String>()
        .where((name) => !name.startsWith('_'))
        .toSet();
