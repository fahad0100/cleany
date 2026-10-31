import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'ast_editor.dart';
import 'project.dart';
import 'templates/core_templates.dart';
import 'templates/feature_templates.dart';
import 'templates/documentation.dart';
import 'transaction.dart';
import 'registry.dart';
import 'specification.dart';
import 'dependencies.dart';

export 'registry.dart' show registryPath;

/// Builds source and integration plans without applying project changes.
///
/// Pass the returned [GenerationPlan] to [GenerationTransaction.apply] for
/// dependency resolution, generation, analysis, and recoverable application.
class Generator {
  /// Creates a planner for [project].
  Generator(this.project);

  /// Project whose fixed architecture and registry are being managed.
  final Project project;
  final _formatter = DartFormatter(
    languageVersion: DartFormatter.latestLanguageVersion,
  );

  /// Plans first-time bootstrap, localization, dependencies, and flavor files.
  ///
  /// Existing app/core directories are protected. An unresolved native app id
  /// requires an explicit [appId]; production identities are never guessed.
  GenerationPlan initialize({
    ApiProvider provider = ApiProvider.retrofit,
    String? appId,
  }) {
    final package = project.validate();
    if (File(project.file(registryPath)).existsSync() ||
        Directory(project.file('lib/app')).existsSync() ||
        Directory(project.file('lib/core')).existsSync()) {
      throw const GenerationException(
        'Already initialized, or lib/app / lib/core exists. Initialization never overwrites an existing architecture.',
      );
    }
    appId ??= project.detectAppId();
    if (!RegExp(r'^[A-Za-z][A-Za-z0-9]*(?:\.[A-Za-z][A-Za-z0-9]*){2,}$')
        .hasMatch(appId)) {
      throw const GenerationException(
        'Use an application id such as com.company.product.',
      );
    }
    final plan = GenerationPlan(project);
    for (final entry in coreTemplates(package, provider, appId).entries) {
      _write(plan, entry.key, entry.value, createOnly: true);
    }
    // Preserve user entrypoints, tests, analysis rules, dependencies, comments,
    // overrides, fonts, and all unrelated pubspec sections.
    if (!File(project.file('lib/main.dart')).existsSync()) {
      _write(
        plan,
        'lib/main.dart',
        "import 'main_dev.dart' as dev;\nFuture<void> main() => dev.main();\n",
        createOnly: true,
      );
    }
    if (!File(project.file('analysis_options.yaml')).existsSync()) {
      plan.write(
        'analysis_options.yaml',
        'include: package:flutter_lints/flutter.yaml\n',
        createOnly: true,
      );
    }
    final yaml = YamlEditor(project.read('pubspec.yaml'));
    final requirements = packageRequirements(provider);
    final original = loadYaml(project.read('pubspec.yaml')) as YamlMap;
    for (final group in requirements.entries) {
      final section = original[group.key];
      if (section != null && section is! YamlMap) {
        throw GenerationException('Expected a mapping for ${group.key}.');
      }
      if (section == null) yaml.update([group.key], <String, Object>{});
      for (final dependency in group.value.entries) {
        if (section is YamlMap && section.containsKey(dependency.key)) continue;
        // Preserve a dependency already declared in another section too.
        if (original['dependencies'] is YamlMap &&
            (original['dependencies'] as YamlMap).containsKey(dependency.key)) {
          continue;
        }
        if (original['dev_dependencies'] is YamlMap &&
            (original['dev_dependencies'] as YamlMap).containsKey(
              dependency.key,
            )) {
          if (group.key == 'dependencies') {
            throw GenerationException(
              'Move ${dependency.key} from dev_dependencies to dependencies before initialization.',
            );
          }
          continue;
        }
        yaml.update([group.key, dependency.key], dependency.value);
      }
    }
    if (original['flutter'] == null) {
      yaml.update(['flutter'], <String, Object>{});
    }
    yaml.update(['flutter', 'generate'], true);
    final flutter = original['flutter'];
    if (flutter != null && flutter is! YamlMap) {
      throw const GenerationException('Expected a flutter mapping in pubspec.');
    }
    final existingAssets = flutter is YamlMap ? flutter['assets'] : null;
    if (existingAssets != null && existingAssets is! YamlList) {
      throw const GenerationException('Expected a flutter assets list.');
    }
    final assets = <Object?>[if (existingAssets is YamlList) ...existingAssets];
    for (final asset in [
      'assets/images/',
      'assets/icons/',
      'assets/translations/',
      'config/flavors/',
    ]) {
      if (!assets.contains(asset)) assets.add(asset);
    }
    yaml.update(['flutter', 'assets'], assets);
    plan.write('pubspec.yaml', yaml.toString());
    plan.write(
      registryPath,
      _json({
        'version': registryVersion,
        'template_version': templateVersion,
        'app_id': appId,
        'project_files': [
          for (final entry in plan.files.entries)
            artifactRecord(entry.key, entry.value.after!, '@project'),
        ],
        'api_provider': provider.name,
        'features': <Object>[],
      }),
      createOnly: true,
    );
    final ignore = File(project.file('.gitignore'));
    final oldIgnore = ignore.existsSync() ? ignore.readAsStringSync() : '';
    plan.write(
      '.gitignore',
      '$oldIgnore\n# Cleany runtime files; commit .cleany/features.json\n.cleany/lock\n.cleany/operation.lock\n.cleany/cache/\n.cleany/backups/\n.cleany/baseline/\n.cleany/logs/\n.cleany/transaction/\n*.cleany-tmp\n.env\n.env.*\n!.env.example\n',
    );
    return plan;
  }

