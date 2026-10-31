import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

import 'project.dart';
import 'registry.dart';
import 'transaction.dart';

const launchConfigurationPath = '.vscode/launch.json';
const runningGuidePath = 'CLEANY_RUN.md';
const defaultMain =
    "// Starts the default development environment.\nimport 'main_dev.dart' as cleany_dev;\n\n/// Starts the default development environment.\nFuture<void> main() => cleany_dev.main();\n";
const _environments = ['dev', 'uat', 'prod'];

/// Adds run profiles and repairs recognizable Flutter scaffold entrypoints.
/// Custom entrypoints and existing profile expressions are preserved.
void planRunConfiguration(Project project, GenerationPlan plan) {
  final launch = File(project.file(launchConfigurationPath));
  final source = launch.existsSync()
      ? launch.readAsStringSync()
      : '{"version":"0.2.0"}\n';
  final editor = _JsoncEditor(source)..ensureVersion();
  editor.append('configurations', 'name', [
    for (final environment in _environments)
      for (final native in [false, true])
        {
          'name':
              'Cleany ${environment.toUpperCase()}${native ? ' (native flavor)' : ''}',
          'type': 'dart',
          'request': 'launch',
          'program': 'lib/main_$environment.dart',
          'flutterMode': 'debug',
          'toolArgs': [
            if (native) ...['--flavor', environment],
            '--dart-define=API_BASE_URL=\${input:cleany_${environment}_api_url}',
          ],
        },
  ]);
  editor.append('inputs', 'id', [
    for (final environment in _environments)
      {
        'id': 'cleany_${environment}_api_url',
        'type': 'promptString',
        'description':
            'Public $environment API base URL${environment == 'dev' ? '' : ' (HTTPS required)'}. Leave empty to use flavor YAML.',
        'default': '',
      },
  ]);
  plan.write(launchConfigurationPath, editor.source);
  final guide = File(project.file(runningGuidePath));
  if (!guide.existsSync() ||
      guide.readAsStringSync() ==
          _runningGuide.replaceAll('menu 10', 'menu 12')) {
    plan.write(runningGuidePath, _runningGuide);
  }
  final main = File(project.file('lib/main.dart'));
  if (!main.existsSync()) {
    plan.write('lib/main.dart', defaultMain);
    return;
  }
  final original = main.readAsStringSync();
  final parsed = parseString(content: original, throwIfDiagnostics: false);
  if (parsed.errors.isNotEmpty) return;
  final unit = parsed.unit;
  final entry = unit.declarations
      .whereType<FunctionDeclaration>()
      .where((node) => node.name.lexeme == 'main')
      .singleOrNull;
  if (entry == null ||
      unit.directives.any((node) => node is! ImportDirective)) {
    return;
  }
  final imports = unit.directives.whereType<ImportDirective>();
  if (imports.any(
    (node) => node.uri.stringValue != 'package:flutter/material.dart',
  )) {
    return;
  }
  final body = entry.functionExpression.body;
  if (body is! BlockFunctionBody || body.block.statements.length != 1) return;
  final statement = body.block.statements.single;
  if (statement is! ExpressionStatement ||
      statement.expression is! MethodInvocation) {
    return;
  }
  final call = statement.expression as MethodInvocation;
  if (call.target != null ||
      call.methodName.name != 'runApp' ||
      call.argumentList.arguments.length != 1) {
    return;
  }
  final argument = call.argumentList.arguments.single.toSource();
  if (!{'const MainApp()', 'const MyApp()'}.contains(argument)) return;
  final root = argument.contains('MainApp') ? 'MainApp' : 'MyApp';
  final rootClass = unit.declarations
      .whereType<ClassDeclaration>()
      .where((node) => node.namePart.typeName.lexeme == root)
      .singleOrNull;
  if (rootClass == null || !_isDefaultFlutterRoot(rootClass, root, unit)) {
    return;
  }
  // Keep widget declarations so existing widget tests and exports stay valid.
  // The original entrypoint is archived as exact bytes in the same transaction.
  final backup =
      '.cleany/backups/entrypoints/main_${contentDigest(utf8.encode(original))}.dart';
  plan.write(backup, original);
  final updated = original.replaceRange(
    entry.offset,
    entry.end,
    '/// Starts Cleany using the development entrypoint.\nFuture<void> main() => cleany_dev.main();',
  );
  plan.write(
    'lib/main.dart',
    "import 'main_dev.dart' as cleany_dev;\n$updated",
  );
}

