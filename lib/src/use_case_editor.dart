import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'project.dart';

class _SourceEdit {
  _SourceEdit(this.start, this.end, this.text);
  final int start;
  final int end;
  final String text;
}

/// Narrow additive edits for operation injection and common Freezed state fields.
/// Existing expressions and named arguments are preserved, never regenerated.
class UseCaseEditor {
  UseCaseEditor(this.source);
  String source;

  CompilationUnit get _unit {
    final result = parseString(content: source, throwIfDiagnostics: false);
    if (result.errors.isNotEmpty) {
      throw const GenerationException('Cannot add a use case to invalid Dart.');
    }
    return result.unit;
  }

  BlockClassBody _body(String name) {
    final declaration = _unit.declarations
        .whereType<ClassDeclaration>()
        .where((node) => node.namePart.typeName.lexeme == name)
        .singleOrNull;
    if (declaration?.body is! BlockClassBody) {
      throw GenerationException('Expected a supported class body: $name');
    }
    return declaration!.body as BlockClassBody;
  }

  void _apply(List<_SourceEdit> edits) {
    for (final edit in edits..sort((a, b) => b.start.compareTo(a.start))) {
      source = source.replaceRange(edit.start, edit.end, edit.text);
    }
  }

  /// Resolves a repository dependency by its declared type, preserving field renames.
  String dependencyField(String className, String type) {
    final fields = _body(className).members
        .whereType<FieldDeclaration>()
        .where((field) => field.fields.type?.toSource().split('.').last == type)
        .expand(
          (field) =>
              field.fields.variables.map((variable) => variable.name.lexeme),
        )
        .toList();
    if (fields.length != 1) {
      throw GenerationException(
        'Expected one $type field in $className before extending its repository.',
      );
    }
    return fields.single;
  }

  /// Adds an optional named parameter to the unnamed controller constructor,
  /// or to every redirecting factory of a Freezed union.
  void addParameter(
    String className,
    String name,
    String declaration, {
    bool factories = false,
  }) {
    final constructors = _body(className).members
        .whereType<ConstructorDeclaration>()
        .where(
          (node) => factories
              ? node.factoryKeyword != null &&
                    node.redirectedConstructor != null
              : node.factoryKeyword == null && node.name == null,
        )
        .toList();
    if (constructors.isEmpty || (!factories && constructors.length != 1)) {
      throw GenerationException(
        'Expected ${factories ? 'Freezed factories' : 'one unnamed constructor'} in $className.',
      );
    }
    final edits = <_SourceEdit>[];
    for (final constructor in constructors) {
      final parameters = constructor.parameters;
      if (parameters.parameters.whereType<RegularFormalParameter>().any(
        (parameter) => parameter.name?.lexeme == name,
      )) {
        throw GenerationException('Existing $className parameter: $name');
      }
      if (parameters.leftDelimiter?.lexeme == '[') {
        throw GenerationException(
          'Optional positional parameters in $className need manual migration before adding a use case.',
        );
      }
      final last = parameters.parameters.lastOrNull;
      final separator = last == null || last.endToken.next?.lexeme == ','
          ? ''
          : ',';
      final offset =
          parameters.rightDelimiter?.offset ??
          parameters.rightParenthesis.offset;
      final text = parameters.rightDelimiter == null
          ? '$separator {$declaration}'
          : '$separator $declaration,';
      edits.add(_SourceEdit(offset, offset, text));
    }
    _apply(edits);
  }

  /// Registers a Bloc handler inside its existing constructor body.
  void addConstructorStatement(String className, String statement) {
    final constructor = _body(className).members
        .whereType<ConstructorDeclaration>()
        .where((node) => node.factoryKeyword == null && node.name == null)
        .single;
    final body = constructor.body;
    if (body is! BlockFunctionBody) {
      throw GenerationException(
        'The $className constructor needs a block body for Bloc registration.',
      );
    }
    _apply([
      _SourceEdit(
        body.block.rightBracket.offset,
        body.block.rightBracket.offset,
        '\n$statement\n',
      ),
    ]);
  }

  /// Preserves all operation statuses through existing primary state changes.
  void preserveStatuses(
    String controller,
    String stateType,
    List<String> fields,
  ) {
    final visitor = _ConstructorCalls(stateType);
    for (final method in _body(
      controller,
    ).members.whereType<MethodDeclaration>().where((node) => !node.isStatic)) {
      method.body.accept(visitor);
    }
    _addArguments(visitor.calls, {
      for (final field in fields) field: 'state.$field',
    });
  }

