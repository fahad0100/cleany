import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'dependencies.dart';
import 'generator.dart';
import 'project.dart';
import 'registry.dart';
import 'specification.dart';
import 'templates/core_templates.dart';
import 'templates/documentation.dart';
import 'templates/feature_templates.dart';
import 'transaction.dart';

/// One project inconsistency or a notice about preserved custom code.
class DiagnosticIssue {
  /// Classifies a diagnostic and whether the proposed plan can repair it.
  const DiagnosticIssue(this.code, this.message, {this.repairable = true});

  /// Machine-readable diagnostic category.
  final String code;

  /// Human-readable finding and proposed action.
  final String message;

  /// Whether the report can propose an automatic repair for this finding.
  final bool repairable;
}

/// Findings and a separate repair plan awaiting review and validation.
class DoctorReport {
  /// Associates diagnostic findings with their proposed file changes.
  const DoctorReport(this.issues, this.plan);

  /// Repairable findings and notices about unchanged files.
  final List<DiagnosticIssue> issues;

  /// Proposed repairs; inspect before passing to a transaction.
  final GenerationPlan plan;
}

/// Reconciles disk, registry, ownership, and composition without overwriting edits.
class ProjectDoctor {
  /// Inspects the fixed architecture in [project].
  ProjectDoctor(this.project);

  /// Project inspected for registry, source, dependency, and binding issues.
  final Project project;
  final _formatter = DartFormatter(
    languageVersion: DartFormatter.latestLanguageVersion,
  );

