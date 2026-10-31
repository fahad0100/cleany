import 'dart:io';

import 'package:path/path.dart' as p;

import 'project.dart' show isValidAppId;

typedef ProjectPath = String Function(String relative);

/// Resolves common Gradle properties/variables and xcconfig references as data.
/// It never executes Gradle, a shell expression, or project-supplied code.
class NativeIdentity {
  NativeIdentity(this.path);
  final ProjectPath path;
  final variables = <String, Set<String>>{};

  List<String> discover() {
    for (final relative in [
      'android/gradle.properties',
      'android/local.properties',
    ]) {
      final file = File(path(relative));
      if (file.existsSync()) _properties(file.readAsStringSync());
    }
    final result = <String>{};
    for (final relative in [
      'android/build.gradle.kts',
      'android/build.gradle',
      'android/app/build.gradle.kts',
      'android/app/build.gradle',
    ]) {
      final file = File(path(relative));
      if (!file.existsSync()) continue;
      final source = _withoutComments(file.readAsStringSync());
      for (final match in RegExp(
        r'\b(?:val|var|def)\s+(\w+)\s*=\s*([^\n;]+)',
      ).allMatches(source)) {
        _add(match[1]!, match[2]!);
      }
      final block = _block(source, 'defaultConfig');
      if (block == null) continue;
      final matches = RegExp(r'\bapplicationId\s*(?:=\s*)?([^\n;]+)')
          .allMatches(block);
      for (final match in matches) {
        result.addAll(_resolve(match[1]!.trim()));
      }
    }
    for (final platform in ['ios', 'macos']) {
      variables.clear();
      final directory = Directory(path(platform));
      if (!directory.existsSync()) continue;
      final configurations = <String, Map<String, Set<String>>>{};
      void visit(Directory directory) {
        for (final entity in directory.listSync(followLinks: false)) {
          if (entity is Directory &&
              !{
                'Pods',
                '.symlinks',
                'ephemeral',
                'build',
              }.contains(p.basename(entity.path))) {
            visit(entity);
          }
          if (entity is File && entity.path.endsWith('.xcconfig')) {
            variables.clear();
            _readXcconfig(entity, {});
            configurations[p.basenameWithoutExtension(entity.path)] = {
              for (final entry in variables.entries)
                entry.key: {...entry.value},
            };
          }
        }
      }

      visit(directory);
      variables.clear();
      final file = File(path('$platform/Runner.xcodeproj/project.pbxproj'));
      if (!file.existsSync()) continue;
      final source = _withoutComments(file.readAsStringSync());
      final blocks = <String>[];
      for (final match in RegExp(
        r'\bbuildSettings\s*=\s*\{',
      ).allMatches(source)) {
        final block = _block(
          source.substring(match.start),
          'buildSettings',
          assignment: true,
        );
        if (block != null) blocks.add(block);
      }
      // Small fixture and legacy projects may store settings without blocks.
      if (blocks.isEmpty) blocks.add(source);
      for (final block in blocks) {
        variables.clear();
        for (final match in RegExp(
          r'\b([A-Z][A-Z0-9_]*)\s*=\s*([^;\n]+)',
        ).allMatches(block)) {
          _add(match[1]!, match[2]!);
        }
        final local = {
          for (final entry in variables.entries) entry.key: {...entry.value},
        };
        for (final match in RegExp(
          r'PRODUCT_BUNDLE_IDENTIFIER\s*=\s*([^;\n]+)',
        ).allMatches(block)) {
          final expression = match[1]!;
          // Resolve each configuration independently; never combine a dev value
          // from one file with a production value from another configuration.
          for (final configuration in [
            <String, Set<String>>{},
            ...configurations.values,
          ]) {
            variables
              ..clear()
              ..addAll(configuration)
              ..addAll(local);
            result.addAll(_resolve(expression));
          }
        }
      }
    }
    return result
        .where(
          (id) =>
              isValidAppId(id) &&
              !RegExp(
                r'\.(RunnerTests|RunnerUITests|UITests|Tests)$',
                caseSensitive: false,
              ).hasMatch(id),
        )
        .toList();
  }