  /// Plans an entry and its central DI, presentation factory, and route wiring.
  ///
  /// [path] is a parent directory inside `lib`. Alternatively, [parent] selects
  /// a registered feature whose `subfeatures` directory receives the entry.
  /// Features require Cubit or Bloc; components also permit no controller.
  GenerationPlan generate({
    required String name,
    required StateManagement state,
    GenerationKind kind = GenerationKind.feature,
    String? path,
    String? parent,
    FeatureSpec? specification,
  }) {
    final package = project.validate();
    validateName(name);
    if (kind == GenerationKind.feature && state == StateManagement.none) {
      throw const GenerationException('Every feature requires cubit or bloc.');
    }
    final registry = readRegistry();
    final provider = ApiProvider.values.byName(
      registry['api_provider'] as String,
    );
    final entries = (registry['features'] as List).cast<Map<String, dynamic>>();
    if (parent != null) {
      validateName(parent);
      if (path != null) {
        throw const GenerationException(
          'Choose either a custom directory or a parent feature.',
        );
      }
      final parents = entries.where(
        (e) => e['name'] == parent && e['kind'] == 'feature',
      );
      if (parents.length != 1) {
        throw GenerationException('Parent feature not found: $parent');
      }
      path = '${parents.single['path']}/subfeatures';
    }
    path ??= kind == GenerationKind.feature ? 'lib/features' : 'lib/components';
    if (p.posix.normalize(path) != path ||
        !p.posix.isWithin('lib', path) ||
        path
            .split('/')
            .any(
              (segment) => !RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(segment),
            )) {
      throw const GenerationException(
        'The destination must be a snake_case directory inside lib.',
      );
    }
    final target = '$path/$name';
    project.file(target);
    if (FileSystemEntity.typeSync(project.file(target), followLinks: false) !=
        FileSystemEntityType.notFound) {
      throw GenerationException('Target already exists: $target');
    }
    if (entries.any(
      (e) => pascalCase(e['name'] as String) == pascalCase(name),
    )) {
      throw GenerationException(
        'Feature/component name already registered: $name',
      );
    }
    final templates = featureTemplates(
      name: name,
      path: target,
      package: package,
      kind: kind,
      state: state,
      provider: provider,
      specification: specification,
    );
    _checkCollisions(templates);
    final plan = GenerationPlan(project);
    for (final entry in templates.entries) {
      _write(plan, entry.key, entry.value, createOnly: true);
    }
    _integrate(
      plan,
      name,
      target,
      kind,
      state,
      provider,
      package,
      specification: specification,
    );
    entries.add({
      'name': name,
      'path': target,
      'kind': kind.name,
      'state': state.name,
      'parent': ?parent,
      'template_version': templateVersion,
      'specification': (specification ?? FeatureSpec()).toJson(),
      'files': [
        for (final entry in templates.entries)
          artifactRecord(entry.key, plan.files[entry.key]!.after!, name),
      ],
    });
    registry['features'] = entries;
    plan.write(registryPath, _json(registry));
    return plan;
  }

