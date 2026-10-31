import 'dart:io';

import 'command_runner.dart';
import 'generator.dart';
import 'registry.dart';
import 'project.dart';
import 'transaction.dart';

import 'dart:convert';

import 'doctor.dart';
import 'lifecycle.dart';
import 'maintenance.dart';
import 'operation.dart';
import 'specification.dart';

/// Numbered, optionally colored prompts. EOF cancels without applying a plan.
class _Terminal {
  _Terminal(this.output, this.input, this.color);
  final StringSink output;
  final String? Function() input;
  final bool color;

  String paint(String value, String code) =>
      color ? '\x1B[${code}m$value\x1B[0m' : value;
  void title(String value) {
    output.writeln(
      paint('\n╭────────────────────────────────────────────╮', '36'),
    );
    output.writeln(paint('  $value', '1;36'));
    output.writeln(
      paint('╰────────────────────────────────────────────╯', '36'),
    );
  }

  void item(int number, String label) =>
      output.writeln('  ${paint('$number', '1;33')}  $label');
  String? line(String label, {String? fallback}) {
    output.write(
      '${paint('›', '36')} $label${fallback == null ? '' : ' [$fallback]'}: ',
    );
    final value = input();
    if (value == null) return null;
    return value.trim().isEmpty ? fallback ?? '' : value.trim();
  }

  int? choose(String label, List<String> choices, {int? fallback}) {
    for (var i = 0; i < choices.length; i++) {
      item(i + 1, choices[i]);
    }
    while (true) {
      final value = line(label, fallback: fallback?.toString());
      if (value == null) return null;
      final number = int.tryParse(_asciiDigits(value));
      if (number != null && number >= 1 && number <= choices.length) {
        return number;
      }
      output.writeln(
        paint('Choose a number from 1 to ${choices.length}.', '31'),
      );
    }
  }

  void success(String value) => output.writeln(paint(value, '32'));
}