// Conservative template recognition: a customized MyApp/MainApp is user code.
// Whitespace and comments do not affect the fingerprint; widget expressions do.
bool _isDefaultFlutterRoot(
  ClassDeclaration declaration,
  String name,
  CompilationUnit unit,
) {
  final expected = parseString(
    content:
        '''
class $name extends StatelessWidget {
  const $name({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Scaffold(body: Center(child: Text('Hello World!'))));
  }
}
''',
  ).unit.declarations.single;
  if (_scaffoldTokens(declaration) == _scaffoldTokens(expected)) return true;
  if (name != 'MyApp') return false;
  final classes = {
    for (final node in unit.declarations.whereType<ClassDeclaration>())
      node.namePart.typeName.lexeme: node,
  };
  return _counterFingerprints.entries.every((entry) {
    final node = classes[entry.key];
    return node != null &&
        entry.value.contains(contentDigest(utf8.encode(_scaffoldTokens(node))));
  });
}

// Fingerprints cover all three default counter widgets, including their build
// and interaction logic, so a customized child screen is never overwritten.
// Readable SDK fixtures live in test/fixtures/flutter_counter_main.dart.txt.
const _counterFingerprints = {
  'MyApp': {
    '4d77ce7dc3004317f4262e434ea3ee695876c4c1144da8d2df63706dd9e6bdbd',
    '4d2b500d11a25c0234424e71451461581235e263b2ad5ae52cd8688cc64cb1f1',
  },
  'MyHomePage': {
    '92cc376a31967246b33aaa62f5a9bc749208002badbc421138d009aedf3e8e08',
  },
  '_MyHomePageState': {
    'fc600038dddcdbed0cda0302cbe87be1efbe436ab6bf44a34fa920bc14d532cd',
    '7f5bcb39854a8fc9112660fcba86cb50d5bd75d38df40168f6aba1630a8202d8',
  },
};

String _scaffoldTokens(AstNode node) {
  final result = <String>[];
  var token = node.beginToken;
  while (true) {
    if (token.lexeme != ',') result.add(token.lexeme);
    if (identical(token, node.endToken)) break;
    token = token.next!;
  }
  return result.join(' ');
}

/// Records only configuration files changed by the reviewed plan.
void recordRunConfigurationOwnership(
  GenerationPlan plan,
  List<Map<String, dynamic>> owned,
) {
  for (final path in [
    launchConfigurationPath,
    runningGuidePath,
    'lib/main.dart',
  ]) {
    final bytes = plan.files[path]?.after;
    if (bytes == null) continue;
    owned.removeWhere((record) => record['path'] == path);
    owned.add(
      Map<String, dynamic>.from(artifactRecord(path, bytes, '@project')),
    );
  }
}

const _runningGuide = r'''# Running this Cleany application

The Dart entrypoints select configuration, localization, DI, and routing:

| Environment | Entrypoint | Native flavor |
| --- | --- | --- |
| dev | lib/main_dev.dart | dev |
| uat | lib/main_uat.dart | uat |
| prod | lib/main_prod.dart | prod |

New/default Flutter entrypoints delegate to dev through lib/main.dart. Existing
custom entrypoints are preserved; launch a named entrypoint to use Cleany.
Recognizable Flutter scaffold main functions are archived under
.cleany/backups/entrypoints/ before being connected to dev. Their widget classes
remain available to existing tests. Review custom startup logic before migrating.

## VS Code

Choose Cleany DEV, Cleany UAT, or Cleany PROD in Run and Debug, then launch.
A prompt requests the public API base URL for that environment. Leave it empty
only when config/flavors/<environment>.yaml already supplies api_base_url.
UAT and prod require HTTPS. Never put privileged credentials in YAML assets or
launch arguments. Existing launch profiles, inputs, and JSONC comments survive.

The profiles marked (native flavor) additionally select the native app identity.
Run Cleany menu 10 for the target platform before using those profiles.
Environment selection and Flutter debug/profile/release modes are independent.
These profiles use debug mode; select release mode when preparing distribution.

## Terminal or another IDE

Before native flavor setup, select the Dart environment explicitly:

```sh
flutter run --target lib/main_dev.dart --dart-define=API_BASE_URL=https://api.example.com
flutter run --target lib/main_uat.dart --dart-define=API_BASE_URL=https://api.example.com
flutter run --target lib/main_prod.dart --dart-define=API_BASE_URL=https://api.example.com
```

Replace the example URL with your real public API URL. After menu 10 configures
native flavors, add --flavor dev, --flavor uat, or --flavor prod respectively:

```sh
flutter run --flavor dev --target lib/main_dev.dart --dart-define=API_BASE_URL=https://api.example.com
flutter build appbundle --flavor prod --target lib/main_prod.dart --dart-define=API_BASE_URL=https://api.example.com
```

Configure signing and validate the native build for each distribution platform.
Project Doctor restores missing run profiles and guide files without replacing
customized existing configurations.
''';

class _Token {
  const _Token(this.text, this.offset);
  final String text;
  final int offset;
}

