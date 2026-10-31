import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'command_runner.dart';
import 'project.dart';
import 'operation.dart';
import 'project_lock.dart';
import 'workspace.dart';
import 'journal_store.dart';
import 'environment_config.dart';
import 'registry.dart';
import 'specification.dart';

/// Original and proposed contents for one recoverable file change.
class PlannedFile {
  /// Uses null for a missing original or a proposed deletion.
  PlannedFile(this.before, this.after, {this.beforeMode, this.afterMode});

  /// POSIX permission bits captured with the original and validated output.
  final int? beforeMode;
  final int? afterMode;

  /// Original bytes, or null if the file did not exist when planned.
  final List<int>? before;

  /// Proposed bytes, or null to delete the file.
  final List<int>? after;
}

/// Compares nullable file snapshots by content.
bool sameBytes(List<int>? a, List<int>? b) {
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// A reviewable set of changes that has not yet been applied.
class GenerationPlan {
  /// Starts an empty plan against [project].
  GenerationPlan(this.project);

  /// Canonical project to which this plan or transaction belongs.
  final Project project;

  /// File paths and their original/proposed snapshots.
  final files = <String, PlannedFile>{};

  /// Directories pruned only when empty after the planned file operations.
  final directoriesToRemove = <String>{};

  /// Native platform folders explicitly included in isolated validation.
  final platformRoots = <String>{};

  /// Additional commands executed in staging before analysis.
  final commands = <PlannedCommand>[];

  /// Temporary staging-only text overrides restored before output collection.
  final stageOverrides = <String, String>{};

  /// Deletions share the same snapshots, staging, and rollback as writes.
  void delete(String relative) {
    relative = p.posix.normalize(relative);
    final target = File(project.file(relative));
    final before = files.containsKey(relative)
        ? files[relative]!.before
        : (target.existsSync() ? target.readAsBytesSync() : null);
    if (before != null) {
      files[relative] = PlannedFile(
        before,
        null,
        beforeMode:
            files[relative]?.beforeMode ??
            (target.existsSync() ? target.statSync().mode & 0x1ff : null),
      );
    }
    if (before == null) files.remove(relative);
  }

  /// Plans a UTF-8 text write; [createOnly] protects an existing target.
  void write(
    String relative,
    String content, {
    bool createOnly = false,
    int? mode,
  }) {
    writeBytes(
      relative,
      utf8.encode(content),
      createOnly: createOnly,
      mode: mode,
    );
  }

  /// Plans binary contents while preserving the original snapshot for undo.
  void writeBytes(
    String relative,
    List<int> content, {
    bool createOnly = false,
    int? mode,
  }) {
    relative = p.posix.normalize(relative);
    final target = File(project.file(relative));
    final type = FileSystemEntity.typeSync(target.path, followLinks: false);
    if (type != FileSystemEntityType.notFound &&
        type != FileSystemEntityType.file) {
      throw GenerationException('Expected a regular file: $relative');
    }
    final before = files.containsKey(relative)
        ? files[relative]!.before
        : (target.existsSync() ? target.readAsBytesSync() : null);
    if (createOnly && (before != null || files.containsKey(relative))) {
      throw GenerationException('File already exists: $relative');
    }
    final beforeMode =
        files[relative]?.beforeMode ??
        (target.existsSync() ? target.statSync().mode & 0x1ff : null);
    mode ??= files[relative]?.afterMode ?? beforeMode;
    if (!sameBytes(before, content) || beforeMode != mode) {
      files[relative] = PlannedFile(
        before,
        List.unmodifiable(content),
        beforeMode: beforeMode,
        afterMode: mode,
      );
    } else {
      files.remove(relative);
    }
  }

  /// Archives one file, sharing its immutable snapshot with a planned removal.
  /// This avoids reading and retaining two copies during an archived reset.
  void archive(String source, String destination, {required bool remove}) {
    final file = File(project.file(source));
    final target = File(project.file(destination));
    if (FileSystemEntity.typeSync(target.path, followLinks: false) !=
        FileSystemEntityType.notFound) {
      throw GenerationException(
        'Archive destination already exists: $destination',
      );
    }
    final bytes = List<int>.unmodifiable(file.readAsBytesSync());
    final mode = file.statSync().mode & 0x1ff;
    files[destination] = PlannedFile(null, bytes, afterMode: mode);
    if (remove) files[source] = PlannedFile(bytes, null, beforeMode: mode);
  }

  /// Reads proposed text when present, otherwise the current project file.
  String read(String relative) => files.containsKey(relative)
      ? utf8.decode(
          files[relative]!.after ??
              (throw GenerationException(
                'File is planned for removal: $relative',
              )),
        )
      : project.read(relative);

  /// Returns a source diff for library consumers; the CLI uses file summaries.
  String preview() {
    final output = StringBuffer();
    for (final entry in files.entries) {
      output.writeln(
        '--- ${entry.value.before == null ? '/dev/null' : entry.key}',
      );
      output.writeln(
        '+++ ${entry.value.after == null ? '/dev/null' : entry.key}',
      );
      // Complete-file unified hunks also expose changes to existing integrations.
      final before = entry.value.before == null
          ? <String>[]
          : const LineSplitter().convert(
              utf8.decode(entry.value.before!, allowMalformed: true),
            );
      final after = entry.value.after == null
          ? <String>[]
          : const LineSplitter().convert(
              utf8.decode(entry.value.after!, allowMalformed: true),
            );
      output.writeln(
        '@@ -${before.isEmpty ? 0 : 1},${before.length} +${after.isEmpty ? 0 : 1},${after.length} @@',
      );
      for (final line in before) {
        output.writeln('-$line');
      }
      for (final line in after) {
        output.writeln('+$line');
      }
    }
    return output.toString();
  }
}

/// One staged executable invocation, supplied without shell interpolation.
class PlannedCommand {
  /// Stores the executable and its argument vector.
  const PlannedCommand(this.executable, this.arguments);

  /// Executable name resolved using the process environment.
  final String executable;

  /// Individual arguments passed to the executable.
  final List<String> arguments;
}

/// Isolated validation followed by a durable per-file commit and recoverable undo.
class GenerationTransaction {
  /// Creates a transaction with optional command injection and progress context.
  GenerationTransaction(
    this.project, {
    this.executor = executeCommand,
    OperationContext? context,
  }) : context = context ?? OperationContext();

  /// Canonical project to which this plan or transaction belongs.
  final Project project;

  /// Command boundary used for package, build, analysis, and native operations.
  final CommandExecutor executor;

  /// Deadline, cancellation token, and progress observer for this operation.
  final OperationContext context;

  /// Project-relative location of the durable interrupted-operation journal.
  static const journalPath = '.cleany/transaction';
  bool _recoveredCommitted = false;

  /// Validates a plan in isolation, then applies it with per-file recovery.
  ///
  /// Keep [install], [build], and [analyze] enabled for real project operations.
  /// Disabling them is intended for controlled fixtures or external validation.
  /// Concurrent edits and unresolved recovery journals prevent application.
  Future<OperationResult> apply(
    GenerationPlan plan, {
    bool install = true,
    bool build = true,
    bool analyze = true,
    void Function(String path)? beforeWrite,
  }) async {
    if (plan.project.root != project.root) {
      throw const GenerationException('The plan belongs to another project.');
    }
    final snapshots = Map<List<int>, List<int>>.identity();
    List<int>? freeze(List<int>? bytes) => bytes == null
        ? null
        : snapshots.putIfAbsent(bytes, () => List.unmodifiable(bytes));
    final frozen = GenerationPlan(project)
      ..directoriesToRemove.addAll(plan.directoriesToRemove)
      ..platformRoots.addAll(plan.platformRoots)
      ..stageOverrides.addAll(plan.stageOverrides)
      ..commands.addAll(
        plan.commands.map(
          (command) => PlannedCommand(
            command.executable,
            List.unmodifiable(command.arguments),
          ),
        ),
      );
    for (final entry in plan.files.entries) {
      frozen.files[entry.key] = PlannedFile(
        freeze(entry.value.before),
        freeze(entry.value.after),
        beforeMode: entry.value.beforeMode,
        afterMode: entry.value.afterMode,
      );
    }
    plan = frozen;
    final lock = await ProjectLock.acquire(project);
    StagedWorkspace? workspace;
    var committed = false;
    try {
      if (Directory(project.file(journalPath)).existsSync()) {
        throw const GenerationException(
          'An interrupted operation remains. Choose recovery before applying new changes.',
        );
      }
      await StagedWorkspace.cleanOrphans(project);
      context.cancellation.check();
      _verify(plan);
      if (install || build || analyze || plan.commands.isNotEmpty) {
        if (plan.files['lib/app/config/app_environment.dart']?.after != null ||
            File(project.file('lib/app/config/app_environment.dart'))
                .existsSync()) {
          for (final environment in ['dev', 'uat', 'prod']) {
            final path = 'config/flavors/$environment.yaml';
            if (!plan.files.containsKey(path) &&
                !File(project.file(path)).existsSync()) {
              throw GenerationException(
                'Missing $path. Run Project doctor before generation.',
              );
            }
            validatePublicFlavor(plan.read(path), environment, path);
          }
        }
        if (identical(executor, executeCommand)) await _validateToolchain();
        context.report('staging');
        workspace = StagedWorkspace(
          project,
          context,
          platforms: plan.platformRoots,
        );
        final explicitTargets = plan.files.keys.toSet();
        final baseline = await workspace.create();
        final stage = workspace.directory;
        for (final entry in plan.files.entries) {
          final file = File(p.join(stage.path, entry.key));
          if (entry.value.after == null) {
            if (file.existsSync()) file.deleteSync();
          } else {
            file.parent.createSync(recursive: true);
            file.writeAsBytesSync(entry.value.after!);
            setFileMode(file, entry.value.afterMode);
          }
        }
        final manifestContents = <String, String>{};
        for (final name in ['pubspec.yaml', 'pubspec_overrides.yaml']) {
          final file = File(p.join(stage.path, name));
          if (file.existsSync()) {
            manifestContents[name] = file.readAsStringSync();
          }
        }
        final dependencyPaths = _rebasePathDependencies(stage);
        for (final entry in plan.stageOverrides.entries) {
          project.file(entry.key);
          File(p.join(stage.path, entry.key)).writeAsStringSync(entry.value);
        }
        if (install) {
          await _run('flutter', ['pub', 'get'], stage.path);
          if (File(p.join(stage.path, 'l10n.yaml')).existsSync()) {
            await _run('flutter', ['gen-l10n'], stage.path);
          }
        }
        if (build) {
          await _run('dart', [
            'run',
            'build_runner',
            'build',
            '--delete-conflicting-outputs',
          ], stage.path);
        }
        for (final command in plan.commands) {
          await _run(command.executable, command.arguments, stage.path);
        }
        _restoreLockPaths(stage, dependencyPaths);
        for (final entry in plan.stageOverrides.entries) {
          File(p.join(stage.path, entry.key))
              .writeAsStringSync(plan.read(entry.key));
        }
        final beforeAnalysis = await workspace.snapshot(
          stage.path,
          includeOutputs: true,
        );
        if (analyze) await _run('flutter', ['analyze', '--no-pub'], stage.path);
        const portableManifests = {
          'pubspec.yaml',
          'pubspec_overrides.yaml',
          'pubspec.lock',
        };
        for (final path in portableManifests) {
          final file = File(p.join(stage.path, path));
          final actual = file.existsSync() ? await fingerprint(file) : null;
          if (actual != beforeAnalysis[path]) {
            throw GenerationException(
              'Manifest changed during analysis: $path. No changes were applied.',
            );
          }
        }
        _restoreLockPaths(stage, dependencyPaths);
        for (final entry in manifestContents.entries) {
          File(p.join(stage.path, entry.key)).writeAsStringSync(entry.value);
        }

        context.cancellation.check();
        workspace.rejectUnexpectedOutputs();
        final current = await workspace.snapshot(project.root);
        if (!_sameSnapshot(baseline, current)) {
          throw const GenerationException(
            'Project inputs changed during validation. Retry with the current files.',
          );
        }
        final validated = await workspace.snapshot(
          stage.path,
          includeOutputs: true,
        );
        for (final path in {
          ...beforeAnalysis.keys,
          ...validated.keys,
        }.difference(portableManifests)) {
          if (beforeAnalysis[path] != validated[path]) {
            throw GenerationException(
              'Output changed during analysis: $path. No changes were applied.',
            );
          }
        }
        context.report(
          'collecting',
          detail: '${validated.length} validated outputs',
        );
        for (final relative in {...baseline.keys, ...validated.keys}) {
          if (baseline[relative] == validated[relative] &&
              !plan.files.containsKey(relative)) {
            continue;
          }
          final explicit = explicitTargets.contains(relative);
          List<int>? original;
          int? originalMode;
          if (!explicit) {
            final file = File(project.file(relative));
            final type = FileSystemEntity.typeSync(
              file.path,
              followLinks: false,
            );
            if (type != FileSystemEntityType.notFound &&
                type != FileSystemEntityType.file) {
              throw GenerationException(
                'Output target is not a regular file: $relative',
              );
            }
            original = file.existsSync() ? file.readAsBytesSync() : null;
            originalMode = file.existsSync()
                ? file.statSync().mode & 0x1ff
                : null;
            final input = baseline[relative];
            if (input == null && original != null) {
              throw GenerationException(
                'Unstaged output conflicts with an existing target: $relative. No changes were applied.',
              );
            }
            if (input != null &&
                (original == null ||
                    digestBytes(original) != input.digest ||
                    originalMode != (input.mode & 0x1ff))) {
              throw GenerationException(
                'Project input changed while collecting outputs: $relative. No changes were applied.',
              );
            }
          }
          final output = validated[relative];
          final bytes = output == null
              ? null
              : File(p.join(stage.path, relative)).readAsBytesSync();
          if (bytes != null && digestBytes(bytes) != output!.digest) {
            throw GenerationException(
              'Output changed while collecting: $relative. No changes were applied.',
            );
          }
          if (explicit) {
            if (bytes == null) {
              plan.delete(relative);
            } else {
              plan.writeBytes(relative, bytes, mode: output!.mode & 0x1ff);
            }
          } else {
            plan.files[relative] = PlannedFile(
              original == null ? null : List.unmodifiable(original),
              bytes == null ? null : List.unmodifiable(bytes),
              beforeMode: originalMode,
              afterMode: output == null ? null : output.mode & 0x1ff,
            );
          }
        }
        _trackOutputs(plan);
        // Publish portable resolver metadata as part of the same transaction.
        for (final name in ['package_config.json', 'package_graph.json']) {
          final file = File(p.join(stage.path, '.dart_tool', name));
          if (!file.existsSync()) continue;
          final content = file.readAsStringSync().replaceAll(
            stage.uri.toString(),
            Directory(project.root).uri.toString(),
          );
          plan.write('.dart_tool/$name', content);
        }
        // Ensure the exact source/resource bytes validated above are still staged.
        final afterCollection = await workspace.snapshot(
          stage.path,
          includeOutputs: true,
        );
        if (!_sameSnapshot(validated, afterCollection)) {
          throw const GenerationException(
            'A build process changed outputs after validation; nothing was applied.',
          );
        }
      } else {
        _trackOutputs(plan);
      }
      context.cancellation.check();
      _verify(plan);
      context.report('applying', detail: '${plan.files.length} files');
      await _commit(plan, beforeWrite);
      committed = true;
      context.report('completed', completed: true);
    } on Object catch (error, stack) {
      if (error is OperationCancelled) Error.throwWithStackTrace(error, stack);
      final recovery = Directory(project.file(journalPath)).existsSync();
      Error.throwWithStackTrace(
        OperationFailure(
          '$error',
          OperationResult(
            recovery
                ? OperationStatus.recoveryRequired
                : OperationStatus.rolledBack,
            context.warnings,
          ),
        ),
        stack,
      );
    } finally {
      try {
        if (workspace != null) await workspace.dispose();
      } on Object catch (error) {
        context.warn('Staging cleanup failed: $error');
      }
      try {
        await lock.release();
      } on Object catch (error) {
        context.warn('Lock cleanup failed: $error');
      }
    }
    return OperationResult(
      committed && context.warnings.isEmpty
          ? OperationStatus.applied
          : OperationStatus.appliedWithWarnings,
      context.warnings,
    );
  }

  Future<void> _validateToolchain() async {
    final flutter = await executeManagedCommand(
      'flutter',
      ['--version', '--machine'],
      project.root,
      context,
    );
    flutter.requireSuccess('flutter --version --machine');
    final dart = await executeManagedCommand(
      'dart',
      ['--version'],
      project.root,
      context,
    );
    dart.requireSuccess('dart --version');
    final metadata = jsonDecode(flutter.output) as Map;
    final expected = RegExp(r'^[^ ]+')
        .firstMatch(metadata['dartSdkVersion'] as String)
        ?.group(0);
    final actual = RegExp(r'Dart SDK version: ([^ ]+)')
        .firstMatch('${dart.output} ${dart.error}')
        ?.group(1);
    if (actual == null || actual != expected) {
      throw GenerationException(
        'Flutter uses Dart $expected, but the selected dart command uses $actual. Put Flutter/bin first in PATH (or use one consistent SDK manager).',
      );
    }
    final environment =
        (loadYaml(project.read('pubspec.yaml')) as Map)['environment'] as Map?;
    for (final item in {
      'sdk': actual,
      'flutter': metadata['frameworkVersion'] as String,
    }.entries) {
      final constraint = environment?[item.key];
      if (constraint is String &&
          !VersionConstraint.parse(constraint)
              .allows(Version.parse(item.value))) {
        throw GenerationException(
          'The selected ${item.key} version ${item.value} does not satisfy $constraint.',
        );
      }
    }
  }

  Future<void> _run(
    String executable,
    List<String> arguments,
    String cwd,
  ) async {
    context.cancellation.check();
    final result = identical(executor, executeCommand)
        ? await executeManagedCommand(executable, arguments, cwd, context)
        : await executor(executable, arguments, cwd);
    result.requireSuccess('$executable ${arguments.join(' ')}');
  }

  bool _sameSnapshot(
    Map<String, FileFingerprint> a,
    Map<String, FileFingerprint> b,
  ) =>
      a.length == b.length &&
      a.entries.every((entry) => b[entry.key] == entry.value);

  void _trackOutputs(GenerationPlan plan) {
    if (plan.files.containsKey(registryPath) &&
        plan.files[registryPath]!.after == null) {
      return;
    }
    if (!plan.files.containsKey(registryPath) &&
        !File(project.file(registryPath)).existsSync()) {
      return;
    }
    Map<String, dynamic> registry;
    try {
      registry = jsonDecode(plan.read(registryPath)) as Map<String, dynamic>;
    } on Object {
      return;
    } // Doctor is allowed to repair corrupt legacy metadata.
    if (registry['version'] != registryVersion) return;
    final records = (registry['features'] as List).cast<Map<String, dynamic>>();
    final projectFiles = (registry['project_files'] as List? ?? [])
        .cast<Map<String, dynamic>>();
    for (final entry in plan.files.entries.toList()) {
      if (entry.key == registryPath ||
          entry.key.startsWith('.cleany/') ||
          entry.key.startsWith('.dart_tool/')) {
        continue;
      }
      final bytes = entry.value.after;
      final candidates = records.where((record) {
        /// File paths and their original/proposed snapshots.
        final files = record['files'] as List? ?? [];
        if (files.any((file) => file['path'] == entry.key)) return true;
        // Only derive builder ownership from a recorded source, never the name alone.
        final parent = entry.key.replaceFirst(
          RegExp(r'\.(g|freezed)\.dart$'),
          '.dart',
        );
        return parent != entry.key &&
            files.any((file) => file['path'] == parent);
      }).toList();
      List<Map<String, dynamic>>? target;
      String owner = '@project';
      if (candidates.length == 1) {
        owner = candidates.single['name'] as String;
        target = (candidates.single['files'] as List)
            .cast<Map<String, dynamic>>();
      } else if (projectFiles.any((file) => file['path'] == entry.key) ||
          (entry.key.replaceFirst(RegExp(r'\.(g|freezed)\.dart$'), '.dart') !=
                  entry.key &&
              projectFiles.any(
                (file) =>
                    file['path'] ==
                    entry.key.replaceFirst(
                      RegExp(r'\.(g|freezed)\.dart$'),
                      '.dart',
                    ),
              )) ||
          entry.key.startsWith('lib/core/localization/generated/') ||
          plan.platformRoots.any((root) => p.posix.isWithin(root, entry.key))) {
        target = projectFiles;
      }
      if (target == null) continue;
      final existing = target
          .where((file) => file['path'] == entry.key)
          .singleOrNull;
      target.removeWhere((file) => file['path'] == entry.key);
      if (bytes != null) {
        target.add(
          Map<String, dynamic>.from(
            artifactRecord(
              entry.key,
              bytes,
              owner,
              origin: existing?['origin'] as String? ?? 'builder',
            ),
          ),
        );
      }
      if (owner != '@project') candidates.single['files'] = target;
    }
    registry['project_files'] = projectFiles;
    plan.write(registryPath, prettyJson(registry));
  }

  List<int>? _bytes(String path) {
    final file = File(project.file(path));
    return file.existsSync() ? file.readAsBytesSync() : null;
  }

  void _verify(GenerationPlan plan) {
    for (final entry in plan.files.entries) {
      if (p.posix.normalize(entry.key) != entry.key) {
        throw GenerationException('Noncanonical planned path: ${entry.key}');
      }
      final file = File(project.file(entry.key));
      final type = FileSystemEntity.typeSync(file.path, followLinks: false);
      if (type != FileSystemEntityType.notFound &&
          type != FileSystemEntityType.file) {
        throw GenerationException('Expected a regular file: ${entry.key}');
      }
      if (!sameBytes(_bytes(entry.key), entry.value.before) ||
          (entry.value.beforeMode != null &&
              file.existsSync() &&
              (file.statSync().mode & 0x1ff) != entry.value.beforeMode)) {
        throw GenerationException('File changed since planning: ${entry.key}');
      }
    }
  }

  Map<String, String> _rebasePathDependencies(Directory stage) {
    final paths = <String, String>{};
    for (final name in ['pubspec.yaml', 'pubspec_overrides.yaml']) {
      final file = File(p.join(stage.path, name));
      if (!file.existsSync()) continue;
      final yaml = loadYaml(file.readAsStringSync());
      if (yaml is! YamlMap) continue;
      if (yaml['workspace'] != null || yaml['resolution'] == 'workspace') {
        throw const GenerationException(
          'Pub workspaces require an isolated package checkout. No project changes were applied.',
        );
      }
      final editor = YamlEditor(file.readAsStringSync());
      for (final section in [
        'dependencies',
        'dev_dependencies',
        'dependency_overrides',
      ]) {
        if (yaml[section] is! YamlMap) continue;
        for (final entry in (yaml[section] as YamlMap).entries) {
          if (entry.value is! YamlMap ||
              (entry.value as YamlMap)['path'] is! String) {
            continue;
          }
          final path = (entry.value as YamlMap)['path'] as String;
          paths[entry.key as String] = path;
          if (p.isRelative(path)) {
            editor.update([
              section,
              entry.key,
              'path',
            ], p.normalize(p.join(project.root, path)));
          }
        }
      }
      file.writeAsStringSync(editor.toString());
    }
    return paths;
  }

  void _restoreLockPaths(Directory stage, Map<String, String> paths) {
    final file = File(p.join(stage.path, 'pubspec.lock'));
    if (paths.isEmpty || !file.existsSync()) return;
    final yaml = loadYaml(file.readAsStringSync());
    final editor = YamlEditor(file.readAsStringSync());
    for (final entry in paths.entries) {
      if (yaml is YamlMap &&
          yaml['packages'] is YamlMap &&
          yaml['packages'][entry.key] is YamlMap &&
          yaml['packages'][entry.key]['source'] == 'path') {
        editor.update([
          'packages',
          entry.key,
          'description',
          'path',
        ], entry.value);
        editor.update([
          'packages',
          entry.key,
          'description',
          'relative',
        ], p.isRelative(entry.value));
      }
    }
    file.writeAsStringSync(editor.toString());
  }

  Future<void> _commit(GenerationPlan plan, void Function(String)? hook) async {
    final directory = Directory(project.file(journalPath))
      ..createSync(recursive: true);
    final records = <String, dynamic>{};
    var index = 0;
    final createdDirectories = <String>{};
    for (final entry in plan.files.entries) {
      final temporary = project.file('${entry.key}.cleany-tmp');
      if (FileSystemEntity.typeSync(temporary, followLinks: false) !=
          FileSystemEntityType.notFound) {
        throw GenerationException('Reserved temporary file exists: $temporary');
      }
      var parent = p.posix.dirname(entry.key);
      while (parent != '.' && !Directory(project.file(parent)).existsSync()) {
        createdDirectories.add(parent);
        parent = p.posix.dirname(parent);
      }
      final backup = 'backups/${index++}';
      if (entry.value.before != null) {
        final file = File(project.file('$journalPath/$backup'));
        file.parent.createSync(recursive: true);
        file.writeAsBytesSync(entry.value.before!, flush: true);
      }
      records[entry.key] = {
        'before_mode': entry.value.before == null
            ? null
            : File(project.file(entry.key)).statSync().mode & 0x1ff,
        'after_mode': entry.value.afterMode,
        'before_hash': entry.value.before == null
            ? null
            : digestBytes(entry.value.before!),
        'after_hash': entry.value.after == null
            ? null
            : digestBytes(entry.value.after!),
        'backup': entry.value.before == null ? null : backup,
        'state': 'pending',
      };
    }
    final manifest = <String, dynamic>{
      'version': 3,
      'files': records,
      'created_directories': createdDirectories.toList(),
      'removed_directories': plan.directoriesToRemove.toList(),
    };
    _journal.create(manifest);
    try {
      for (final entry in plan.files.entries) {
        // Deliver signals between durable writes; recovery itself completes
        // without interruption so cancellation cannot leave a partial undo.
        await Future<void>.delayed(Duration.zero);
        context.cancellation.check();
        hook?.call(entry.key);
        final target = File(project.file(entry.key));
        if (!sameBytes(_bytes(entry.key), entry.value.before) ||
            (entry.value.beforeMode != null &&
                target.existsSync() &&
                (target.statSync().mode & 0x1ff) != entry.value.beforeMode)) {
          throw GenerationException('Concurrent edit detected: ${entry.key}');
        }
        if (entry.value.after == null) {
          File(project.file(entry.key)).deleteSync();
        } else {
          _atomicWrite(
            entry.key,
            entry.value.after!,
            mode: entry.value.afterMode,
          );
        }
        (records[entry.key] as Map)['state'] = 'applied';
        _journal.transition(entry.key, 'applied');
      }
      _prune(plan.directoriesToRemove);
      File(project.file('$journalPath/committed'))
          .writeAsStringSync('ok', flush: true);
      try {
        directory.deleteSync(recursive: true);
      } on Object catch (error) {
        context.warn(
          'Committed successfully; recovery journal cleanup failed: $error',
        );
      }
    } catch (error) {
      final conflicts = _restore();
      if (conflicts.isNotEmpty) {
        throw GenerationException(
          '$error\nSafe files were restored. Resolve these files, then choose recovery: ${conflicts.join(', ')}',
        );
      }
      rethrow;
    }
  }

  JournalStore get _journal => JournalStore(project, journalPath);
  void _atomicWrite(String relative, List<int> bytes, {int? mode}) {
    final file = File(project.file(relative));
    mode ??= file.existsSync() ? file.statSync().mode & 0x1ff : null;
    file.parent.createSync(recursive: true);
    final temporary = File('${file.path}.cleany-tmp');
    temporary.createSync(exclusive: true);
    try {
      temporary.writeAsBytesSync(bytes, flush: true);
      setFileMode(temporary, mode);
      temporary.renameSync(file.path);
    } finally {
      if (temporary.existsSync()) temporary.deleteSync();
    }
  }

  /// Restores safe journal records and preserves conflicting user edits.
  Future<OperationResult> recover() async {
    _recoveredCommitted = false;
    final lock = await ProjectLock.acquire(project);
    try {
      final conflicts = _restore();
      if (conflicts.isNotEmpty) {
        throw GenerationException(
          'Safe files were restored; these user edits were preserved: ${conflicts.join(', ')}',
        );
      }
    } on Object catch (error) {
      throw OperationFailure(
        '$error',
        OperationResult(OperationStatus.recoveryRequired),
      );
    } finally {
      try {
        await lock.release();
      } on Object catch (error) {
        context.warn('Lock cleanup failed: $error');
      }
    }
    return OperationResult(
      _recoveredCommitted
          ? (context.warnings.isEmpty
                ? OperationStatus.applied
                : OperationStatus.appliedWithWarnings)
          : OperationStatus.rolledBack,
      context.warnings,
    );
  }

  /// Recovery attempts every record, preserving only the conflicting files.
  List<String> _restore() {
    final directory = Directory(project.file(journalPath));
    if (!directory.existsSync()) return [];
    final manifest = _journal.read();
    if (File(project.file('$journalPath/committed')).existsSync()) {
      _recoveredCommitted = true;
      try {
        directory.deleteSync(recursive: true);
      } on Object catch (error) {
        context.warn(
          'Application was committed; journal cleanup failed: $error',
        );
      }
      return [];
    }
    final file = File(project.file('$journalPath/manifest.json'));
    final records = manifest['files'] as Map;
    final conflicts = <String>[];
    final backupDirectory = Directory(project.file('$journalPath/backups'));
    final declaredBackups = records.values
        .whereType<Map>()
        .map((record) => record['backup'])
        .whereType<String>()
        .toSet();
    if (backupDirectory.existsSync()) {
      for (final backup in backupDirectory.listSync(followLinks: false)) {
        final relative = 'backups/${p.basename(backup.path)}';
        if (!declaredBackups.contains(relative) && manifest['version'] != 1) {
          conflicts.add('$relative (unreferenced backup preserved)');
        }
      }
    }
    // A crash during a journal replacement can leave this owned temporary file.
    final journalTemporary = File('${file.path}.cleany-tmp');
    if (journalTemporary.existsSync()) journalTemporary.deleteSync();
    for (final entry in records.entries.toList().reversed) {
      if (entry.key is! String || entry.value is! Map) {
        conflicts.add('${entry.key} (invalid journal record)');
        continue;
      }
      final path = entry.key as String;
      final record = entry.value as Map;

      try {
        project.file(path);
        final backup = record['backup'];
        if (manifest['version'] != 1 &&
            backup != null &&
            (backup is! String ||
                !RegExp(r'^backups/[0-9]+$').hasMatch(backup))) {
          throw const FormatException('Invalid backup path');
        }
        final before = manifest['version'] == 1
            ? (record['before'] == null
                  ? null
                  : base64Decode(record['before'] as String))
            : (record['backup'] == null
                  ? null
                  : File(project.file('$journalPath/${record['backup']}'))
                        .readAsBytesSync());
        final beforeHash = before == null ? null : digestBytes(before);
        if (manifest['version'] != 1 && beforeHash != record['before_hash']) {
          throw const FormatException('Backup hash mismatch');
        }
        final afterHash = manifest['version'] == 1
            ? (record['after'] == null
                  ? null
                  : digestBytes(base64Decode(record['after'] as String)))
            : record['after_hash'];
        final current = _bytes(path);
        final currentHash = current == null ? null : digestBytes(current);
        final currentMode = current == null
            ? null
            : File(project.file(path)).statSync().mode & 0x1ff;
        final matchesBefore =
            currentHash == beforeHash &&
            (record['before_mode'] == null ||
                currentMode == record['before_mode']);
        final matchesAfter =
            currentHash == afterHash &&
            (record['after_mode'] == null ||
                currentMode == record['after_mode']);
        if (!matchesBefore && !matchesAfter) {
          record['state'] = 'conflict';
          conflicts.add(path);
          continue;
        }
        final temporary = File(project.file('$path.cleany-tmp'));
        if (temporary.existsSync()) temporary.deleteSync();
        final targetMode = current == null
            ? null
            : File(project.file(path)).statSync().mode & 0x1ff;
        if (currentHash != beforeHash ||
            (record['before_mode'] != null &&
                targetMode != record['before_mode'])) {
          if (before == null) {
            final target = File(project.file(path));
            if (target.existsSync()) target.deleteSync();
          } else {
            _atomicWrite(path, before, mode: record['before_mode'] as int?);
          }
        }
        record['state'] = 'restored';
      } on Object {
        record['state'] = 'conflict';
        conflicts.add(path);
      }
    }
    _journal.create(manifest);
    if (conflicts.isEmpty) {
      _prune(
        (manifest['created_directories'] as List? ??
                manifest['directories'] as List? ??
                [])
            .cast<String>(),
      );
      for (final path
          in (manifest['removed_directories'] as List? ?? []).cast<String>()) {
        Directory(project.file(path)).createSync(recursive: true);
      }
      directory.deleteSync(recursive: true);
    }
    return conflicts;
  }

  void _prune(Iterable<String> paths) {
    final sorted = paths.toList()..sort((a, b) => b.length.compareTo(a.length));
    for (final path in sorted) {
      final directory = Directory(project.file(path));
      if (directory.existsSync() && directory.listSync().isEmpty) {
        directory.deleteSync();
      }
    }
  }
}
