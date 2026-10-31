import 'dart:io';
import 'dart:convert';

import 'ast_editor.dart';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:path/path.dart' as p;

import 'project.dart';
import 'registry.dart';
import 'specification.dart';
import 'transaction.dart';

class _Edit {
  const _Edit(this.start, this.end, this.text);
  final int start;
  final int end;
  final String text;
}

/// Refactors known generated symbols and URI directives while preserving payloads.
class FeatureLifecycle {
  /// Creates a refactoring planner for [project].
  FeatureLifecycle(this.project);

  /// Project whose known generated symbols and owned paths are refactored.
  final Project project;
  final _exposedSymbols = <String, Set<String>>{};

  /// Plans a rename, move, or both, including nested registered entries.
  ///
  /// Rewrites known Dart identifiers and URI directives inside supported source
  /// roots. Backend endpoint strings are preserved. Review the plan and apply
  /// through [GenerationTransaction] to catch unresolved references.
  GenerationPlan renameMove({
    required String name,
    required GenerationKind kind,
    String? newName,
    String? destination,
  }) {
    _exposedSymbols.clear();
    final package = project.validate();
    final registry = FeatureRegistry(project).read();
    final entries = (registry['features'] as List).cast<Map<String, dynamic>>();
    final selected = entries
        .where((entry) => entry['name'] == name && entry['kind'] == kind.name)
        .singleOrNull;
    if (selected == null) {
      throw const GenerationException('The selected entry no longer exists.');
    }
    newName ??= name;
    validateName(newName);
    if (newName != name &&
        entries.any(
          (entry) =>
              pascalCase(entry['name'] as String) == pascalCase(newName!),
        )) {
      throw GenerationException('The name is already registered: $newName');
    }
    final oldRoot = selected['path'] as String;
    destination ??= p.posix.dirname(oldRoot);
    validateEntryDirectory(destination);
    final newRoot = '$destination/$newName';
    project.file(newRoot);
    if (newRoot == oldRoot) {
      throw const GenerationException('The name and location are unchanged.');
    }
    if (p.posix.isWithin(oldRoot, newRoot)) {
      throw const GenerationException(
        'An entry cannot be moved inside itself.',
      );
    }
    if (FileSystemEntity.typeSync(project.file(newRoot), followLinks: false) !=
        FileSystemEntityType.notFound) {
      throw GenerationException('Destination already exists: $newRoot');
    }
    final plan = GenerationPlan(project);
    final paths = <String, String>{};
    final operationFiles = {
      for (final entry in entries)
        for (final operation in entryUseCases(entry)) ...[
          '${entry['path']}/domain/usecases/${operation.name}.dart',
          if (!operation.usesFeatureRepository)
            '${entry['path']}/domain/repositories/${operation.name}_repository.dart',
          if (!operation.usesFeatureRepository)
            '${entry['path']}/data/repositories/${operation.name}_repository_impl.dart',
        ],
    };
    for (final entity in Directory(
      project.file(oldRoot),
    ).listSync(recursive: true, followLinks: false)) {
      final relative = p
          .relative(entity.path, from: project.root)
          .split(p.separator)
          .join('/');
      project.file(relative);
      if (entity is Directory) {
        plan.directoriesToRemove.add(relative);
        continue;
      }
      if (entity is! File) continue;
      var target = '$newRoot${relative.substring(oldRoot.length)}';
      final basename = p.posix.basename(target);
      // Rename only this entry's filenames, not nested feature names.
      if (!operationFiles.contains(relative) &&
          !entries.any(
            (entry) =>
                entry != selected &&
                p.posix.isWithin(entry['path'] as String, relative),
          )) {
        if (basename.startsWith('${name}_')) {
          target = p.posix.join(
            p.posix.dirname(target),
            '$newName${basename.substring(name.length)}',
          );
        }
        if (basename == 'get_$name.dart') {
          target = p.posix.join(p.posix.dirname(target), 'get_$newName.dart');
        }
      }
      paths[relative] = target;
    }
    for (final owned in selected['files'] as List) {
      final path = owned['path'] as String;
      if (!p.posix.isWithin(oldRoot, path) &&
          File(project.file(path)).existsSync()) {
        final basename = p.posix.basename(path);
        paths[path] = p.posix.join(
          p.posix.dirname(path),
          '$newName${basename.substring(name.length)}',
        );
      }
    }
    final oldType = pascalCase(name);
    final newType = pascalCase(newName);
    final symbols = <String, String>{};
    for (final suffix in [
      'Entity',
      'Model',
      'Request',
      'Api',
      'RemoteDataSource',
      'Repository',
      'RepositoryImpl',
      'Cubit',
      'Bloc',
      'State',
      'Event',
      'Page',
      'Widget',
      'Initial',
      'Loading',
      'Success',
      'Failure',
      'Updated',
      'Requested',
    ]) {
      symbols['$oldType$suffix'] = '$newType$suffix';
      symbols['_$oldType$suffix'] = '_$newType$suffix';
      symbols['_\$$oldType$suffix'] = '_\$$newType$suffix';
    }
    symbols['_\$${oldType}ModelFromJson'] = '_\$${newType}ModelFromJson';
    symbols['_\$${oldType}ModelToJson'] = '_\$${newType}ModelToJson';
    symbols['Get$oldType'] = 'Get$newType';
    symbols['_get$oldType'] = '_get$newType';
    for (final operation in entryUseCases(selected)) {
      symbols['$oldType${operation.type}Requested'] =
          '$newType${operation.type}Requested';
    }
    // Detect collisions before changing any URI or symbol.
    if (newName != name) {
      for (final file in _dartFiles()) {
        final relative = p
            .relative(file.path, from: project.root)
            .split(p.separator)
            .join('/');
        final overlap = declaredSymbols(file.readAsStringSync())
            .intersection(symbols.values.toSet());
        if (overlap.isNotEmpty) {
          throw GenerationException(
            'Symbol collision in $relative: ${overlap.join(', ')}',
          );
        }
      }
    }
    for (final file in _dartFiles()) {
      final oldPath = p
          .relative(file.path, from: project.root)
          .split(p.separator)
          .join('/');
      final newPath = paths[oldPath] ?? oldPath;
      final original = file.readAsStringSync();
      final transformed = _transform(
        original,
        oldPath,
        newPath,
        paths,
        symbols,
        package,
        name,
        newName,
      );
      if (oldPath != newPath) plan.delete(oldPath);
      if (transformed != original || oldPath != newPath) {
        plan.write(
          newPath,
          transformed,
          createOnly: oldPath != newPath,
          mode: file.statSync().mode & 0x1ff,
        );
      }
    }
    for (final entry in paths.entries.where(
      (entry) => !entry.key.endsWith('.dart'),
    )) {
      plan.delete(entry.key);
      plan.writeBytes(
        entry.value,
        File(project.file(entry.key)).readAsBytesSync(),
        createOnly: true,
        mode: File(project.file(entry.key)).statSync().mode & 0x1ff,
      );
    }
    plan.directoriesToRemove.add(oldRoot);
    for (final entry in entries) {
      final path = entry['path'] as String;
      if (path == oldRoot || p.posix.isWithin(oldRoot, path)) {
        entry['path'] = '$newRoot${path.substring(oldRoot.length)}';
      }
      if (entry['parent'] == name) entry['parent'] = newName;
      if (identical(entry, selected)) {
        entry['name'] = newName;
        final parents =
            entries
                .where(
                  (candidate) =>
                      candidate != selected &&
                      candidate['kind'] == 'feature' &&
                      p.posix.isWithin(
                        '${candidate['path']}/subfeatures',
                        newRoot,
                      ),
                )
                .toList()
              ..sort(
                (a, b) => (b['path'] as String).length.compareTo(
                  (a['path'] as String).length,
                ),
              );
        if (parents.isEmpty) {
          entry.remove('parent');
        } else {
          entry['parent'] = parents.first['name'];
        }
        final spec = Map<String, dynamic>.from(
          entry['specification'] as Map? ?? {},
        );
        // Renaming a feature must not silently change its backend endpoint.
        if (spec['endpoint'] == null) spec['endpoint'] = '/$name';
        entry['specification'] = spec;
      }
      final owned = (entry['files'] as List).cast<Map<String, dynamic>>();
      for (final item in owned) {
        item['path'] = paths[item['path']] ?? item['path'];
        item['owner'] = entry['name'];
        final planned = plan.files[item['path']];
        if (planned?.after != null) {
          item['sha256'] = contentDigest(planned!.after!);
        }
      }
    }
    // Preserve the baseline identity of each owned composition node after a
    // rename. Customized nodes retain their previous digest for later review.
    for (final entry in entries) {
      for (final raw in entry['integrations'] as List? ?? []) {
        final record = raw as Map;
        final path = record['path'] as String;
        final oldNode = record['node'] as String;
        var newNode = oldNode;
        if (identical(entry, selected)) {
          if (oldNode.startsWith('DI.')) {
            final oldSymbol = oldNode.substring(3);
            newNode = 'DI.${symbols[oldSymbol] ?? oldSymbol}';
          } else if (oldNode.endsWith('.${camelCase(name)}')) {
            newNode =
                '${oldNode.substring(0, oldNode.lastIndexOf('.') + 1)}${camelCase(newName)}';
          }
        }
        final before = AstEditor(project.read(path))
            .integrationNodes()[oldNode];
        final after = AstEditor(plan.read(path)).integrationNodes()[newNode];
        if (before != null &&
            after != null &&
            contentDigest(utf8.encode(before)) == record['sha256']) {
          record['sha256'] = contentDigest(utf8.encode(after));
        }
        record['node'] = newNode;
        record['owner'] = entry['name'];
      }
    }
    registry['template_version'] = templateVersion;
    plan.write(registryPath, prettyJson(registry));
    return plan;
  }