  /// Inspects disk state and builds repairs without applying project changes.
  DoctorReport inspect() {
    final package = project.validate();
    final plan = GenerationPlan(project);
    final issues = <DiagnosticIssue>[];
    Map<String, dynamic> registry;
    try {
      registry = FeatureRegistry(project).read(strict: false);
    } on GenerationException catch (error) {
      issues.add(DiagnosticIssue('registry', '$error'));
      final yaml = loadYaml(project.read('pubspec.yaml')) as Map;
      final retrofit = (yaml['dependencies'] as Map).containsKey('retrofit');
      registry = {
        'version': registryVersion,
        'template_version': templateVersion,
        'api_provider': retrofit ? 'retrofit' : 'dio',
        'project_files': <Object>[],
        'features': <Object>[],
      };
      if (File(project.file(registryPath)).existsSync()) {
        plan.write(
          '.cleany/backups/registry_${DateTime.now().microsecondsSinceEpoch}.json',
          project.read(registryPath),
        );
      }
    }
    final old = (registry['features'] as List).cast<Map<String, dynamic>>();
    final active = old
        .where(
          (entry) =>
              Directory(project.file(entry['path'] as String)).existsSync(),
        )
        .toList();
    for (final entry in old.where((entry) => !active.contains(entry))) {
      issues.add(
        DiagnosticIssue(
          'missing_directory',
          '${entry['path']} is missing; remove its stale registry and composition bindings.',
        ),
      );
    }
    final discovered = discoverEntries();
    for (final entry in discovered) {
      if (active.any((existing) => existing['path'] == entry['path'])) continue;
      if (active.any((existing) => existing['name'] == entry['name'])) {
        issues.add(
          DiagnosticIssue(
            'duplicate_name',
            'Duplicate name ${entry['name']}: ${entry['path']}',
            repairable: false,
          ),
        );
        continue;
      }
      active.add(entry);
      issues.add(
        DiagnosticIssue(
          'unregistered',
          'Register ${entry['kind']} ${entry['name']} at ${entry['path']}.',
        ),
      );
    }
    for (final entry in active) {
      final ancestors =
          active
              .where(
                (candidate) =>
                    candidate != entry &&
                    candidate['kind'] == 'feature' &&
                    p.posix.isWithin(
                      '${candidate['path']}/subfeatures',
                      entry['path'] as String,
                    ),
              )
              .toList()
            ..sort(
              (a, b) => (b['path'] as String).length.compareTo(
                (a['path'] as String).length,
              ),
            );
      if (ancestors.isNotEmpty) {
        entry['parent'] = ancestors.first['name'];
      } else {
        entry.remove('parent');
      }
    }
    final provider = ApiProvider.values.byName(
      registry['api_provider'] as String,
    );
    for (final entry in active) {
      final owned = (entry['files'] as List? ?? [])
          .cast<Map<String, dynamic>>();
      final templates = featureTemplates(
        name: entry['name'] as String,
        path: entry['path'] as String,
        package: package,
        kind: GenerationKind.values.byName(entry['kind'] as String),
        state: StateManagement.values.byName(entry['state'] as String),
        provider: provider,
        specification: FeatureSpec.fromJson(
          Map<String, dynamic>.from(entry['specification'] as Map? ?? {}),
        ),
      );
      for (final template in templates.entries) {
        final file = File(project.file(template.key));
        if (!file.existsSync()) {
          if (!template.key.endsWith('.gitkeep')) {
            issues.add(
              DiagnosticIssue(
                'missing_source',
                'Restore missing template file ${template.key}.',
              ),
            );
            final content = _render(template.key, template.value);
            plan.write(template.key, content);
            owned.removeWhere((item) => item['path'] == template.key);
            owned.add(
              Map<String, dynamic>.from(
                artifactRecord(
                  template.key,
                  utf8.encode(content),
                  entry['name'] as String,
                ),
              ),
            );
          }
        } else if (!owned.any((item) => item['path'] == template.key)) {
          // Legacy adoption is restricted to token-equivalent fixed templates.
          if (_tokens(file.readAsStringSync()) == _tokens(template.value) ||
              p.posix.isWithin(entry['path'] as String, template.key)) {
            owned.add(
              Map<String, dynamic>.from(
                artifactRecord(
                  template.key,
                  file.readAsBytesSync(),
                  entry['name'] as String,
                  origin: 'adopted',
                ),
              ),
            );
            issues.add(
              DiagnosticIssue(
                'ownership',
                'Record ownership of ${template.key}.',
              ),
            );
          } else {
            issues.add(
              DiagnosticIssue(
                'unverified_api',
                'Unverified external file ${template.key}; it will be preserved on removal.',
                repairable: false,
              ),
            );
          }
        }
      }
      entry['files'] = owned;
      entry['template_version'] ??= 'legacy';
      for (final item in owned) {
        final file = File(project.file(item['path'] as String));
        if (file.existsSync() &&
            contentDigest(file.readAsBytesSync()) != item['sha256']) {
          issues.add(
            DiagnosticIssue(
              'modified',
              '${item['path']} contains user edits and will be preserved.',
              repairable: false,
            ),
          );
        }
      }
    }
    registry['features'] = active;
    registry['version'] = registryVersion;
    registry['template_version'] = templateVersion;
    String? applicationId = registry['app_id'] as String?;
    applicationId ??= project.applicationIds().singleOrNull;
    final flavorFile = File(project.file('flavorizr.yaml'));
    if (applicationId == null && flavorFile.existsSync()) {
      try {
        final flavors = loadYaml(flavorFile.readAsStringSync()) as Map;
        final production = flavors['flavors']['prod'] as Map;
        final candidate =
            production['android']?['applicationId'] ??
            production['ios']?['bundleId'] ??
            production['macos']?['bundleId'];
        if (candidate is String &&
            RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*(\.[a-zA-Z][a-zA-Z0-9_]*)+$')
                .hasMatch(candidate)) {
          applicationId = candidate;
        }
      } on Object {
        // Invalid public configuration is reported by staged validation.
      }
    }
    final core = coreTemplates(
      package,
      provider,
      applicationId ?? 'com.example.diagnostic',
    );
    final projectFiles = (registry['project_files'] as List? ?? [])
        .cast<Map<String, dynamic>>();
    for (final entry in core.entries) {
      final existing = File(project.file(entry.key));
      if (existing.existsSync()) {
        if (!projectFiles.any((record) => record['path'] == entry.key) &&
            (entry.key.endsWith('.dart')
                ? _tokens(existing.readAsStringSync()) == _tokens(entry.value)
                : existing.readAsStringSync() == entry.value)) {
          projectFiles.add(
            Map<String, dynamic>.from(
              artifactRecord(
                entry.key,
                existing.readAsBytesSync(),
                '@project',
                origin: 'adopted',
              ),
            ),
          );
          issues.add(
            DiagnosticIssue(
              'ownership',
              'Record legacy template ownership: ${entry.key}.',
            ),
          );
        }
        continue;
      }
      if (entry.key == 'flavorizr.yaml' && applicationId == null) {
        issues.add(
          /// Classifies a diagnostic and whether the proposed plan can repair it.
          const DiagnosticIssue(
            'app_id',
            'Select a production application id before rebuilding flavorizr.yaml.',
            repairable: false,
          ),
        );
        continue;
      }
      final content = _render(entry.key, entry.value);
      plan.write(entry.key, content);
      projectFiles.add(
        Map<String, dynamic>.from(
          artifactRecord(entry.key, utf8.encode(content), '@project'),
        ),
      );
      issues.add(DiagnosticIssue('missing_core', 'Restore ${entry.key}.'));
    }
    registry['project_files'] = projectFiles;
    if (applicationId != null) registry['app_id'] = applicationId;
    plan.write(registryPath, prettyJson(registry));
    _repairDependencies(plan, provider, issues);
    try {
      Generator(project).reconcileIntegrations(plan, [...old, ...active]);
      if (plan.files.keys.any((key) => key.startsWith('lib/app/'))) {
        issues.add(
          /// Classifies a diagnostic and whether the proposed plan can repair it.
          const DiagnosticIssue(
            'integrations',
            'Reconcile DI registrations, presentation factories, route constants, and route entries.',
          ),
        );
      }
    } on Object catch (error) {
      issues.add(
        DiagnosticIssue(
          'custom_structure',
          'Composition needs manual resolution: $error',
          repairable: false,
        ),
      );
      // Do not offer a partially reconciled repair when its integration is unsupported.
      throw GenerationException(
        'Doctor found an unsupported composition structure: $error. Existing files were preserved.',
      );
    }
    return DoctorReport(issues, plan);
  }