  /// Reads ownership metadata; [strict] also checks that entry folders exist.
  Map<String, dynamic> readRegistry({bool strict = true}) =>
      FeatureRegistry(project).read(strict: strict);

  /// Rebuilds known entry bindings in a repair plan, preserving unrelated code.
  void reconcileIntegrations(
    GenerationPlan plan,
    List<Map<String, dynamic>> entries,
  ) {
    final names = entries
        .map((entry) => camelCase(entry['name'] as String))
        .toSet();
    final types = <String>{};
    for (final entry in entries) {
      final type = pascalCase(entry['name'] as String);
      types.addAll([
        '${type}Api',
        '${type}RemoteDataSource',
        '${type}Repository',
        'Get$type',
        '${type}Cubit',
        '${type}Bloc',
      ]);
    }
    bool owns(String uri, String from) {
      final package = project.validate();
      final resolved = uri.startsWith('package:')
          ? uri
          : 'package:$package/${p.posix.normalize(p.posix.join(p.posix.dirname(from.substring(4)), uri))}';
      return entries.any(
        (entry) =>
            resolved.startsWith(
              'package:$package/${(entry['path'] as String).substring(4)}/',
            ) ||
            resolved ==
                'package:$package/core/network/retrofit/${entry['name']}_api.dart',
      );
    }

    final di = AstEditor(plan.read('lib/app/di/injection.dart'));
    di.removeImports((uri) => owns(uri, 'lib/app/di/injection.dart'));
    di.ensureFunction(
      'registerFeatureDependencies',
      'void registerFeatureDependencies(GetIt container) {}',
    );
    di.removeRegistrations(types);
    _write(plan, 'lib/app/di/injection.dart', di.source);
    final factories = AstEditor(
      plan.read('lib/app/composition/feature_pages.dart'),
    );
    factories.removeMembers('FeaturePages', names);
    factories.removeImports(
      (uri) => owns(uri, 'lib/app/composition/feature_pages.dart'),
    );
    _write(plan, 'lib/app/composition/feature_pages.dart', factories.source);
    final routes = AstEditor(plan.read('lib/app/router/app_router.dart'))
      ..removeRoutes(names);
    _write(plan, 'lib/app/router/app_router.dart', routes.source);
    final routeNames = AstEditor(plan.read('lib/app/router/route_names.dart'))
      ..removeMembers('RouteNames', names);
    _write(plan, 'lib/app/router/route_names.dart', routeNames.source);
    final registry =
        jsonDecode(plan.read(registryPath)) as Map<String, dynamic>;
    final provider = ApiProvider.values.byName(
      registry['api_provider'] as String,
    );
    for (final entry
        in (registry['features'] as List).cast<Map<String, dynamic>>()) {
      _integrate(
        plan,
        entry['name'] as String,
        entry['path'] as String,
        GenerationKind.values.byName(entry['kind'] as String),
        StateManagement.values.byName(entry['state'] as String),
        provider,
        project.validate(),
        specification: FeatureSpec.fromJson(
          Map<String, dynamic>.from(entry['specification'] as Map? ?? {}),
        ),
      );
    }
  }