  /// Installs lazy operation dependencies before the controller registration,
  /// including when a customized controller is registered eagerly.
  void ensureRegistrations(
    String controller,
    Map<String, String> declarations,
  ) {
    final function = _unit.declarations
        .whereType<FunctionDeclaration>()
        .where((node) => node.name.lexeme == 'registerFeatureDependencies')
        .singleOrNull;
    if (function?.functionExpression.body is! BlockFunctionBody) {
      throw const GenerationException(
        'Use case DI integration requires a block function body.',
      );
    }
    final found = _RegisteredTypes();
    function!.accept(found);
    final missing = declarations.entries
        .where((entry) => !found.types.contains(entry.key))
        .map((entry) => entry.value)
        .join('\n');
    if (missing.isEmpty) return;
    final registrations = _ControllerRegistrations(controller);
    function.accept(registrations);
    if (registrations.calls.length != 1) {
      throw GenerationException(
        'Expected one DI registration for $controller.',
      );
    }
    final registration = registrations.calls.single;
    final body = function.functionExpression.body as BlockFunctionBody;
    final anchor = body.block.statements
        .where(
          (statement) =>
              statement.offset <= registration.offset &&
              statement.end >= registration.end,
        )
        .singleOrNull;
    if (anchor == null) {
      throw GenerationException(
        'Cannot safely locate $controller registration.',
      );
    }
    _apply([_SourceEdit(anchor.offset, anchor.offset, '$missing\n')]);
  }

  /// Adds dependencies only to constructor calls inside the controller's DI
  /// registration, preserving custom factories and existing argument values.
  void injectController(String controller, Map<String, String> arguments) {
    if (arguments.isEmpty) return;
    final function = _unit.declarations
        .whereType<FunctionDeclaration>()
        .where((node) => node.name.lexeme == 'registerFeatureDependencies')
        .singleOrNull;
    if (function == null) {
      throw const GenerationException(
        'Missing registerFeatureDependencies function.',
      );
    }
    final registrations = _ControllerRegistrations(controller);
    function.accept(registrations);
    if (registrations.calls.length != 1) {
      throw GenerationException(
        'Expected one DI registration for $controller; existing custom code was preserved.',
      );
    }
    final constructors = _ConstructorCalls(controller);
    registrations.calls.single.argumentList.accept(constructors);
    if (constructors.calls.isEmpty) {
      throw GenerationException(
        'Cannot locate $controller construction inside its DI factory. Connect its use cases manually before retrying.',
      );
    }
    _addArguments(constructors.calls, arguments);
  }

  void _addArguments(List<AstNode> calls, Map<String, String> arguments) {
    final edits = <_SourceEdit>[];
    for (final node in calls) {
      final list = node is InstanceCreationExpression
          ? node.argumentList
          : (node as MethodInvocation).argumentList;
      final existing = list.arguments
          .whereType<NamedArgument>()
          .map((arg) => arg.name.lexeme)
          .toSet();
      final added = arguments.entries
          .where((entry) => !existing.contains(entry.key))
          .toList();
      if (added.isEmpty) continue;
      final separator =
          list.arguments.isEmpty ||
              list.arguments.last.endToken.next?.lexeme == ','
          ? ''
          : ',';
      edits.add(
        _SourceEdit(
          list.rightParenthesis.offset,
          list.rightParenthesis.offset,
          '$separator ${added.map((entry) => '${entry.key}: ${entry.value},').join(' ')}',
        ),
      );
      if (node is InstanceCreationExpression &&
          node.keyword?.lexeme == 'const') {
        edits.add(_SourceEdit(node.keyword!.offset, node.keyword!.end, ''));
      }
    }
    _apply(edits);
  }
}

class _ConstructorCalls extends RecursiveAstVisitor<void> {
  _ConstructorCalls(this.type);
  final String type;
  final calls = <AstNode>[];
  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final parts = node.constructorName.type.toSource().split('.');
    // Unresolved analyzer ASTs can project `const State.loading()` as a
    // prefixed type `State.loading`, rather than a named constructor.
    if (parts.last == type ||
        (node.constructorName.name == null &&
            parts.length > 1 &&
            parts[parts.length - 2] == type)) {
      calls.add(node);
    }
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.target?.toSource().split('.').last == type ||
        node.methodName.name == type) {
      calls.add(node);
    }
    super.visitMethodInvocation(node);
  }
}

class _ControllerRegistrations extends RecursiveAstVisitor<void> {
  _ControllerRegistrations(this.type);
  final String type;
  final calls = <MethodInvocation>[];
  @override
  void visitMethodInvocation(MethodInvocation node) {
    if ({
          'registerFactory',
          'registerLazySingleton',
          'registerSingleton',
        }.contains(node.methodName.name) &&
        node.typeArguments?.arguments.any(
              (arg) => arg.toSource().split('.').last == type,
            ) ==
            true) {
      calls.add(node);
    }
    super.visitMethodInvocation(node);
  }
}

class _RegisteredTypes extends RecursiveAstVisitor<void> {
  final types = <String>{};
  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name.startsWith('register')) {
      types.addAll(
        node.typeArguments?.arguments.map(
              (arg) => arg.toSource().split('.').last,
            ) ??
            <String>[],
      );
    }
    super.visitMethodInvocation(node);
  }
}
