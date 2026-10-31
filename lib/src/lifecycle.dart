import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dart_style/dart_style.dart';
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
    if (p.posix.normalize(destination) != destination ||
        !p.posix.isWithin('lib', destination) ||
        destination
            .split('/')
            .any((part) => !RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(part))) {
      throw const GenerationException(
        'Choose a snake_case parent directory inside lib.',
      );
    }
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
      if (!entries.any(
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
    // Detect collisions before changing any URI or symbol.
    if (newName != name) {
      for (final file in _dartFiles()) {
        final relative = p
            .relative(file.path, from: project.root)
            .split(p.separator)
            .join('/');
        if (paths.containsKey(relative)) continue;
        final declarations = parseString(
          content: file.readAsStringSync(),
          throwIfDiagnostics: false,
        ).unit.declarations;
        for (final declaration in declarations.whereType<ClassDeclaration>()) {
          if (symbols.values.contains(declaration.namePart.typeName.lexeme)) {
            throw GenerationException(
              'Symbol collision in $relative: ${declaration.namePart.typeName.lexeme}',
            );
          }
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
        plan.write(newPath, transformed, createOnly: oldPath != newPath);
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
    final oldMember = camelCase(oldName);
    final newMember = camelCase(newName);
    final visitor = _RenameVisitor(oldMember, newMember, edits);
    parsed.unit.accept(visitor);
    var token = parsed.unit.beginToken;
    while (!token.isEof) {
      if (symbols.containsKey(token.lexeme)) {
        edits.add(_Edit(token.offset, token.end, symbols[token.lexeme]!));
      }
      token = token.next!;
    }
    for (final directive in parsed.unit.directives) {
      final uri = switch (directive) {
        ImportDirective() => directive.uri,
        ExportDirective() => directive.uri,
        PartDirective() => directive.uri,
        PartOfDirective() => directive.uri,
        _ => null,
      };
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
    final unique = <int, _Edit>{for (final edit in edits) edit.start: edit};
    for (final edit
        in unique.values.toList()..sort((a, b) => b.start.compareTo(a.start))) {
      source = source.replaceRange(edit.start, edit.end, edit.text);
    }
    return DartFormatter(languageVersion: DartFormatter.latestLanguageVersion)
        .format(source);
  }
}

class _RenameVisitor extends RecursiveAstVisitor<void> {
  _RenameVisitor(this.oldName, this.newName, this.edits);
  final String oldName;
  final String newName;
  final List<_Edit> edits;
  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    final parent = node.parent;
    if (node.name == oldName &&
        parent is PrefixedIdentifier &&
        {'RouteNames', 'FeaturePages'}.contains(parent.prefix.name)) {
      edits.add(_Edit(node.offset, node.end, newName));
    }
    if (node.name == oldName &&
        parent is PropertyAccess &&
        {'RouteNames', 'FeaturePages'}.contains(parent.target?.toSource())) {
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
        node.target is SimpleIdentifier &&
        {
          'FeaturePages',
          'RouteNames',
        }.contains((node.target as SimpleIdentifier).name)) {
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
