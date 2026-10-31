import 'dart:io';

import 'package:cleany/cleany.dart';
import 'package:cleany/src/cli.dart';
import 'package:cleany/src/cli_menu.dart';
import 'package:test/test.dart';

void main() {
  late Directory directory;
  late Project project;
  setUp(() async {
    directory = Directory.systemTemp.createTempSync('cleany_menu_');
    project = Project(directory.path);
    File(project.file('pubspec.yaml')).writeAsStringSync(
      'name: fixture_app\nenvironment:\n  sdk: ^3.13.0\ndependencies:\n  flutter:\n    sdk: flutter\n',
    );
    Directory(project.file('android')).createSync();
    final generator = Generator(project);
    final transaction = GenerationTransaction(project);
    for (final plan in [generator.initialize(appId: 'com.example.fixture')]) {
      await transaction.apply(
        plan,
        install: false,
        build: false,
        analyze: false,
      );
    }
    await transaction.apply(
      generator.generate(name: 'home', state: StateManagement.cubit),
      install: false,
      build: false,
      analyze: false,
    );
    await transaction.apply(
      generator.generate(
        name: 'card',
        state: StateManagement.none,
        kind: GenerationKind.component,
      ),
      install: false,
      build: false,
      analyze: false,
    );
  });
  tearDown(() => directory.deleteSync(recursive: true));

  Future<String> menu(
    List<String> answers, {
    bool color = false,
    List<String> arguments = const [],
  }) async {
    final iterator = answers.iterator;
    final output = StringBuffer();
    final errors = StringBuffer();
    final code = await runCli(
      arguments,
      projectRoot: project.root,
      output: output,
      error: errors,
      useColor: color,
      readLine: () => iterator.moveNext() ? iterator.current : null,
      executor: (_, _, _) async =>
          throw StateError('Incomplete menu actions must not run commands.'),
    );
    expect(code, 0, reason: '$errors\n$output');
    expect(errors.toString(), isEmpty);
    return output.toString();
  }

  test('numbered sections and commands follow the requested order in plain and colored terminals', () async {
    final output = await menu(['0']);
    final sections = [
      'Generation',
      'Cleanup',
      'Inspection & Management',
      'Core & Setup',
      'Maintenance & Recovery',
    ];
    var previous = -1;
    for (final section in sections) {
      final offset = output.indexOf('[ $section ]');
      expect(offset, greaterThan(previous));
      previous = offset;
    }
    const labels = [
      'Create feature',
      'Create component',
      'Add use case',
      'Remove feature',
      'Remove component',
      'List features',
      'List components',
      'Rename or move an entry',
      'Initialize project',
      'Configure native flavors',
      'Project doctor / repair',
      'Recover interrupted operation',
      'Cleany maintenance / reset',
    ];
    for (var i = 0; i < labels.length; i++) {
      expect(
        output,
        matches(
          RegExp(
            '^\\s*${i + 1}\\. ${RegExp.escape(labels[i])}\$',
            multiLine: true,
          ),
        ),
      );
    }
    expect(output, matches(RegExp(r'^\s*0\. Exit$', multiLine: true)));
    expect(output, isNot(contains('\x1b[')));
    final colored = await menu(['0'], color: true);
    expect(colored, contains('\x1b[1;35m[ Generation ]'));
    expect(colored, contains('\x1b[1;33m'));
  });

  test(
    'every selected command explains its behavior before its first prompt',
    () async {
      const prompts = {
        CliCommand.createFeature: 'Name (snake_case)',
        CliCommand.createComponent: 'Name (snake_case)',
        CliCommand.addUseCase: '› Feature:',
        CliCommand.removeFeature: 'Select feature to remove',
        CliCommand.removeComponent: 'Select component to remove',
        CliCommand.listFeatures: 'home ·',
        CliCommand.listComponents: 'card ·',
        CliCommand.renameMove: '› Entry:',
        CliCommand.initialize: 'Production app id (example:',
        CliCommand.configureFlavors: '› Platforms:',
        CliCommand.doctor: 'No repairable issues found.',
        CliCommand.recover: '› Recovery',
        CliCommand.maintenance: '› Action:',
      };
      final before = project.read(registryPath);
      for (final command in CliCommand.values) {
        final output = await menu(['${command.number}']);
        final normalized = output.replaceAll(RegExp(r'\s+'), ' ');
        expect(
          normalized,
          contains(command.description),
          reason: command.label,
        );
        final prompt = prompts[command];
        if (prompt != null) {
          expect(
            normalized.indexOf(command.description),
            lessThan(normalized.indexOf(prompt)),
            reason: command.label,
          );
        }
        expect(project.read(registryPath), before);
      }
    },
  );

  test('Arabic command digits and maintenance shortcut route to their new command identities', () async {
    final output = await menu(['٣']);
    expect(
      output.replaceAll(RegExp(r'\s+'), ' '),
      contains(CliCommand.addUseCase.description),
    );
    expect(output, contains('› Feature:'));
    final maintenance = await menu([], arguments: ['maintenance']);
    expect(
      maintenance.replaceAll(RegExp(r'\s+'), ' '),
      contains(CliCommand.maintenance.description),
    );
    expect(maintenance, contains('Set command timeout'));
  });
}