  /// Plans removal of an entry, its nested children, and only their integrations.
  GenerationPlan remove({required String name, required GenerationKind kind}) {
    final package = project.validate();
    validateName(name);
    final registry = readRegistry();
    final entries = (registry['features'] as List).cast<Map<String, dynamic>>();
    final selected = entries
        .where((entry) => entry['name'] == name && entry['kind'] == kind.name)
        .singleOrNull;
    if (selected == null) {
      throw GenerationException('${kind.name} not found: $name');
    }
    final root = selected['path'] as String;
    final removed = entries
        .where(
          (entry) =>
              entry['path'] == root ||
              p.posix.isWithin(root, entry['path'] as String),
        )
        .toList();
    final plan = GenerationPlan(project);
    final imports = <String>{};
    final types = <String>{};
    final members = <String>{};
    final routeMembers = <String>{};
    for (final entry in removed) {
      final featureName = entry['name'] as String;
      final type = pascalCase(featureName);
      final path = entry['path'] as String;
      imports.add('package:$package/${path.substring(4)}/');
      imports.add(
        'package:$package/core/network/retrofit/${featureName}_api.dart',
      );
      members.add(camelCase(featureName));
      if (entry['kind'] == 'feature') routeMembers.add(camelCase(featureName));
      types.addAll([
        '${type}Api',
        '${type}RemoteDataSource',
        '${type}Repository',
        'Get$type',
        '${type}Cubit',
        '${type}Bloc',
      ]);
      for (final owned in entry['files'] as List? ?? []) {
        final file = owned['path'] as String;
        if (!p.posix.isWithin(root, file) &&
            File(project.file(file)).existsSync()) {
          plan.delete(file);
        }
      }
    }
    final directory = Directory(project.file(root));
    plan.directoriesToRemove.add(root);
    for (final entity in directory.listSync(
      recursive: true,
      followLinks: false,
    )) {
      final relative = p
          .relative(entity.path, from: project.root)
          .split(p.separator)
          .join('/');
      project.file(relative);
      if (entity is Directory) plan.directoriesToRemove.add(relative);
      if (entity is File) plan.delete(relative);
    }
    bool ownsImport(String uri, String file) {
      final absolute = uri.startsWith('package:')
          ? uri
          : 'package:$package/${p.posix.normalize(p.posix.join(p.posix.dirname(file.substring(4)), uri))}';
      return imports.any(
        (prefix) => prefix.endsWith('/')
            ? absolute.startsWith(prefix)
            : absolute == prefix,
      );
    }

    const diPath = 'lib/app/di/injection.dart';
    final di = AstEditor(plan.read(diPath));
    di.removeRegistrations(types);
    di.removeImports((uri) => ownsImport(uri, diPath));
    _write(plan, diPath, di.source);
    const factoryPath = 'lib/app/composition/feature_pages.dart';
    final factories = AstEditor(plan.read(factoryPath));
    factories.removeMembers('FeaturePages', members);
    factories.removeImports((uri) => ownsImport(uri, factoryPath));
    // Avoid unused imports after removing the last stateful factory.
    final remaining = entries
        .where((entry) => !removed.contains(entry))
        .toList();
    if (!remaining.any((entry) => entry['state'] != 'none')) {
      factories.removeImports(
        (uri) => uri == 'package:flutter_bloc/flutter_bloc.dart',
      );
    }
    _write(plan, factoryPath, factories.source);
    if (routeMembers.isNotEmpty) {
      const namesPath = 'lib/app/router/route_names.dart';
      final names = AstEditor(plan.read(namesPath))
        ..removeMembers('RouteNames', routeMembers);
      _write(plan, namesPath, names.source);
      const routerPath = 'lib/app/router/app_router.dart';
      final router = AstEditor(plan.read(routerPath))
        ..removeRoutes(routeMembers);
      _write(plan, routerPath, router.source);
    }
    registry['features'] = remaining;
    plan.write(registryPath, _json(registry));
    return plan;
  }

  void _checkCollisions(Map<String, String> templates) {
    Set<String> symbols(String content) {
      final declarations = parseString(
        content: content,
        throwIfDiagnostics: false,
      ).unit.declarations;
      return declarations
          .expand(
            (node) => switch (node) {
              ClassDeclaration() => [node.namePart.typeName.lexeme],
              EnumDeclaration() => [node.namePart.typeName.lexeme],
              MixinDeclaration() => [node.name.lexeme],
              GenericTypeAlias() => [node.name.lexeme],
              FunctionTypeAlias() => [node.name.lexeme],
              FunctionDeclaration() => [node.name.lexeme],
              TopLevelVariableDeclaration() => node.variables.variables.map(
                (v) => v.name.lexeme,
              ),
              _ => <String>[],
            },
          )
          .where((n) => !n.startsWith('_'))
          .toSet();
    }

    final generated = templates.entries
        .where((e) => e.key.endsWith('.dart'))
        .expand((e) => symbols(e.value))
        .toSet();
    final lib = Directory(project.file('lib'));
    if (!lib.existsSync()) return;
    for (final file
        in lib
            .listSync(recursive: true, followLinks: false)
            .whereType<File>()) {
      if (!file.path.endsWith('.dart') ||
          file.path.endsWith('.g.dart') ||
          file.path.endsWith('.freezed.dart')) {
        continue;
      }
      final overlap = symbols(file.readAsStringSync()).intersection(generated);
      if (overlap.isNotEmpty) {
        throw GenerationException(
          'Dart symbol collision in ${p.relative(file.path, from: project.root)}: ${overlap.join(', ')}',
        );
      }
    }
  }