  /// Finds recognizable feature/component source layouts inside `lib`.
  List<Map<String, dynamic>> discoverEntries() {
    final lib = Directory(project.file('lib'));
    if (!lib.existsSync()) return [];
    final result = <String, Map<String, dynamic>>{};
    for (final file
        in lib
            .listSync(recursive: true, followLinks: false)
            .whereType<File>()) {
      final relative = p
          .relative(file.path, from: project.root)
          .split(p.separator)
          .join('/');
      if (relative.startsWith('lib/core/') || relative.startsWith('lib/app/')) {
        continue;
      }
      final basename = p.posix.basename(relative);
      String? path;
      String? name;
      GenerationKind? kind;
      if (relative.contains('/data/datasources/') &&
          basename.endsWith('_remote_data_source.dart')) {
        name = basename.replaceFirst('_remote_data_source.dart', '');
        path = p.posix.dirname(p.posix.dirname(p.posix.dirname(relative)));
        kind = GenerationKind.feature;
      } else if (relative.contains('/widgets/') &&
          basename.endsWith('_widget.dart') &&
          !relative.contains('/presentation/')) {
        name = basename.replaceFirst('_widget.dart', '');
        path = p.posix.dirname(p.posix.dirname(relative));
        kind = GenerationKind.component;
      }
      if (name == null ||
          path == null ||
          kind == null ||
          p.posix.basename(path) != name) {
        continue;
      }
      try {
        validateName(name);
      } on GenerationException {
        continue;
      }
      final prefix = kind == GenerationKind.feature
          ? '$path/presentation'
          : path;
      final state =
          File(project.file('$prefix/cubit/${name}_cubit.dart')).existsSync()
          ? 'cubit'
          : File(project.file('$prefix/bloc/${name}_bloc.dart')).existsSync()
          ? 'bloc'
          : 'none';
      if (kind == GenerationKind.feature && state == 'none') continue;
      result[path] = {
        'name': name,
        'path': path,
        'kind': kind.name,
        'state': state,
        'template_version': 'discovered',
        'specification': _inferSpec(path, name).toJson(),
        'files': <Object>[],
      };
    }
    return result.values.toList();
  }

