import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'native_identity.dart';

/// Selects a complete layered feature or a lightweight reusable component.
enum GenerationKind { feature, component }

/// Presentation controller style; [StateManagement.none] is only valid for components.
enum StateManagement { cubit, bloc, none }

/// Selects direct Dio requests or generated Retrofit clients over Dio.
enum ApiProvider { retrofit, dio }

/// An actionable validation, command, or filesystem failure shown by the CLI.
class GenerationException implements Exception {
  /// Creates a failure with a user-facing [message].
  const GenerationException(this.message);

  /// Explanation of the failed operation and any required recovery action.
  final String message;
  @override
  String toString() => message;
}

/// A canonical Flutter project root with traversal and symlink protection.
class Project {
  /// Resolves an existing directory to its canonical filesystem location.
  Project(String root) : root = Directory(root).resolveSymbolicLinksSync();

  /// Absolute canonical project directory.
  final String root;

  /// Resolves a relative file path contained by this project.
  ///
  /// Throws [GenerationException] for absolute paths, traversal, or symlinks.
  String file(String relative) {
    if (p.isAbsolute(relative) || relative.contains('\\')) {
      throw const GenerationException('Use a project-relative path.');
    }
    final target = p.normalize(p.join(root, relative));
    if (!p.isWithin(root, target)) {
      throw const GenerationException('The path must stay inside the project.');
    }
    // Never traverse a symlink, including a link to another project directory.
    var current = root;
    for (final segment in p.split(p.relative(target, from: root))) {
      current = p.join(current, segment);
      if (FileSystemEntity.typeSync(current, followLinks: false) ==
          FileSystemEntityType.link) {
        throw GenerationException('Symlink paths are unsupported: $relative');
      }
    }
    return target;
  }

  /// Canonical identity for package and relative Dart import comparisons.
  String dartUri(String from, String uri) {
    if (uri.contains(':')) return uri;
    final target = p.posix.normalize(p.posix.join(p.posix.dirname(from), uri));
    file(target);
    if (!p.posix.isWithin('lib', target)) return target;
    return 'package:${validate()}/${target.substring(4)}';
  }

  /// Reads a UTF-8 text file after validating its project-relative path.
  String read(String relative) => File(file(relative)).readAsStringSync();

  /// Reads native identifiers instead of inventing a new production app id.
  List<String> applicationIds() => NativeIdentity(file).discover();

  /// Returns the unique detected native app id, or throws when unresolved.
  String detectAppId() {
    final ids = applicationIds();
    if (ids.length == 1) return ids.single;
    throw GenerationException(
      ids.isEmpty ? 'No native app id found. Enter it during initialization.' : 'Native app ids differ. Select the production identifier during initialization.',
    );
  }

  /// Validates the Flutter SDK dependency and returns the package name.
  String validate() {
    if (!File(file('pubspec.yaml')).existsSync()) {
      throw const GenerationException('pubspec.yaml was not found.');
    }
    final yaml = loadYaml(read('pubspec.yaml'));
    if (yaml is! YamlMap ||
        yaml['dependencies'] is! YamlMap ||
        yaml['dependencies']['flutter'] is! YamlMap ||
        yaml['dependencies']['flutter']['sdk'] != 'flutter') {
      throw const GenerationException('Expected a Flutter SDK dependency.');
    }
    final name = yaml['name'];
    if (name is! String || !RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name)) {
      throw const GenerationException('Invalid package name in pubspec.yaml.');
    }
    return name;
  }
}

// Dart keywords, core types, and Windows device names cannot become public
// generated symbols or portable directory names.
const _reserved = {
  'abstract',
  'as',
  'assert',
  'async',
  'await',
  'base',
  'bool',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'covariant',
  'default',
  'deferred',
  'do',
  'double',
  'dynamic',
  'else',
  'enum',
  'export',
  'extends',
  'extension',
  'external',
  'factory',
  'false',
  'final',
  'finally',
  'for',
  'function',
  'get',
  'hide',
  'if',
  'implements',
  'import',
  'in',
  'int',
  'interface',
  'is',
  'late',
  'library',
  'list',
  'map',
  'mixin',
  'never',
  'new',
  'null',
  'num',
  'object',
  'of',
  'on',
  'operator',
  'part',
  'required',
  'rethrow',
  'return',
  'sealed',
  'set',
  'show',
  'static',
  'string',
  'super',
  'switch',
  'sync',
  'this',
  'throw',
  'true',
  'try',
  'type',
  'typedef',
  'var',
  'void',
  'when',
  'while',
  'with',
  'yield',
  'con',
  'prn',
  'aux',
  'nul',
  'com1',
  'com2',
  'com3',
  'com4',
  'com5',
  'com6',
  'com7',
  'com8',
  'com9',
  'lpt1',
  'lpt2',
  'lpt3',
  'lpt4',
  'lpt5',
  'lpt6',
  'lpt7',
  'lpt8',
  'lpt9',
};

/// Rejects nonportable, reserved, or malformed snake_case entry names.
void validateName(String name) {
  if (name.length > 64 ||
      !RegExp(r'^[a-z][a-z0-9]*(?:_[a-z0-9]+)*$').hasMatch(name) ||
      _reserved.contains(name) ||
      _reserved.contains(pascalCase(name).toLowerCase())) {
    throw const GenerationException(
      'Use a non-reserved snake_case name, starting with a letter (max 64).',
    );
  }
}

/// Converts a validated snake_case name into a Dart type-name prefix.
String pascalCase(String value) => value
    .split('_')
    .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
    .join();

/// Converts a validated snake_case name into a member-name prefix.
String camelCase(String value) {
  final result = pascalCase(value);
  return '${result[0].toLowerCase()}${result.substring(1)}';
}

/// Shared production identity policy for discovery and explicit input.
bool isValidAppId(String value) =>
    RegExp(r'^[A-Za-z][A-Za-z0-9]*(?:\.[A-Za-z][A-Za-z0-9]*){2,}$')
        .hasMatch(value);

/// Rejects an identity that cannot be shared across supported native platforms.
void validateAppId(String value) {
  if (!isValidAppId(value)) {
    throw const GenerationException(
      'Use an application id such as com.company.product.',
    );
  }
}

/// Shared destination policy for generation, discovery, and refactoring.
void validateEntryDirectory(String path) {
  if (p.posix.normalize(path) != path ||
      !p.posix.isWithin('lib', path) ||
      path
          .split('/')
          .any((part) => !RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(part)) ||
      path == 'lib/app' ||
      path == 'lib/core' ||
      p.posix.isWithin('lib/app', path) ||
      p.posix.isWithin('lib/core', path)) {
    throw const GenerationException(
      'Choose a snake_case directory inside lib, outside app and core.',
    );
  }
}