  void _integrate(
    GenerationPlan plan,
    String name,
    String target,
    GenerationKind kind,
    StateManagement state,
    ApiProvider provider,
    String package, {
    FeatureSpec? specification,
  }) {
    final type = pascalCase(name);
    final member = camelCase(name);
    final full = kind == GenerationKind.feature;
    final spec = specification ?? FeatureSpec();
    final automaticRequest = full && spec.method == 'GET' && !spec.hasRequest;
    final stateful = state != StateManagement.none;
    final bloc = state == StateManagement.bloc;
    final controller = '$type${bloc ? 'Bloc' : 'Cubit'}';
    final base = 'package:$package/${target.substring(4)}';
    final statePath = full ? 'presentation/${state.name}' : state.name;
    final imports = <String>[
      if (full) ...[
        '$base/data/datasources/${name}_remote_data_source.dart',
        '$base/data/repositories/${name}_repository_impl.dart',
        '$base/domain/repositories/${name}_repository.dart',
        '$base/domain/usecases/get_$name.dart',
        if (provider == ApiProvider.retrofit)
          'package:$package/core/network/retrofit/${name}_api.dart',
      ],
      if (stateful) '$base/$statePath/${name}_${state.name}.dart',
    ];
    if (imports.isNotEmpty) {
      final di = AstEditor(plan.read('lib/app/di/injection.dart'));
      di.addImports(imports);
      di.addStatements('registerFeatureDependencies', '''
${full ? '''
${provider == ApiProvider.retrofit ? '  container.registerLazySingleton<${type}Api>(() => ${type}Api(container<Dio>()));' : ''}
  container.registerLazySingleton<${type}RemoteDataSource>(() => ${type}RemoteDataSource(container<${provider == ApiProvider.retrofit ? '${type}Api' : 'Dio'}>()));
  container.registerLazySingleton<${type}Repository>(() => ${type}RepositoryImpl(container<${type}RemoteDataSource>()));
  container.registerLazySingleton<Get$type>(() => Get$type(container<${type}Repository>()));
''' : ''}
${stateful ? '  container.registerFactory<$controller>(() => $controller(${full ? 'container<Get$type>()' : ''}));' : ''}
''');
      _write(plan, 'lib/app/di/injection.dart', di.source);
    }
    final suffix = full ? 'page' : 'widget';
    final widget = '$type${full ? 'Page' : 'Widget'}';
    final factories = AstEditor(
      plan.read('lib/app/composition/feature_pages.dart'),
    );
    factories.addImports([
      '$base/${full ? 'presentation/pages' : 'widgets'}/${name}_$suffix.dart',
      if (stateful) ...[
        'package:flutter_bloc/flutter_bloc.dart',
        '$base/$statePath/${name}_${state.name}.dart',
        if (bloc && automaticRequest) '$base/$statePath/${name}_event.dart',
      ],
    ]);
    factories.addMembers('FeaturePages', '''
  static Widget $member(GetIt container) => ${stateful ? '''BlocProvider<$controller>(
    create: (_) => container<$controller>()${automaticRequest ? (bloc ? '..add(const ${type}Event.requested())' : '..load()') : ''},
    child: const $widget(),
  )''' : 'const $widget()'};
''');
    _write(plan, 'lib/app/composition/feature_pages.dart', factories.source);
    if (full) {
      final names = AstEditor(plan.read('lib/app/router/route_names.dart'));
      names.requireUnusedRoutePath('/$name');
      names.addMembers('RouteNames', "static const $member = '/$name';");
      _write(plan, 'lib/app/router/route_names.dart', names.source);
      final router = AstEditor(plan.read('lib/app/router/app_router.dart'));
      router.requireUnusedRoutePath('/$name');
      router.addRoutes(
        'GoRoute(path: RouteNames.$member, builder: (context, state) => FeaturePages.$member(container)),',
      );
      _write(plan, 'lib/app/router/app_router.dart', router.source);
    }
  }

  void _write(
    GenerationPlan plan,
    String path,
    String content, {
    bool createOnly = false,
  }) {
    plan.write(
      path,
      path.endsWith('.dart')
          ? _formatter.format(
              createOnly ? documentGeneratedDart(path, content) : content,
            )
          : content,
      createOnly: createOnly,
    );
  }

  String _json(Object value) =>
      '${const JsonEncoder.withIndent('  ').convert(value)}\n';
}