  FeatureSpec _inferSpec(String path, String name) {
    List<FieldSpec> fields(String relative) {
      final file = File(project.file(relative));
      if (!file.existsSync()) return [];
      final classes = parseString(
        content: file.readAsStringSync(),
        throwIfDiagnostics: false,
      ).unit.declarations.whereType<ClassDeclaration>();
      for (final declaration in classes) {
        final body = declaration.body;
        if (body is! BlockClassBody) continue;
        for (final constructor
            in body.members.whereType<ConstructorDeclaration>()) {
          if (constructor.factoryKeyword == null || constructor.name != null) {
            continue;
          }
          final result = <FieldSpec>[];
          for (final parameter in constructor.parameters.parameters) {
            if (parameter is! RegularFormalParameter ||
                parameter.name == null ||
                parameter.type == null) {
              continue;
            }
            String? key;
            for (final annotation in parameter.metadata.where(
              (a) => a.name.toSource() == 'JsonKey',
            )) {
              for (final argument
                  in annotation.arguments?.arguments
                          .whereType<NamedArgument>() ??
                      <NamedArgument>[]) {
                if (argument.name.lexeme == 'name' &&
                    argument.argumentExpression is SimpleStringLiteral) {
                  key = (argument.argumentExpression as SimpleStringLiteral)
                      .value;
                }
              }
            }
            result.add(
              FieldSpec(
                parameter.name!.lexeme,
                parameter.type!.toSource(),
                jsonKey: key,
              ),
            );
          }
          if (result.isNotEmpty) return result;
        }
      }
      return [];
    }

    final response = fields('$path/data/models/${name}_model.dart');
    final request = fields('$path/domain/entities/${name}_request.dart');
    var method = 'GET';
    String? endpoint;
    var encoding = 'query';
    final api = File(
      project.file('lib/core/network/retrofit/${name}_api.dart'),
    );
    if (api.existsSync()) {
      final unit = parseString(
        content: api.readAsStringSync(),
        throwIfDiagnostics: false,
      ).unit;
      for (final declaration
          in unit.declarations.whereType<ClassDeclaration>()) {
        final body = declaration.body;
        if (body is! BlockClassBody) continue;
        for (final operation in body.members.whereType<MethodDeclaration>()) {
          for (final annotation in operation.metadata) {
            if (![
              'GET',
              'POST',
              'PUT',
              'PATCH',
              'DELETE',
            ].contains(annotation.name.toSource())) {
              continue;
            }
            method = annotation.name.toSource();
            final argument =
                annotation.arguments?.arguments.firstOrNull?.argumentExpression;
            if (argument is SimpleStringLiteral) endpoint = argument.value;
          }
          if (operation.parameters?.toSource().contains('@Body(') == true) {
            encoding = 'body';
          }
        }
      }
    }
    if (!api.existsSync()) {
      final remote = File(
        project.file('$path/data/datasources/${name}_remote_data_source.dart'),
      );
      if (remote.existsSync()) {
        final visitor = _DioContractVisitor();
        parseString(
          content: remote.readAsStringSync(),
          throwIfDiagnostics: false,
        ).unit.accept(visitor);
        method = visitor.method ?? method;
        endpoint = visitor.endpoint;
        encoding = visitor.body ? 'body' : 'query';
      }
    }
    return FeatureSpec(
      fields: response.isEmpty ? null : response,
      requestFields: request,
      method: method,
      endpoint: endpoint,
      requestEncoding: encoding,
    );
  }