/// Actions live in numbered menus; `cleany maintenance` opens maintenance directly.
Future<int> runCli(
  List<String> arguments, {
  StringSink? output,
  StringSink? error,
  String? projectRoot,
  bool? useColor,
  String? Function()? readLine,
  CommandExecutor executor = executeCommand,
}) async {
  output ??= stdout;
  error ??= stderr;
  if (arguments.isNotEmpty &&
      !(arguments.length == 1 && arguments.single == 'maintenance')) {
    error.writeln(
      'Start cleany without arguments, then choose an action by number.',
    );
    return 64;
  }
  final terminal = _Terminal(
    output,
    readLine ?? stdin.readLineSync,
    useColor ?? stdout.supportsAnsiEscapes,
  );
  try {
    final project = Project(projectRoot ?? Directory.current.path);
    project.validate();
    final generator = Generator(project);
    String? pendingAction = arguments.isEmpty ? null : '9';
    var lastActionFailed = false;
    while (true) {
      terminal.title('CLEANY  ·  Flutter Architecture');
      terminal.item(1, 'Create feature');
      terminal.item(2, 'Create component');
      terminal.item(3, 'List features');
      terminal.item(4, 'List components');
      terminal.item(5, 'Remove feature');
      terminal.item(6, 'Remove component');
      terminal.item(7, 'Initialize project');
      terminal.item(8, 'Recover interrupted operation');
      terminal.item(9, 'Cleany maintenance / reset');
      terminal.item(10, 'Project doctor / repair');
      terminal.item(11, 'Rename or move an entry');
      terminal.item(12, 'Configure native flavors');
      terminal.item(0, 'Exit');
      if (!File(project.file(registryPath)).existsSync()) {
        output.writeln(
          terminal.paint(
            '  New project: choose 7 to initialize it first.',
            '33',
          ),
        );
      }
      final actionInput = pendingAction ?? terminal.line('Choose a number');
      final action = actionInput == null ? null : _asciiDigits(actionInput);
      pendingAction = null;
      if (action == null || action == '0') return lastActionFailed ? 1 : 0;
      if (![
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9',
        '10',
        '11',
        '12',
      ].contains(action)) {
        output.writeln(terminal.paint('Choose a number from the menu.', '31'));
        continue;
      }
      try {
        if (['1', '2', '3', '4', '5', '6'].contains(action) &&
            !File(project.file(registryPath)).existsSync()) {
          output.writeln(
            terminal.paint(
              'Initialize this project using option 7 first.',
              '33',
            ),
          );
          continue;
        }
        if (action == '8') {
          final confirm = terminal.choose('Recovery', [
            'Restore interrupted operation',
            'Cancel',
          ], fallback: 2);
          if (confirm == 1) {
            await GenerationTransaction(project, executor: executor).recover();
            terminal.success('Recovery completed.');
          }
          continue;
        }
        if (action == '3' || action == '4') {
          _list(
            generator,
            action == '3' ? GenerationKind.feature : GenerationKind.component,
            terminal,
          );
          continue;
        }
        late final GenerationPlan plan;
        var runChecks = true;
        var runBuild = true;
        if (action == '9') {
          terminal.title('Cleany maintenance');
          final selected = terminal.choose('Action', [
            'Clean abandoned local cache',
            'Archive managed folders and reset Cleany',
            'Set command timeout',
            'Cancel',
          ]);
          if (selected == null || selected == 4) continue;
          if (selected == 1) {
            output.writeln(
              'Only abandoned .cleany/cache workspaces will be removed. Backups, recovery data, and global Flutter caches are preserved.',
            );
            final confirmation = terminal.choose('Continue', [
              'Apply',
              'Cancel',
            ], fallback: 2);
            if (confirmation == 1) {
              final count = await ProjectMaintenance(project).cleanCache();
              terminal.success('Removed $count abandoned workspaces.');
              lastActionFailed = false;
            }
            continue;
          }
          if (selected == 3) {
            final value = int.tryParse(
              terminal.line('Timeout per command, seconds (5 to 3600)') ?? '',
            );
            if (value == null || value < 5 || value > 3600) {
              throw const GenerationException(
                'Enter a timeout from 5 to 3600 seconds.',
              );
            }
            plan = GenerationPlan(project)
              ..write(
                '.cleany/settings.json',
                prettyJson({'command_timeout_seconds': value}),
              );
            runChecks = false;
          } else {
            output.writeln(
              'Current lib/app, lib/core, registered entry folders, and managed configuration are archived before replacing the architecture. Unrelated code, dependencies, and native projects are preserved.',
            );
            plan = ProjectMaintenance(project).reset();
          }
        } else if (action == '10') {
          final report = ProjectDoctor(project).inspect();
          terminal.title('Project doctor');
          for (final issue in report.issues) {
            output.writeln(
              '  ${issue.repairable ? 'REPAIR' : 'NOTICE'}  ${issue.message}',
            );
          }
          if (report.plan.files.isEmpty) {
            terminal.success('No repairable issues found.');
            continue;
          }
          plan = report.plan;
        } else if (action == '11') {
          final entries = (generator.readRegistry()['features'] as List)
              .cast<Map<String, dynamic>>();
          if (entries.isEmpty) {
            output.writeln('No entries to rename or move.');
            continue;
          }
          final selected = terminal.choose('Entry', [
            for (final entry in entries) '${entry['name']} (${entry['kind']})',
            'Cancel',
          ]);
          if (selected == null || selected > entries.length) continue;
          final entry = entries[selected - 1];
          final name = terminal.line(
            'New name',
            fallback: entry['name'] as String,
          );
          final oldPath = entry['path'] as String;
          final destination = terminal.line(
            'Parent directory',
            fallback: oldPath.substring(0, oldPath.lastIndexOf('/')),
          );
          if (name == null || destination == null) continue;
          output.writeln(
            'Dart references, owned filenames, routes, and the registry will be updated. Backend API endpoints are preserved.',
          );
          plan = FeatureLifecycle(project).renameMove(
            name: entry['name'] as String,
            kind: GenerationKind.values.byName(entry['kind'] as String),
            newName: name,
            destination: destination,
          );
        } else if (action == '12') {
          final available = ['android', 'ios', 'macos']
              .where(
                (platform) => Directory(project.file(platform)).existsSync(),
              )
              .toList();
          if (available.isEmpty) {
            throw const GenerationException(
              'No native platform directories exist in this project.',
            );
          }
          final selected = terminal.choose('Platforms', [
            ...available,
            'All available',
            'Cancel',
          ]);
          if (selected == null || selected == available.length + 2) continue;
          final platforms = selected == available.length + 1
              ? available.toSet()
              : {available[selected - 1]};
          output.writeln(
            'Configure ${platforms.join(', ')} through Flavorizr in isolation, then validate and apply native project changes.',
          );
          plan = planPlatformFlavors(project, platforms);
          runBuild = false;
        } else if (action == '7') {
          terminal.title('Initialize project');
          final ids = project.applicationIds();
          String? id;
          if (ids.length == 1) {
            id = ids.single;
            output.writeln(
              'Detected production app id: ${terminal.paint(id, '32')}',
            );
          } else if (ids.isNotEmpty) {
            final selected = terminal.choose('Production app id', [
              ...ids,
              'Enter another app id',
            ]);
            if (selected == null) continue;
            id = selected <= ids.length
                ? ids[selected - 1]
                : terminal.line('Production app id');
          } else {
            id = terminal.line(
              'Production app id (example: com.company.product)',
            );
          }
          if (id == null || id.isEmpty) continue;
          output.writeln('  prod  $id\n  dev   $id.dev\n  uat   $id.uat');
          final provider = terminal.choose('API provider', [
            'Retrofit over Dio',
            'Dio',
          ], fallback: 1);
          if (provider == null) continue;
          plan = generator.initialize(
            appId: id,
            provider: provider == 1 ? ApiProvider.retrofit : ApiProvider.dio,
          );
        } else if (action == '5' || action == '6') {
          final kind = action == '5'
              ? GenerationKind.feature
              : GenerationKind.component;
          final entries = _entries(generator, kind);
          terminal.title('Remove ${kind.name}');
          if (entries.isEmpty) continue;
          final selected = terminal.choose('Select ${kind.name} to remove', [
            for (final entry in entries) '${entry['name']}  (${entry['path']})',
            'Cancel',
          ]);
          if (selected == null || selected > entries.length) continue;
          final entry = entries[selected - 1];
          output.writeln(
            'The directory, its files, and any nested entries will be removed: ${entry['path']}',
          );
          plan = generator.remove(name: entry['name'] as String, kind: kind);
        } else {
          final kind = action == '1'
              ? GenerationKind.feature
              : GenerationKind.component;
          terminal.title('Create ${kind.name}');
          final name = terminal.line('Name (snake_case)');
          if (name == null || name.isEmpty) continue;
          validateName(name);
          final state = terminal.choose('State management', [
            'Cubit',
            'Bloc',
            if (kind == GenerationKind.component) 'No state management',
          ]);
          if (state == null) continue;
          final destination = terminal.choose('Location', [
            'Default directory',
            'Custom directory inside lib',
            'Inside an existing feature',
          ], fallback: 1);
          if (destination == null) continue;
          String? path;
          String? parent;
          if (destination == 2) {
            path = terminal.line(
              'Parent directory (example: lib/shared/components)',
            );
            if (path == null || path.isEmpty) continue;
          } else if (destination == 3) {
            final entries = _entries(generator, GenerationKind.feature);
            if (entries.isEmpty) continue;
            final selected = terminal.choose('Parent feature', [
              for (final entry in entries) entry['name'] as String,
            ]);
            if (selected == null) continue;
            parent = entries[selected - 1]['name'] as String;
          }
          plan = generator.generate(
            name: name,
            kind: kind,
            state: state == 1
                ? StateManagement.cubit
                : state == 2
                ? StateManagement.bloc
                : StateManagement.none,
            path: path,
            parent: parent,
            specification: kind == GenerationKind.feature
                ? _contract(terminal)
                : null,
          );
        }
        terminal.title('Review changes');
        for (final entry in plan.files.entries) {
          final label = entry.value.after == null
              ? 'REMOVE'
              : entry.value.before == null
              ? 'CREATE'
              : 'UPDATE';
          output.writeln(
            '  ${terminal.paint(label, entry.value.after == null ? '31' : '36')}  ${entry.key}',
          );
        }
        final review = terminal.choose('Continue', [
          'Apply and validate',
          'Cancel',
        ], fallback: 2);
        if (review == 1) {
          final logs = File(project.file('.cleany/logs/latest.jsonl'));
          logs.parent.createSync(recursive: true);
          logs.writeAsStringSync('');
          final context = OperationContext(
            timeout: ProjectMaintenance(project).commandTimeout(),
            onProgress: (event) {
              terminal.output.writeln(
                '[${event.elapsed.inSeconds}s] ${event.command ?? event.stage}${event.detail == null ? '' : ' · ${event.detail}'}${event.completed ? ' ✓' : ''}',
              );
              logs.writeAsStringSync(
                '${jsonEncode({'stage': event.stage, 'seconds': event.elapsed.inSeconds, 'command': event.command, 'detail': event.detail, 'completed': event.completed})}\n',
                mode: FileMode.append,
              );
            },
          );
          output.writeln(
            'Preparing operation. Ctrl+C cancels the active command and requests safe rollback.',
          );
          final interrupts = context.watchInterrupts();
          try {
            await GenerationTransaction(
              project,
              executor: executor,
              context: context,
            ).apply(
              plan,
              install: runChecks,
              build: runChecks && runBuild,
              analyze: runChecks,
            );
          } finally {
            await interrupts?.cancel();
          }
          lastActionFailed = false;
          terminal.success(
            runChecks
                ? 'Completed. Staged generation and analysis passed.'
                : 'Settings updated.',
          );
        } else {
          output.writeln('Cancelled. No files were changed.');
        }
      } on Object catch (exception) {
        lastActionFailed = exception is! OperationCancelled;
        error.writeln(
          terminal.paint('Operation stopped: ${_redact('$exception')}', '31'),
        );
        output.writeln(
          'Existing edits are preserved. Review recovery notices if a rollback conflict was reported.',
        );
        final next = terminal.choose('Next step', [
          'Retry this action',
          'Return to main menu',
        ], fallback: 2);
        if (next == 1) pendingAction = action;
      }
    }
  } on Object catch (exception) {
    error.writeln('Unable to open project: $exception');
    return 1;
  }
}