  Iterable<File> _dartFiles() sync* {
    for (final root in ['lib', 'test', 'integration_test', 'tool']) {
      final directory = Directory(project.file(root));
      if (!directory.existsSync()) continue;
      for (final file
          in directory
              .listSync(recursive: true, followLinks: false)
              .whereType<File>()) {
        if (file.path.endsWith('.dart')) yield file;
      }
    }
  }

  String _transform(
    String source,
    String oldPath,
    String newPath,
    Map<String, String> paths,
    Map<String, String> symbols,
    String package,
    String oldName,
    String newName,
  ) {
    final parsed = parseString(content: source, throwIfDiagnostics: false);
    if (parsed.errors.isNotEmpty) {
      throw GenerationException(
        'Invalid Dart in $oldPath; fix syntax before refactoring.',
      );
    }
    final edits = <_Edit>[];
    String? localTarget(String value) {
      if (value.startsWith('package:$package/')) {
        return 'lib/${value.substring('package:$package/'.length)}';
      }
      if (value.contains(':')) return null;
      return p.posix.normalize(p.posix.join(p.posix.dirname(oldPath), value));
    }

    Set<String> exposed(String target, [Set<String>? visited]) {
      if (_exposedSymbols.containsKey(target)) {
        return {..._exposedSymbols[target]!};
      }
      visited ??= {};
      if (!visited.add(target)) return {};
      final file = File(project.file(target));
      if (!file.existsSync()) return {};
      final unit = parseString(
        content: file.readAsStringSync(),
        throwIfDiagnostics: false,
      ).unit;
      final result = <String>{};
      for (final node in unit.declarations) {
        if (paths.containsKey(target)) {
          if (node is ClassDeclaration) {
            result.add(node.namePart.typeName.lexeme);
            if (node.body is BlockClassBody) {
              for (final constructor
                  in (node.body as BlockClassBody).members
                      .whereType<ConstructorDeclaration>()) {
                final redirected = constructor.redirectedConstructor?.type
                    .toSource();
                if (redirected != null) result.add(redirected);
              }
            }
          }
          if (node is FunctionDeclaration) result.add(node.name.lexeme);
        }
      }
      for (final directive
          in unit.directives
              .where((d) => d is ExportDirective || d is PartDirective)
              .cast<UriBasedDirective>()) {
        final uri = directive.uri.stringValue;
        if (uri == null || uri.startsWith('dart:')) continue;
        final nested = uri.startsWith('package:$package/')
            ? 'lib/${uri.substring('package:$package/'.length)}'
            : uri.contains(':')
            ? null
            : p.posix.normalize(p.posix.join(p.posix.dirname(target), uri));
        if (nested != null) result.addAll(exposed(nested, visited));
      }
      _exposedSymbols[target] = {...result};
      return result;
    }

    final own = paths.containsKey(oldPath);
    final imported = <String>{};
    final prefixes = <String, Set<String>>{};
    final foreignPrefixes = <String>{};
    final compositionOwners = <String>{
      if (oldPath == 'lib/app/router/route_names.dart') 'RouteNames',
      if (oldPath == 'lib/app/composition/feature_pages.dart') 'FeaturePages',
    };
    for (final directive
        in parsed.unit.directives.whereType<ImportDirective>()) {
      final uri = directive.uri.stringValue;
      if (uri == null) continue;
      final target = localTarget(uri);
      if (target == null) {
        if (directive.prefix != null) {
          foreignPrefixes.add(directive.prefix!.name);
        }
        continue;
      }
      if (target == 'lib/app/router/route_names.dart' ||
          target == 'lib/app/composition/feature_pages.dart') {
        final owner = target.endsWith('route_names.dart')
            ? 'RouteNames'
            : 'FeaturePages';
        compositionOwners.add(
          directive.prefix == null ? owner : '${directive.prefix!.name}.$owner',
        );
      }
      final names = exposed(target)
        ..removeWhere((name) => name.startsWith('_'));
      for (final combinator in directive.combinators) {
        if (combinator is ShowCombinator) {
          names.retainAll(combinator.shownNames.map((n) => n.name));
        }
        if (combinator is HideCombinator) {
          names.removeAll(combinator.hiddenNames.map((n) => n.name));
        }
      }
      if (directive.prefix == null) {
        imported.addAll(names);
      } else {
        prefixes.putIfAbsent(directive.prefix!.name, () => {}).addAll(names);
      }
      // Conditional alternatives must expose the same owned declarations.
      for (final configuration in directive.configurations) {
        final alternative = localTarget(configuration.uri.stringValue ?? '');
        if (alternative != null && !exposed(alternative).containsAll(names)) {
          if (names.intersection(symbols.keys.toSet()).isNotEmpty) {
            throw GenerationException(
              'Conditional import in $oldPath mixes owned and external symbols; review it before renaming.',
            );
          }
        }
      }
    }
    // Local declarations shadow imports. Never rename an unrelated declaration.
    if (!own) {
      for (final node in parsed.unit.declarations) {
        if (node is ClassDeclaration) {
          imported.remove(node.namePart.typeName.lexeme);
        }
        if (node is FunctionDeclaration) imported.remove(node.name.lexeme);
      }
    }
    if (!own) {
      final shadows = _ShadowedNames(imported);
      parsed.unit.accept(shadows);
      if (shadows.names.isNotEmpty) {
        throw GenerationException(
          'Ambiguous local names in $oldPath: ${shadows.names.join(', ')}. Rename these local bindings before refactoring.',
        );
      }
    }
    final oldMember = camelCase(oldName);
    final newMember = camelCase(newName);
    if (compositionOwners.isNotEmpty) {
      parsed.unit.accept(
        _RenameVisitor(oldMember, newMember, edits, compositionOwners),
      );
    }
    var token = parsed.unit.beginToken;
    while (!token.isEof) {
      if (symbols.containsKey(token.lexeme)) {
        final prefix = token.previous?.lexeme == '.'
            ? token.previous?.previous?.lexeme
            : null;
        final bound =
            (own &&
                (prefix == null ||
                    (!foreignPrefixes.contains(prefix) &&
                        !prefixes.containsKey(prefix)))) ||
            (prefix == null
                ? imported.contains(token.lexeme)
                : prefixes[prefix]?.contains(token.lexeme) == true);
        if (bound) {
          edits.add(_Edit(token.offset, token.end, symbols[token.lexeme]!));
        }
      }
      token = token.next!;
    }
    for (final directive in parsed.unit.directives) {
      final uris = <StringLiteral?>[
        switch (directive) {
          ImportDirective() => directive.uri,
          ExportDirective() => directive.uri,
          PartDirective() => directive.uri,
          PartOfDirective() => directive.uri,
          _ => null,
        },
        if (directive is ImportDirective)
          ...directive.configurations.map((c) => c.uri),
        if (directive is ExportDirective)
          ...directive.configurations.map((c) => c.uri),
      ];
      for (final uri in uris) {
        final value = uri?.stringValue;
        if (uri == null ||
            value == null ||
            value.startsWith('dart:') ||
            (value.startsWith('package:') &&
                !value.startsWith('package:$package/'))) {
          continue;
        }
        final packageUri = value.startsWith('package:');
        final target = packageUri
            ? 'lib/${value.substring('package:$package/'.length)}'
            : p.posix.normalize(p.posix.join(p.posix.dirname(oldPath), value));
        var moved = paths[target];
        if (moved == null) {
          for (final suffix in ['.freezed.dart', '.g.dart']) {
            if (!target.endsWith(suffix)) continue;
            final sourcePath =
                '${target.substring(0, target.length - suffix.length)}.dart';
            final renamedSource = paths[sourcePath];
            if (renamedSource != null) {
              moved =
                  '${renamedSource.substring(0, renamedSource.length - 5)}$suffix';
            }
          }
        }
        moved ??= target;
        final rewritten = packageUri
            ? 'package:$package/${moved.substring(4)}'
            : p.posix.relative(moved, from: p.posix.dirname(newPath));
        if (rewritten != value) {
          edits.add(_Edit(uri.offset, uri.end, dartLiteral(rewritten)));
        }
      }
    }
    final unique = <int, _Edit>{for (final edit in edits) edit.start: edit};
    for (final edit
        in unique.values.toList()..sort((a, b) => b.start.compareTo(a.start))) {
      source = source.replaceRange(edit.start, edit.end, edit.text);
    }
    return source;
  }
}

