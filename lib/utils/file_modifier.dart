import 'dart:io';
import 'package:cleany/utils/extension/extensions.dart';
import 'package:yaml/yaml.dart';

class FileModifier {
  static const String _pubspecPath = 'pubspec.yaml';

  ///---------------------------------------------------------------------------
  /// 1. Add Imports
  ///---------------------------------------------------------------------------
  static Future<void> addImports(String filePath, List<String> imports) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        print('❌ File not found: $filePath');
        return;
      }

      String content = await file.readAsString();

      // Format imports to ensure a semicolon exists at the end
      final normalizedImports = imports.map((imp) {
        final trimmed = imp.trim();
        return trimmed.endsWith(';') ? trimmed : '$trimmed;';
      }).toList();

      // Filter out already existing imports
      final importsToAdd = normalizedImports
          .where((imp) => !content.contains(imp))
          .toList();

      if (importsToAdd.isEmpty) {
        print('⚠️ All imports already exist');
        return;
      }

      final regex = RegExp(r"""import\s+['"](.+?)['"];""");
      final matches = regex.allMatches(content);
      final importsText = importsToAdd.join('\n');

      String newContent;

      if (matches.isNotEmpty) {
        final insertPosition = matches.last.end;
        newContent =
            '${content.substring(0, insertPosition)}\n$importsText\n${content.substring(insertPosition)}';
      } else {
        newContent = '$importsText\n\n$content';
      }

      await file.writeAsString(newContent);

      print('✅ Imports added successfully:');
      for (final imp in importsToAdd) {
        print('   ➕ $imp');
      }
    } catch (e) {
      print('❌ Error adding imports: $e');
    }
  }

  ///---------------------------------------------------------------------------
  /// 2. Replace File Content
  ///---------------------------------------------------------------------------
  static Future<void> replaceFileContent({
    required String filePath,
    required String newContent,
    bool createIfNotExists = false,
  }) async {
    try {
      final file = File(filePath);
      final exists = await file.exists();

      if (!exists) {
        if (createIfNotExists) {
          await file.create(recursive: true);
        } else {
          throw Exception('❌ File not found: $filePath');
        }
      }

      await file.writeAsString(newContent);
    } catch (e) {
      rethrow;
    }
  }

  ///---------------------------------------------------------------------------
  /// 3. Add Route
  ///---------------------------------------------------------------------------
  static Future<void> addRoute({
    required String routesFilePath,
    required String appRouterFilePath,
    required String routeName,
    required String routePath,
    required String screenWidget,
    required String cubit,
  }) async {
    try {
      // 1. Update Routes file
      final routesFile = File(routesFilePath);
      if (!await routesFile.exists()) {
        print('❌ File not found: $routesFilePath');
        return;
      }

      String routesContent = await routesFile.readAsString();
      final routesClassMatch = RegExp(
        r'class\s+Routes\s*{',
      ).firstMatch(routesContent);

      if (routesClassMatch != null) {
        final insertIndex = routesContent.indexOf('}', routesClassMatch.end);
        if (insertIndex != -1) {
          final newConst =
              '  static const String $routeName = \'$routePath\';\n';
          routesContent =
              routesContent.substring(0, insertIndex) +
              newConst +
              routesContent.substring(insertIndex);
          await routesFile.writeAsString(routesContent);
          print('✅ The key $routeName has been added inside Routes');
        }
      }

      // 2. Update AppRouter file
      final appRouterFile = File(appRouterFilePath);
      if (!await appRouterFile.exists()) {
        print('❌ File not found: $appRouterFilePath');
        return;
      }

      String routerContent = await appRouterFile.readAsString();
      final routesMatch = RegExp(r'routes\s*:\s*\[').firstMatch(routerContent);

      if (routesMatch != null) {
        int index = routesMatch.end;
        int bracketCount = 1;

        while (index < routerContent.length && bracketCount > 0) {
          if (routerContent[index] == '[') bracketCount++;
          if (routerContent[index] == ']') bracketCount--;
          index++;
        }

        final insertPosition = index - 1;
        final newGoRoute =
            '''
  GoRoute(
    path: Routes.$routeName,
    builder: (context, state) => BlocProvider(
          create: (context) => $cubit(GetIt.I.get()),
          child: const $screenWidget(),
        ),
  ),''';

        routerContent =
            '${routerContent.substring(0, insertPosition)}\n$newGoRoute\n${routerContent.substring(insertPosition)}';

        await appRouterFile.writeAsString(routerContent);
        print('✅ A new GoRoute has been added inside AppRouter.routes');
      }
    } catch (e) {
      print('❌ Error adding route: $e');
    }
  }

  ///---------------------------------------------------------------------------
  /// 4. Replace MaterialApp
  ///---------------------------------------------------------------------------
  // static Future<void> replaceMaterialApp(
  //   String filePath,
  //   String newReturnWidget,
  // ) async {
  //   try {
  //     final file = File(filePath);

  //     if (!await file.exists()) {
  //       print('❌ File not found: $filePath');
  //       return;
  //     }

  //     final content = await file.readAsString();
  //     final materialReturnRegex = RegExp(
  //       r'return\s+MaterialApp\s*\(([\s\S]*?)\);',
  //       multiLine: true,
  //     );

  //     if (!materialReturnRegex.hasMatch(content)) {
  //       print('⚠️ No MaterialApp return widget found to replace');
  //       return;
  //     }

  //     final updatedContent = content.replaceAll(
  //       materialReturnRegex,
  //       "return $newReturnWidget",
  //     );

  //     await file.writeAsString(updatedContent);
  //     print('✅ MaterialApp replaced correctly');
  //   } catch (e) {
  //     print('❌ Error replacing MaterialApp: $e');
  //   }
  // }

  ///---------------------------------------------------------------------------
  /// 5. Check File / Folder Existence
  ///---------------------------------------------------------------------------
  static Future<bool> checkFileExistenceAsync({
    required String filePath,
  }) async {
    return await File(filePath).exists();
  }

  static Future<bool> checkFolderExistenceAsync({
    required String folderPath,
  }) async {
    return await Directory(folderPath).exists();
  }

  ///---------------------------------------------------------------------------
  /// 6. Create Folder
  ///---------------------------------------------------------------------------
  static Future<void> createFolder(String folderPath) async {
    try {
      final dir = Directory(folderPath);
      if (await dir.exists()) {
        print('📂 Folder already exists: $folderPath');
      } else {
        await dir.create(recursive: true);
        print('📁 Folder created: $folderPath');
      }
    } catch (e) {
      print('❌ Error creating folder: $e');
    }
  }

  ///---------------------------------------------------------------------------
  /// 7. Add Asset To Pubspec
  ///---------------------------------------------------------------------------
  static Future<void> addAssetToPubspec(String assetPath) async {
    final pubspec = File(_pubspecPath);

    if (!await pubspec.exists()) {
      print('❌ pubspec.yaml not found!');
      return;
    }

    final lines = await pubspec.readAsLines();

    if (lines.any((line) => line.trim().contains('- $assetPath'))) {
      print('⚠️ Asset "$assetPath" is already in pubspec.yaml');
      return;
    }

    final flutterIndex = lines.lastIndexWhere(
      (line) => line.trim() == 'flutter:',
    );

    if (flutterIndex != -1) {
      int assetsIndex = -1;

      for (int i = flutterIndex + 1; i < lines.length; i++) {
        final line = lines[i];
        if (line.trim().isNotEmpty && !line.startsWith('  ')) break;
        if (line.trim() == 'assets:') {
          assetsIndex = i;
          break;
        }
      }

      if (assetsIndex != -1) {
        lines.insert(assetsIndex + 1, '    - $assetPath');
        print('➕ Added "$assetPath" to existing assets list.');
      } else {
        lines.insertAll(flutterIndex + 1, ['  assets:', '    - $assetPath']);
        print('🆕 Created assets section and added "$assetPath".');
      }

      await pubspec.writeAsString(lines.join('\n'));
    } else {
      print('❌ "flutter:" section not found in pubspec.yaml');
    }
  }

  ///---------------------------------------------------------------------------
  /// 8. Setup Env File
  ///---------------------------------------------------------------------------
  static Future<void> setupEnvFile() async {
    final envFile = File('.env');
    if (!await envFile.exists()) {
      await envFile.writeAsString(
        'url_supabase=<XXXXX>\nkey_supabase=<XXXXX>\n',
      );
    }
  }

  ///---------------------------------------------------------------------------
  /// 9. Get Project Name
  ///---------------------------------------------------------------------------
  static String getProjectName() {
    final file = File(_pubspecPath);
    if (!file.existsSync()) {
      throw Exception(
        'pubspec.yaml not found. Run this inside a Flutter project.',
      );
    }
    final content = file.readAsStringSync();
    final yamlMap = loadYaml(content) as Map;
    return yamlMap['name']?.toString() ?? 'unknown_project';
  }

  ///---------------------------------------------------------------------------
  /// 10. Recreate Pubspec
  ///---------------------------------------------------------------------------
  static Future<void> recreatePubspec() async {
    try {
      final pubspecFile = File(_pubspecPath);

      if (pubspecFile.existsSync()) {
        pubspecFile.deleteSync();
        print('🗑️ Deleted old pubspec.yaml');
      } else {
        throw Exception('pubspec.yaml not found');
      }

      final result = await Process.run('flutter', [
        'create',
        '.',
        '-e',
      ], runInShell: true);

      if (result.exitCode == 0) {
        print('✅ New pubspec.yaml created successfully!');
      } else {
        print('❌ Failed to recreate pubspec.yaml\n${result.stderr}');
      }
    } catch (e) {
      throw Exception('❌ Error while recreating pubspec: $e');
    }
  }

  ///---------------------------------------------------------------------------
  /// 11. Is Flutter Project Root
  ///---------------------------------------------------------------------------
  static Future<bool> isFlutterProjectRoot() async {
    final requiredPaths = [_pubspecPath, 'lib', 'android', 'ios'];

    for (final pathName in requiredPaths) {
      final exists =
          await FileSystemEntity.type(pathName) !=
          FileSystemEntityType.notFound;
      if (!exists) return false;
    }
    return true;
  }

  ///---------------------------------------------------------------------------
  /// 12. Resolve Executable (Windows Support)
  ///---------------------------------------------------------------------------
  static String resolveExecutable(String name) {
    if (!Platform.isWindows) return name;
    final exts = ['.exe', '.bat', '.cmd'];
    for (final ext in exts) {
      final full = '$name$ext';
      final result = Process.runSync('where', [full], runInShell: true);
      if (result.exitCode == 0) {
        return result.stdout.toString().split('\n').first.trim();
      }
    }
    return name;
  }

  ///---------------------------------------------------------------------------
  /// 13. CLI Commands (pub get, build_runner, etc.)
  ///---------------------------------------------------------------------------
  static Future<void> runPubGet({bool showResult = true}) async {
    await _runCommand(
      'flutter',
      ['pub', 'get'],
      '✅ pub get completed',
      showResult: showResult,
    );
  }

  static Future<void> runPubUpgrade({bool showResult = true}) async {
    await _runCommand(
      'flutter',
      ['pub', 'upgrade'],
      '✅ pub upgrade completed',
      showResult: showResult,
    );
  }

  static Future<void> runPubOutdated({bool showResult = true}) async {
    await _runCommand(
      'flutter',
      ['pub', 'outdated'],
      '📦 Outdated packages:',
      showResult: showResult,
    );
  }

  static Future<void> runBuildRunner({bool showResult = true}) async {
    await _runCommand(
      'dart',
      ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
      '🏗️ build_runner completed',
      showResult: showResult,
    );
  }

  ///---------------------------------------------------------------------------
  /// 14. Update Main DI File
  ///---------------------------------------------------------------------------
  static Future<void> updateMainDiFile({
    required String featureName,
    required String packageName,
    String? ownFeaturesName,
    bool? isSub = false,
  }) async {
    final nameCab = featureName.toCapitalized().toCapitalizeSecondWord();
    final targetFile = File('lib/core/di/configure_dependencies.dart');

    if (!targetFile.existsSync()) {
      print('❌ Error: configure_dependencies.dart file not found');
      return;
    }

    String content = targetFile.readAsStringSync();

    final importPath = isSub == true && ownFeaturesName == null
        ? '/sub'
        : (ownFeaturesName != null ? '/$ownFeaturesName/sub' : '');
    final importStatement =
        "import 'package:$packageName/features$importPath/$featureName/di/${featureName}_di.dart';";

    final initMethodName = isSub == true ? 'Sub' : '';
    final initMethodOwner = ownFeaturesName != null
        ? 'For${ownFeaturesName.toCapitalized().toCapitalizeSecondWord()}'
        : '';
    final initStatement =
        "  configure$nameCab$initMethodName$initMethodOwner(getIt);";

    // Prevent duplication
    if (content.contains(initStatement)) {
      print('✅ DI for $nameCab is already added.');
      return;
    }

    // Inject Import
    if (!content.contains(importStatement)) {
      final lastImportIndex = content.lastIndexOf('import ');
      if (lastImportIndex != -1) {
        final endOfLastImportLine = content.indexOf('\n', lastImportIndex);
        content = content.replaceRange(
          endOfLastImportLine,
          endOfLastImportLine,
          '\n$importStatement',
        );
      } else {
        content = '$importStatement\n$content';
      }
    }

    // Inject the initialization function before the last closing bracket of the method
    final functionSignature = 'Future<void> configureDependencies() async {';
    final startIndex = content.indexOf(functionSignature);

    if (startIndex != -1) {
      final endIndex = content.indexOf('}', startIndex);
      if (endIndex != -1) {
        final before = content.substring(0, endIndex);
        final after = content.substring(endIndex);
        content = '$before  $initStatement\n$after';
      } else {
        print('❌ Error: Closing bracket } not found!');
        return;
      }
    } else {
      print('❌ Error: configureDependencies() method not found in the file!');
      return;
    }

    targetFile.writeAsStringSync(content);
    print(
      '🚀 configure$nameCab injected successfully into configure_dependencies.dart',
    );
  }

  //===

  static Future<void> _runCommand(
    String executable,
    List<String> args,
    String successMsg, {
    bool showResult = true,
  }) async {
    final resolvedCommand = resolveExecutable(executable);
    final result = await Process.run(resolvedCommand, args, runInShell: true);

    if (result.exitCode == 0) {
      if (showResult) print("$successMsg\n${result.stdout}");
    } else {
      print("❌ ${args.join(' ')} failed:\n${result.stderr}");
    }
  }
}
