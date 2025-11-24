import 'dart:io';

class FileModifier {
  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------

  static Future<void> addLineBefore(
    String filePath,
    String targetLine,
    String newLine, {
    bool replaceIfExists = false,
  }) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        print('❌ File not found: $filePath');

        return;
      }

      final content = await file.readAsString();

      if (content.contains(newLine) && !replaceIfExists) {
        print('⚠️ The line already exists, skipped');
        return;
      }

      if (content.contains(newLine) && replaceIfExists) {
        print('🔄 The existing line has been replaced');

        await file.writeAsString(content);
        return;
      }

      final updatedContent = content.replaceFirst(
        targetLine,
        '$newLine\n$targetLine',
      );

      await file.writeAsString(updatedContent);
      print('✅ The line was successfully added before: $targetLine');
    } catch (e) {
      print('❌ خطأ: $e');
    }
  }

  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------

  static Future<void> addLineInsideFunction(
    String filePath,
    String functionName,
    String newLine, {
    bool atStart = true,
  }) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        print('❌ File not found: $filePath');

        return;
      }

      var content = await file.readAsString();

      // البحث عن الدالة
      final functionPattern = RegExp(
        r'(?:void|Future<void>|Future)\s+' +
            functionName +
            r'\s*\([^)]*\)\s*(?:async\s*)?\{',
      );

      final match = functionPattern.firstMatch(content);
      if (match == null) {
        print('❌ Function not found: $functionName');
        return;
      }

      if (content.contains(newLine)) {
        print('⚠️ The line already exists, skipped');

        return;
      }

      int insertPosition = match.end;

      if (atStart) {
        final afterBrace = content.substring(insertPosition);
        final firstLineMatch = RegExp(r'\n\s*').firstMatch(afterBrace);
        if (firstLineMatch != null) {
          insertPosition += firstLineMatch.end;
        }
      } else {
        int braceCount = 1;
        int i = insertPosition;
        while (i < content.length && braceCount > 0) {
          if (content[i] == '{') braceCount++;
          if (content[i] == '}') braceCount--;
          i++;
        }
        insertPosition = i - 1;
      }

      final indent = _getIndentation(content, insertPosition);
      final newContent =
          '${content.substring(0, insertPosition)}\n$indent$newLine${content.substring(insertPosition)}';

      await file.writeAsString(newContent);
      print('✅ The line was added inside the function $functionName');
    } catch (e) {
      print('❌ Error: $e');
    }
  }

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

      // تأكد من أن كل import ينتهي بـ ;
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
        // تحديد المكان بعد آخر import
        final insertPosition = lastImportMatch.end;

        final importsText = importsToAdd.join('\n');

        newContent =
            content.substring(0, insertPosition) +
            '\n$importsText\n' + // ← إضافه سطر جديد
            content.substring(insertPosition);
      } else {
        final importsText = importsToAdd.join('\n');
        newContent = '$importsText\n\n$content';
      }

      await file.writeAsString(newContent);

      print('✅ Imports added successfully:');
      importsToAdd.forEach((imp) => print('   ➕ $imp'));
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------

  /// الحصول على المحاذاة (Indentation)
  static String _getIndentation(String content, int position) {
    int start = position;
    while (start > 0 && content[start - 1] != '\n') {
      start--;
    }
    int end = start;
    while (end < content.length && content[end] == ' ') {
      end++;
    }
    return content.substring(start, end);
  }

  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------

  /// استبدال سطر كامل
  static Future<void> replaceLine(
    String filePath,
    Pattern oldLine, // ← يدعم String و RegExp
    String newLine,
  ) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        print('❌ File not found: $filePath');
        return;
      }

      final content = await file.readAsString();

      if (!content.contains(oldLine)) {
        print('❌ The line to be replaced does not exist');
        return;
      }

      final updatedContent = content.replaceAll(oldLine, newLine);
      await file.writeAsString(updatedContent);
      print('✅ The line was successfully replaced');
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------

  static Future<void> addRoute({
    required String routesFilePath, // ملف Routes.dart
    required String appRouterFilePath, // ملف AppRouter.dart
    required String routeName, // مثل: 'home'
    required String routePath, // مثل: '/home'
    required String screenWidget, // مثل: 'HomeScreen'
    required String cubit, // مثل: 'HomeCubit'
  }) async {
    try {
      // ========================
      // 1️⃣ تعديل ملف Routes
      // ========================
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

      // ========================
      // 2️⃣ تعديل ملف AppRouter
      // ========================
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
          create: (context) => $cubit(${routeName}UseCase: GetIt.I.get()),
          child: const $screenWidget(),
        ),
  ),''';

        routerContent =
            routerContent.substring(0, insertPosition) +
            '\n$newGoRoute\n' +
            routerContent.substring(insertPosition);

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
  static Future<void> setupEnvFile() async {
    try {
      // 1️⃣ إنشاء فولدر assets
      final assetsDir = Directory('assets');
      if (!await assetsDir.exists()) {
        await assetsDir.create();
        print('📁 Created assets/ folder');
      }

      // 2️⃣ إنشاء ملف .env
      final envFile = File('assets/.env');
      final envContent = '''
url_supabase=<XXXXX>
key_supabase=<XXXXX>
''';
      await envFile.writeAsString(envContent);
      print('📝 Created assets/.env file');

      // 3️⃣ تعديل pubspec.yaml
      final pubspec = File('pubspec.yaml');
      if (await pubspec.exists()) {
        String content = await pubspec.readAsString();

        // إذا كان قد أضيف سابقاً لا نكرر
        if (!content.contains('assets/.env')) {
          final lines = content.split('\n');

          // إيجاد آخر سطر يحتوي "flutter:"
          int lastFlutterIndex = -1;
          for (int i = 0; i < lines.length; i++) {
            if (lines[i].trim().startsWith('flutter:')) {
              lastFlutterIndex = i;
            }
          }

          if (lastFlutterIndex != -1) {
            // نحسب مستوى الـ indent المستعمل
            final indent =
                RegExp(
                  r'^(\s*)',
                ).firstMatch(lines[lastFlutterIndex])?.group(1) ??
                '';

            // نضيف بعدها مباشرة
            lines.insertAll(lastFlutterIndex + 1, [
              '$indent  assets:',
              '$indent    - .env',
              '$indent    - images/',
              '$indent    - icons/',
            ]);

            content = lines.join('\n');
            await pubspec.writeAsString(content);
            print('⚙️ Updated pubspec.yaml at the last flutter: block');
          }
        }
      }

      // 4️⃣ تعديل .gitignore
      final gitignore = File('.gitignore');
      if (await gitignore.exists()) {
        String ignoreContent = await gitignore.readAsString();

        if (!ignoreContent.contains('*.env')) {
          ignoreContent += '\n*.env\n';
          await gitignore.writeAsString(ignoreContent);
          print('🔒 Added *.env to .gitignore');
        }
      }

      print('✅ All steps completed successfully!');
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------

  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------

  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------

  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------

  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------
  ///---------------------------------------------------------------------------
}