  String _render(String path, String content) => path.endsWith('.dart')
      ? _formatter.format(documentGeneratedDart(path, content))
      : content;
  String _tokens(String content) {
    if (content.isEmpty) return '';
    final unit = parseString(content: content, throwIfDiagnostics: false).unit;
    final literals = _LiteralTokens();
    unit.accept(literals);
    final tokens = <String>[];
    var token = unit.beginToken;
    while (!token.isEof) {
      tokens.add(literals.values[token.offset] ?? token.lexeme);
      token = token.next!;
    }
    return tokens.join(' ');
  }

  void _repairDependencies(
    GenerationPlan plan,
    ApiProvider provider,
    List<DiagnosticIssue> issues,
  ) {
    final original = loadYaml(plan.read('pubspec.yaml')) as YamlMap;
    final editor = YamlEditor(plan.read('pubspec.yaml'));
    for (final section in packageRequirements(provider).entries) {
      if (original[section.key] == null) {
        editor.update([section.key], <String, Object>{});
      }
      for (final dependency in section.value.entries) {
        final current = original[section.key] is Map
            ? original[section.key][dependency.key]
            : null;
        var replace = current == null;
        Object replacement = dependency.value;
        if (dependency.value is Map &&
            (dependency.value as Map)['sdk'] != null) {
          replace =
              current is! Map ||
              current['sdk'] != (dependency.value as Map)['sdk'];
        }
        if (current is String && dependency.value is String) {
          try {
            final declared = VersionConstraint.parse(current);
            final supported = declared.intersect(
              VersionConstraint.parse(dependency.value as String),
            );
            replace = supported.isEmpty || supported != declared;
            if (!supported.isEmpty) replacement = supported.toString();
          } on FormatException {
            issues.add(
              DiagnosticIssue(
                'dependency',
                'Cannot parse ${dependency.key}: $current',
                repairable: false,
              ),
            );
          }
        }
        if (replace) {
          editor.update([section.key, dependency.key], replacement);
          issues.add(
            DiagnosticIssue(
              'dependency',
              'Set ${dependency.key} to the supported constraint $replacement.',
            ),
          );
        }
      }
    }
    if (original['flutter'] is Map && original['flutter']['generate'] != true) {
      editor.update(['flutter', 'generate'], true);
    }
    plan.write('pubspec.yaml', editor.toString());
  }
}

class _LiteralTokens extends RecursiveAstVisitor<void> {
  final values = <int, String>{};
  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    values[node.offset] = jsonEncode(node.value);
  }
}

class _DioContractVisitor extends RecursiveAstVisitor<void> {
  String? method;
  String? endpoint;
  bool body = false;
  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.target?.toSource() == '_dio' &&
        [
          'get',
          'post',
          'put',
          'patch',
          'delete',
          'request',
        ].contains(node.methodName.name)) {
      method = node.methodName.name == 'request'
          ? 'GET'
          : node.methodName.name.toUpperCase();
      final first = node.argumentList.arguments.firstOrNull?.argumentExpression;
      if (first is SimpleStringLiteral) endpoint = first.value;
      for (final argument
          in node.argumentList.arguments.whereType<NamedArgument>()) {
        if (argument.name.lexeme == 'data') body = true;
        if (argument.name.lexeme == 'options') {
          final expression = argument.argumentExpression;
          final arguments = expression is InstanceCreationExpression
              ? expression.argumentList
              : expression is MethodInvocation
              ? expression.argumentList
              : null;
          for (final option
              in arguments?.arguments.whereType<NamedArgument>() ??
                  <NamedArgument>[]) {
            if (option.name.lexeme == 'method' &&
                option.argumentExpression is SimpleStringLiteral) {
              method = (option.argumentExpression as SimpleStringLiteral).value;
            }
          }
        }
      }
    }
    super.visitMethodInvocation(node);
  }
}