/// Minimal lossless JSONC integration: validate JSON, insert only missing items.
/// Strings are tokenized before comments; existing bytes are never reformatted.
class _JsoncEditor {
  _JsoncEditor(this.source);
  String source;

  List<_Token> _tokens() {
    final tokens = <_Token>[];
    var i = 0;
    while (i < source.length) {
      final start = i;
      final char = source[i];
      if (char.trim().isEmpty) {
        i++;
        continue;
      }
      if (source.startsWith('//', i)) {
        while (i < source.length && source[i] != '\n') {
          i++;
        }
        continue;
      }
      if (source.startsWith('/*', i)) {
        final end = source.indexOf('*/', i + 2);
        if (end < 0) throw const FormatException('Unclosed JSONC comment.');
        i = end + 2;
        continue;
      }
      if (char == '"') {
        i++;
        while (i < source.length) {
          if (source[i] == '\\') {
            i += 2;
            continue;
          }
          if (source[i++] == '"') break;
        }
      } else if ('{}[]:,'.contains(char)) {
        i++;
      } else {
        while (i < source.length && !'{}[]:, \t\r\n'.contains(source[i])) {
          i++;
        }
      }
      tokens.add(_Token(source.substring(start, i), start));
    }
    return tokens;
  }

  void ensureVersion() {
    try {
      final tokens = _tokens();
      final normalized = [
        for (var i = 0; i < tokens.length; i++)
          if (!(tokens[i].text == ',' &&
              i + 1 < tokens.length &&
              {']', '}'}.contains(tokens[i + 1].text)))
            tokens[i].text,
      ].join();
      final decoded = jsonDecode(normalized);
      if (decoded is! Map) throw const FormatException('Expected an object.');
      if (decoded.containsKey('version')) return;
      final comma = {'{', ','}.contains(tokens[tokens.length - 2].text)
          ? ''
          : ',';
      source = source.replaceRange(
        tokens.last.offset,
        tokens.last.offset,
        '$comma\n  "version": "0.2.0"\n',
      );
    } on Object catch (error) {
      throw GenerationException(
        'Cannot safely merge $launchConfigurationPath: $error. Fix its JSONC structure before retrying.',
      );
    }
  }

  void append(String key, String identity, List<Map<String, Object>> entries) {
    try {
      final tokens = _tokens();
      final normalized = [
        for (var i = 0; i < tokens.length; i++)
          if (!(tokens[i].text == ',' &&
              i + 1 < tokens.length &&
              {']', '}'}.contains(tokens[i + 1].text)))
            tokens[i].text,
      ].join();
      final decoded = jsonDecode(normalized);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Expected an object.');
      }
      if (decoded.containsKey(key) && decoded[key] is! List) {
        throw FormatException('Expected $key to be an array.');
      }
      final existing = (decoded[key] as List? ?? [])
          .whereType<Map>()
          .map((row) => row[identity])
          .toSet();
      final missing = entries
          .where((row) => !existing.contains(row[identity]))
          .toList();
      final keys = <String>{};
      var depth = 0;
      int? array;
      for (var i = 0; i < tokens.length; i++) {
        final text = tokens[i].text;
        if (depth == 1 &&
            text.startsWith('"') &&
            i + 1 < tokens.length &&
            tokens[i + 1].text == ':') {
          final property = jsonDecode(text) as String;
          if (!keys.add(property)) {
            throw const FormatException('Duplicate root property.');
          }
          if (property == key) array = i + 2;
        }
        if (text == '{' || text == '[') depth++;
        if (text == '}' || text == ']') depth--;
      }
      if (missing.isEmpty) return;
      final content = const JsonEncoder.withIndent('  ').convert(missing);
      if (array == null) {
        final comma = {'{', ','}.contains(tokens[tokens.length - 2].text)
            ? ''
            : ',';
        source = source.replaceRange(
          tokens.last.offset,
          tokens.last.offset,
          '$comma\n  ${jsonEncode(key)}: $content\n',
        );
      } else {
        if (tokens[array].text != '[') {
          throw const FormatException('Expected an array.');
        }
        var nesting = 1;
        var end = array + 1;
        while (nesting > 0) {
          if (tokens[end].text == '[') nesting++;
          if (tokens[end].text == ']') nesting--;
          if (nesting > 0) end++;
        }
        final comma = {'[', ','}.contains(tokens[end - 1].text) ? '' : ',';
        source = source.replaceRange(
          tokens[end].offset,
          tokens[end].offset,
          '$comma\n${content.substring(1, content.length - 1)}\n',
        );
      }
    } on Object catch (error) {
      throw GenerationException(
        'Cannot safely merge $launchConfigurationPath: $error. Fix its JSONC structure before retrying.',
      );
    }
  }
}
