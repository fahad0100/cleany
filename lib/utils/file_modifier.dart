import 'dart:io';
import 'package:yaml/yaml.dart';

class FileModifier {
  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------

  static Future<void> addImports(String filePath, List<String> imports) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        print('❌ File not found: $filePath');
        return;
      }

      var content = await file.readAsString();

      final normalizedImports = imports.map((imp) {
        imp = imp.trim();
        if (!imp.endsWith(';')) {
          imp = '$imp;';
        }
        return imp;
      }).toList();

      final importsToAdd = normalizedImports
          .where((imp) => !content.contains(imp))
          .toList();

      if (importsToAdd.isEmpty) {
        print('⚠️ All imports already exist');
        return;
      }

      final regex = RegExp(r"""import\s+['"](.+?)['"];""");
      final matches = regex.allMatches(content);
      final lastImportMatch = matches.isNotEmpty ? matches.last : null;

      String newContent;

      if (lastImportMatch != null) {
        final insertPosition = lastImportMatch.end;

        final importsText = importsToAdd.join('\n');

        newContent =
            '${content.substring(0, insertPosition)}\n$importsText\n${content.substring(insertPosition)}';
      } else {
        final importsText = importsToAdd.join('\n');
        newContent = '$importsText\n\n$content';
      }

      await file.writeAsString(newContent);

      print('✅ Imports added successfully:');
      for (var imp in importsToAdd) {
        print('   ➕ $imp');
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------

  static Future<void> replaceFileContent({
    required String filePath,
    required String newContent,
    bool createIfNotExists = false,
  }) async {
    try {
      final file = File(filePath);

      if (createIfNotExists == false) {
        if (!await file.exists()) {
          // await file.create(recursive: true);
          throw FormatException('❌ File not found: $filePath');
        }
      } else {
        await file.create(recursive: true);
      }

      await file.writeAsString(newContent);
    } catch (e) {
      rethrow;
    }
  }

  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------
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
      final routesFile = File(routesFilePath);
      if (!await routesFile.exists()) {
        print('❌ File not found: $routesFilePath');
        return;
      }

      var routesContent = await routesFile.readAsString();

      final routesClassPattern = RegExp(r'class\s+Routes\s*{');
      final routesClassMatch = routesClassPattern.firstMatch(routesContent);

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

      final appRouterFile = File(appRouterFilePath);
      if (!await appRouterFile.exists()) {
        print('❌ File not found: $appRouterFilePath');
        return;
      }

      var routerContent = await appRouterFile.readAsString();

      final routesPattern = RegExp(r'routes\s*:\s*\[');
      final routesMatch = routesPattern.firstMatch(routerContent);

      if (routesMatch != null) {
        int startIndex = routesMatch.end;
        int bracketCount = 1;
        int index = startIndex;

        while (index < routerContent.length && bracketCount > 0) {
          if (routerContent[index] == '[') bracketCount++;
          if (routerContent[index] == ']') bracketCount--;
          index++;
        }

        int insertPosition = index - 1;

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
      print('❌ Error: $e');
    }
  }

  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------
  static Future<void> replaceMaterialApp(
    String filePath,
    String newReturnWidget,
  ) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        print('❌ File not found: $filePath');
        return;
      }

      String content = await file.readAsString();

      final materialReturnRegex = RegExp(
        r'return\s+MaterialApp\s*\(([\s\S]*?)\);',
        multiLine: true,
      );

      if (!materialReturnRegex.hasMatch(content)) {
        print('⚠️ No MaterialApp return widget found to replace');
        return;
      }

      final updatedContent = content.replaceAll(
        materialReturnRegex,
        "return $newReturnWidget",
      );

      await file.writeAsString(updatedContent);

      print('✅ MaterialApp replaced correctly');
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------

  static Future<bool> checkFileExistenceAsync({
    required String filePath,
  }) async {
    final file = File(filePath);
    if (await file.exists()) {
      return true;
    } else {
      return false;
    }
  }

  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------
  static Future<bool> checkFolderExistenceAsync({
    required String folderPath,
  }) async {
    final Directory myDirectory = Directory(folderPath);

    final bool exists = await myDirectory.exists();

    if (exists) {
      return true;
    } else {
      return false;
    }
  }

  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------
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
  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------

  static Future<void> addAssetToPubspec(String assetPath) async {
    final pubspec = File('pubspec.yaml');

    if (!await pubspec.exists()) {
      print('❌ pubspec.yaml not found!');
      return;
    }

    List<String> lines = await pubspec.readAsLines();

    bool isAlreadyAdded = lines.any(
      (line) => line.trim().contains('- $assetPath'),
    );
    if (isAlreadyAdded) {
      print('⚠️ Asset "$assetPath" is already in pubspec.yaml');
      return;
    }

    int flutterIndex = lines.lastIndexWhere(
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
        print(
          '➕ Added "$assetPath" to existing assets list (in last flutter block).',
        );
      } else {
        lines.insertAll(flutterIndex + 1, ['  assets:', '    - $assetPath']);
        print(
          '🆕 Created assets section in last flutter block and added "$assetPath".',
        );
      }

      // حفظ التعديلات
      await pubspec.writeAsString(lines.join('\n'));
    } else {
      print('❌ "flutter:" section not found in pubspec.yaml');
    }
  }

  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------
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
  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------
  static String getProjectName() {
    final file = File('pubspec.yaml');

    if (!file.existsSync()) {
      throw Exception(
        'pubspec.yaml not found. Run this command inside a Flutter project.',
      );
    }

    final content = file.readAsStringSync();
    final yamlMap = loadYaml(content);

    return yamlMap['name'];
  }

  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------

  static Future<void> recreatePubspec() async {
    try {
      final pubspecFile = File('pubspec.yaml');

      // 1 — Delete pubspec.yaml
      if (pubspecFile.existsSync()) {
        pubspecFile.deleteSync();
        print('🗑️ Deleted old pubspec.yaml');
      } else {
        throw FormatException('pubspec.yaml not found');
      }

      // 2 — Run flutter create . -e
      final result = await Process.run('flutter', [
        'create',
        '.',
        '-e',
      ], runInShell: true);

      if (result.exitCode == 0) {
        print('✅ New pubspec.yaml created successfully!');
      } else {
        print('❌ Failed to recreate pubspec.yaml');
        print(result.stderr);
      }
    } on FormatException catch (_) {
      rethrow;
    } catch (e) {
      throw FormatException('❌ Error while recreating pubspec: $e');
    }
  }

  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------
  ///

  static Future<bool> isFlutterProjectRoot() async {
    final currentDir = Directory.current;

    final requiredPaths = ['pubspec.yaml', 'lib', 'android', 'ios'];

    for (final pathName in requiredPaths) {
      final entity = FileSystemEntity.typeSync('${currentDir.path}/$pathName');

      if (entity == FileSystemEntityType.notFound) {
        return false;
      }
    }

    return true;
  }

  static String resolveExecutable(String name) {
    if (!Platform.isWindows) return name;

    final exts = ['.exe', '.bat', '.cmd'];
    for (final ext in exts) {
      final full = '$name$ext';
      final result = Process.runSync('where', [full]);
      if (result.exitCode == 0) {
        return result.stdout.toString().split('\n').first.trim();
      }
    }

    return name;
  }

  static Future<void> runPubGet({bool showResult = true}) async {
    final flutter = resolveExecutable("flutter");

    final result = await Process.run(flutter, ['pub', 'get']);

    if (result.exitCode == 0) {
      if (showResult) {
        print("✅ pub get completed");
        print(result.stdout);
      }
    } else {
      print("❌ pub get failed: ${result.stderr}");
    }
  }

  static Future<void> runPubUpgrade({bool showResult = true}) async {
    final flutter = resolveExecutable("flutter");

    final result = await Process.run(flutter, ['pub', 'upgrade']);

    if (result.exitCode == 0) {
      if (showResult) {
        print("✅ pub upgrade completed");
        print(result.stdout);
      }
    } else {
      print("❌ pub upgrade failed: ${result.stderr}");
    }
  }

  static Future<void> runPubOutdated({bool showResult = true}) async {
    final flutter = resolveExecutable("flutter");

    final result = await Process.run(flutter, ['pub', 'outdated']);

    if (result.exitCode == 0) {
      if (showResult) {
        print("📦 Outdated packages:");
        print(result.stdout);
      }
    } else {
      print("❌ pub outdated failed: ${result.stderr}");
    }
  }

  static Future<void> runBuildRunner({bool showResult = true}) async {
    final dart = resolveExecutable("dart");

    final result = await Process.run(dart, [
      'run',
      'build_runner',
      'build',
      '--delete-conflicting-outputs',
    ]);

    if (result.exitCode == 0) {
      if (showResult) {
        print("🏗️ build_runner completed");
        print(result.stdout);
      }
    } else {
      print("❌ build_runner failed: ${result.stderr}");
    }
  }
}
