import 'dart:io';

import 'package:cleany/cleany.dart';
import 'package:test/test.dart';

/// Opt-in real native builds; selected platforms require their actual SDKs.
/// CI selects Android, iOS simulator and macOS in independent jobs.
void main() {
  final enabled = Platform.environment['CLEANY_NATIVE_INTEGRATION'] == 'true';
  final platforms =
      (Platform.environment['CLEANY_NATIVE_PLATFORMS'] ?? 'ios,macos')
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toSet();
  for (final platform in platforms) {
    test(
      'real $platform builds for dev, uat and prod native flavors',
      () async {
        expect({'android', 'ios', 'macos'}, contains(platform));
        if (platform != 'android' && !Platform.isMacOS) {
          fail(
            '$platform requires macOS and Xcode; choose a supported native test runner.',
          );
        }
        final directory = Directory.systemTemp.createTempSync(
          'cleany_native_${platform}_',
        );
        print('Native fixture: ${directory.path}');
        try {
          (await executeCommand('flutter', [
            'create',
            '--empty',
            '--no-pub',
            '--project-name',
            'native_fixture',
            '--org',
            'com.cleany.validation',
            '--platforms',
            platform,
            directory.path,
          ], directory.parent.path)).requireSuccess('create $platform fixture');
          final project = Project(directory.path);
          final transaction = GenerationTransaction(
            project,
            context: OperationContext(
              timeout: const Duration(minutes: 12),
              onProgress: (event) => print(
                '[$platform] ${event.command ?? event.stage} ${event.detail ?? ''}',
              ),
            ),
          );
          await transaction.apply(
            Generator(project)
                .initialize(appId: 'com.cleany.validation.nativefixture'),
          );
          await transaction.apply(
            planPlatformFlavors(project, {platform}),
            build: false,
          );
          for (final flavor in ['dev', 'uat', 'prod']) {
            final target = platform == 'android' ? 'apk' : platform;
            final args = [
              'build',
              target,
              '--debug',
              if (platform == 'ios') '--simulator',
              '--flavor',
              flavor,
              '-t',
              'lib/main_$flavor.dart',
              '--dart-define=API_BASE_URL=https://example.com',
            ];
            final result = await executeManagedCommand(
              'flutter',
              args,
              project.root,
              OperationContext(
                timeout: const Duration(minutes: 12),
                onProgress: (event) => print(
                  '[$platform/$flavor] ${event.command ?? event.stage} ${event.detail ?? ''}',
                ),
              ),
            );
            result.requireSuccess('build $platform/$flavor');
            final artifacts = Directory(project.file('build'))
                .listSync(recursive: true, followLinks: false);
            expect(
              artifacts.any(
                (entry) => platform == 'android'
                    ? entry is File &&
                          entry.path.endsWith('app-$flavor-debug.apk')
                    : entry is Directory && entry.path.endsWith('.app'),
              ),
              isTrue,
              reason: 'Expected actual $platform/$flavor artifact.',
            );
            print('BUILT $platform/$flavor');
            final device = Platform.environment['CLEANY_IOS_DEVICE'];
            if (platform == 'ios' && device != null) {
              (await executeCommand('flutter', [
                'run',
                '--no-resident',
                '-d',
                device,
                '--flavor',
                flavor,
                '-t',
                'lib/main_$flavor.dart',
                '--dart-define=API_BASE_URL=https://example.com',
              ], project.root)).requireSuccess('launch ios/$flavor');
              print('LAUNCHED ios/$flavor');
            }
          }
        } finally {
          if (Platform.environment['CLEANY_KEEP_NATIVE_FIXTURE'] != 'true') {
            directory.deleteSync(recursive: true);
          }
        }
      },
      skip: !enabled,
      timeout: const Timeout(Duration(minutes: 35)),
    );
  }
}