  void _readXcconfig(File file, Set<String> visited) {
    if (!visited.add(file.path)) return;
    final source = file.readAsStringSync();
    for (final match in RegExp(
      r'^\s*#include\??\s+"([^"\n]+)"',
      multiLine: true,
    ).allMatches(source)) {
      final included = File(p.normalize(p.join(file.parent.path, match[1]!)));
      // Resolve through the project path guard; external references are not read.
      final relative = p.relative(
        included.path,
        from: p.dirname(path('pubspec.yaml')),
      );
      final guarded = File(path(relative));
      if (guarded.existsSync()) _readXcconfig(guarded, visited);
    }
    _properties(_withoutComments(source));
  }

  void _properties(String source) {
    for (final match in RegExp(
      r'^\s*([A-Za-z_][\w.]*)\s*=\s*(.*?)\s*$',
      multiLine: true,
    ).allMatches(source)) {
      variables[match[1]!] = {match[2]!.trim()};
    }
  }

  void _add(String key, String expression) {
    variables[key] = {expression.trim()};
  }

  Set<String> _resolve(String expression, [Set<String> seen = const {}]) {
    var value = expression.trim();
    if ((value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'"))) {
      value = value.substring(1, value.length - 1);
    }
    final property = RegExp(
      r'''(?:gradleProperty|property|findProperty|getenv)\s*\(\s*["']([\w.]+)["']\s*\)''',
    ).firstMatch(value);
    if (property != null) return _variable(property[1]!, seen);
    if (variables.containsKey(value)) return _variable(value, seen);
    final placeholder = RegExp(r'\$\{(\w+)\}|\$\((\w+)\)|\$(\w+)')
        .firstMatch(value);
    if (placeholder != null) {
      final key = placeholder[1] ?? placeholder[2] ?? placeholder[3]!;
      return {
        for (final resolved in _variable(key, seen))
          ..._resolve(
            value.replaceRange(placeholder.start, placeholder.end, resolved),
            {...seen, key},
          ),
      };
    }
    return {value};
  }

  Set<String> _variable(String name, Set<String> seen) {
    if (seen.contains(name)) return {};
    final candidates =
        variables[name] ??
        {if (Platform.environment[name] != null) Platform.environment[name]!};
    return {
      for (final value in candidates) ..._resolve(value, {...seen, name}),
    };
  }

  String? _block(String source, String name, {bool assignment = false}) {
    final match = RegExp('\\b$name\\s*${assignment ? '=\\s*' : ''}\\{')
        .firstMatch(source);
    if (match == null) return null;
    var index = match.end;
    var depth = 1;
    String? quote;
    var escaped = false;
    for (; index < source.length; index++) {
      final char = source[index];
      if (quote != null) {
        if (escaped) {
          escaped = false;
          continue;
        }
        if (char == r'\') {
          escaped = true;
          continue;
        }
        if (char == quote) quote = null;
        continue;
      }
      if (char == '"' || char == "'") {
        quote = char;
        continue;
      }
      if (char == '{') depth++;
      if (char == '}' && --depth == 0) break;
    }
    return source.substring(match.end, index);
  }

  String _withoutComments(String source) {
    final out = StringBuffer();
    String? quote;
    var escaped = false;
    for (var i = 0; i < source.length; i++) {
      final char = source[i];
      if (quote != null) {
        out.write(char);
        if (escaped) {
          escaped = false;
          continue;
        }
        if (char == r'\') {
          escaped = true;
          continue;
        }
        if (char == quote) quote = null;
      } else if (char == '"' || char == "'") {
        quote = char;
        out.write(char);
      } else if (char == '/' && i + 1 < source.length && source[i + 1] == '/') {
        while (i < source.length && source[i] != '\n') {
          i++;
        }
        out.write('\n');
      } else if (char == '/' && i + 1 < source.length && source[i + 1] == '*') {
        i += 2;
        while (i + 1 < source.length &&
            !(source[i] == '*' && source[i + 1] == '/')) {
          i++;
        }
        i++;
        out.write(' ');
      } else {
        out.write(char);
      }
    }
    return out.toString();
  }
}