class _RenameVisitor extends RecursiveAstVisitor<void> {
  _RenameVisitor(this.oldName, this.newName, this.edits, this.owners);
  final Set<String> owners;
  final String oldName;
  final String newName;
  final List<_Edit> edits;
  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    final parent = node.parent;
    if (node.name == oldName &&
        parent is PrefixedIdentifier &&
        owners.contains(parent.prefix.name)) {
      edits.add(_Edit(node.offset, node.end, newName));
    }
    if (node.name == oldName &&
        parent is PropertyAccess &&
        owners.contains(parent.target?.toSource())) {
      edits.add(_Edit(node.offset, node.end, newName));
    }
    super.visitSimpleIdentifier(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final parent = node.parent?.parent;
    if (node.name.lexeme == oldName &&
        parent is ClassDeclaration &&
        parent.namePart.typeName.lexeme == 'FeaturePages') {
      edits.add(_Edit(node.name.offset, node.name.end, newName));
    }
    super.visitMethodDeclaration(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == oldName &&
        owners.contains(node.target?.toSource())) {
      edits.add(_Edit(node.methodName.offset, node.methodName.end, newName));
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    final parent = node.parent?.parent;
    if (parent is ClassDeclaration &&
        parent.namePart.typeName.lexeme == 'RouteNames') {
      for (final variable in node.fields.variables.where(
        (v) => v.name.lexeme == oldName,
      )) {
        edits.add(_Edit(variable.name.offset, variable.name.end, newName));
        final initializer = variable.initializer;
        if (initializer is SimpleStringLiteral &&
            initializer.value == '/${_snake(oldName)}') {
          edits.add(
            _Edit(
              initializer.offset,
              initializer.end,
              dartLiteral('/${_snake(newName)}'),
            ),
          );
        }
      }
    }
    super.visitFieldDeclaration(node);
  }

  String _snake(String value) =>
      value.replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]!.toLowerCase()}');
}

class _ShadowedNames extends RecursiveAstVisitor<void> {
  _ShadowedNames(this.imported);
  final Set<String> imported;
  final names = <String>{};
  void check(String? name) {
    if (name != null && imported.contains(name)) names.add(name);
  }

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    check(node.name.lexeme);
    super.visitVariableDeclaration(node);
  }

  @override
  void visitRegularFormalParameter(RegularFormalParameter node) {
    check(node.name?.lexeme);
    super.visitRegularFormalParameter(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    check(node.name.lexeme);
    super.visitMethodDeclaration(node);
  }
}