List<Map<String, dynamic>> _list(
  Generator generator,
  GenerationKind kind,
  _Terminal terminal,
) {
  final entries = (generator.readRegistry()['features'] as List)
      .cast<Map<String, dynamic>>()
      .where((entry) => entry['kind'] == kind.name)
      .toList();
  terminal.title(kind == GenerationKind.feature ? 'Features' : 'Components');
  if (entries.isEmpty) terminal.output.writeln('  No ${kind.name}s yet.');
  for (final entry in entries) {
    terminal.output.writeln(
      '  ${terminal.paint(entry['name'] as String, '32')}  ·  ${entry['state']}  ·  ${entry['path']}',
    );
  }
  return entries;
}

List<Map<String, dynamic>> _entries(Generator generator, GenerationKind kind) =>
    (generator.readRegistry()['features'] as List)
        .cast<Map<String, dynamic>>()
        .where((entry) => entry['kind'] == kind.name)
        .toList();

FeatureSpec _contract(_Terminal terminal) {
  final choice = terminal.choose('Data contract', [
    'Default id / GET scaffold',
    'Define fields and API contract',
  ], fallback: 1);
  if (choice == null) throw const OperationCancelled();
  if (choice == 1) return FeatureSpec();
  return FeatureSpec(fields: _fields(terminal));
}

/// Collect response fields without transport or request-parameter prompts.
List<FieldSpec> _fields(_Terminal terminal) {
  late final int count;
  while (true) {
    final input = terminal.line('Response field count (1 to 30)');
    if (input == null) throw const OperationCancelled();
    final value = int.tryParse(_asciiDigits(input));
    if (value != null && value >= 1 && value <= 30) {
      count = value;
      break;
    }
    terminal.output.writeln(
      terminal.paint('Enter a field count from 1 to 30.', '31'),
    );
  }
  terminal.output.writeln(
    'Format: fieldName:type:jsonKey (example: userName:string:user_name)',
  );
  terminal.output.writeln(
    'Types: string, int, double, bool, datetime, list<string>, list<int>.',
  );
  final fields = <FieldSpec>[];
  while (fields.length < count) {
    final index = fields.length + 1;
    final input = terminal.line(
      'Response field $index, lowerCamelCase:type:JSON key',
    );
    if (input == null) throw const OperationCancelled();
    late final FieldSpec field;
    try {
      final parts = input.split(':').map((part) => part.trim()).toList();
      if (parts.length != 3) {
        throw const GenerationException('Use fieldName:type:jsonKey.');
      }
      final requestedType = parts[1]
          .replaceAll(RegExp(r'\s+'), '')
          .toLowerCase();
      final type = FieldSpec.types
          .where((value) => value.toLowerCase() == requestedType)
          .firstOrNull;
      if (type == null) {
        throw const GenerationException(
          'Choose string, int, double, bool, datetime, list<string>, or list<int>.',
        );
      }
      field = FieldSpec(parts[0], type, jsonKey: parts[2]);
      if (fields.any(
        (existing) =>
            existing.name == field.name || existing.jsonKey == field.jsonKey,
      )) {
        throw const GenerationException(
          'Field names and JSON keys must be unique.',
        );
      }
    } on GenerationException catch (error) {
      terminal.output.writeln(terminal.paint('$error', '31'));
      continue;
    }
    final nullable = _nullable(terminal, index);
    fields.add(
      FieldSpec(
        field.name,
        '${field.type}${nullable ? '?' : ''}',
        jsonKey: field.jsonKey,
      ),
    );
  }
  return fields;
}

bool _nullable(_Terminal terminal, int index) {
  while (true) {
    final input = terminal.line('Nullable [$index] (y/N)');
    if (input == null) throw const OperationCancelled();
    switch (_asciiDigits(input.toLowerCase())) {
      case 'y' || 'yes' || '2' || 'نعم':
        return true;
      case '' || 'n' || 'no' || '1' || 'لا':
        return false;
      default:
        terminal.output.writeln(
          terminal.paint('Enter y or n (1 = No, 2 = Yes).', '31'),
        );
    }
  }
}

String _asciiDigits(String value) => String.fromCharCodes(
  value.runes.map((rune) {
    if (rune >= 0x660 && rune <= 0x669) return rune - 0x660 + 0x30;
    if (rune >= 0x6f0 && rune <= 0x6f9) return rune - 0x6f0 + 0x30;
    return rune;
  }),
);

String _redact(String text) => text
    .replaceAll(
      RegExp(r'Bearer\s+\S+', caseSensitive: false),
      'Bearer [redacted]',
    )
    .replaceAll(RegExp(r'://[^/@\s]+:[^/@\s]+@'), '://[redacted]@');
