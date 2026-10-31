import 'dart:convert';
import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as p;

import 'ast_editor.dart';
import 'component_layout.dart';
import 'project.dart';
import 'templates/core_templates.dart';
import 'templates/feature_templates.dart';
import 'templates/documentation.dart';
import 'transaction.dart';
import 'registry.dart';
import 'run_configuration.dart';
import 'specification.dart';
import 'dependencies.dart';
import 'use_case_editor.dart';
import 'use_case_support.dart';
import 'templates/feature_context.dart';
import 'templates/use_case_templates.dart';

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
    validateAppId(appId);
    final plan = GenerationPlan(project);
    for (final entry in coreTemplates(package, provider, appId).entries) {
      _write(plan, entry.key, entry.value, createOnly: true);
    }
    // Run profiles preserve custom configuration; recognizable Flutter scaffolds
    // gain a dev entrypoint and an exact recovery copy of the original main.
    planRunConfiguration(project, plan);
    if (!File(project.file('analysis_options.yaml')).existsSync()) {
      plan.write(
        'analysis_options.yaml',
        'include: package:flutter_lints/flutter.yaml\n',
        createOnly: true,
      );
    }
    plan.write(
      'pubspec.yaml',
      configurePubspec(project.read('pubspec.yaml'), provider),
    );
    plan.write(
      registryPath,
      _json({
        'version': registryVersion,
        'template_version': templateVersion,
        'app_id': appId,
        'project_files': [
          for (final entry in plan.files.entries)
            if (!entry.key.startsWith('.cleany/backups/'))
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
    validateEntryDirectory(path);
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
      if (kind == GenerationKind.component) 'component_layout': 'flat',
      'parent': ?parent,
      'template_version': templateVersion,
      'specification': (specification ?? FeatureSpec()).toJson(),
      'integrations': integrationOwnership(plan, name),
      'files': [
        for (final entry in templates.entries)
          artifactRecord(entry.key, plan.files[entry.key]!.after!, name),
      ],
    });
    registry['features'] = entries;
    plan.write(registryPath, _json(registry));
    return plan;
  }

  /// Adds a transport-independent operation to an existing full feature.
  /// Extends its existing repository contract and implementation, while central
  /// DI injects the operation into the current Cubit or Bloc.
  GenerationPlan addUseCase({
    required String feature,
    required String name,
    required UseCaseReturnType returnType,
  }) {
    final package = project.validate();
    validateName(feature);
    var operation = UseCaseSpec(name: name, returnType: returnType);
    final registry = readRegistry();
    final entries = (registry['features'] as List).cast<Map<String, dynamic>>();
    final selected = entries
        .where(
          (entry) => entry['name'] == feature && entry['kind'] == 'feature',
        )
        .singleOrNull;
    if (selected == null) {
      throw GenerationException('Feature not found: $feature');
    }
    final operations = entryUseCases(selected);
    if (operations.any((existing) => existing.type == operation.type)) {
      throw GenerationException('Use case already registered: $name');
    }
    final provider = ApiProvider.values.byName(
      registry['api_provider'] as String,
    );
    final context = FeatureTemplateContext(
      name: feature,
      path: selected['path'] as String,
      package: package,
      kind: GenerationKind.feature,
      state: StateManagement.values.byName(selected['state'] as String),
      provider: provider,
      specification: FeatureSpec.fromJson(
        Map<String, dynamic>.from(selected['specification'] as Map? ?? {}),
      ),
    );
    if (returnType == UseCaseReturnType.entity) {
      operation = UseCaseSpec(
        name: name,
        returnType: returnType,
        entityFields: existingEntityMappingFields(project, context),
      );
    }
    operations.add(operation);
    final inputs = <String, String>{};
    for (final path in [
      '${context.path}/${context.stateFolder}/${feature}_state.dart',
      '${context.path}/${context.stateFolder}/${feature}_${context.mode}.dart',
      '${context.path}/data/datasources/${feature}_remote_data_source.dart',
      '${context.path}/domain/repositories/${feature}_repository.dart',
      '${context.path}/data/repositories/${feature}_repository_impl.dart',
      if (context.bloc)
        '${context.path}/${context.stateFolder}/${feature}_event.dart',
    ]) {
      if (!File(project.file(path)).existsSync()) {
        throw GenerationException(
          'Missing $path. Run Project doctor before adding a use case.',
        );
      }
      inputs[path] = project.read(path);
    }
    final newFiles = useCaseFiles(context, operation);
    final shared = File(project.file(useCaseStatePath));
    final projectFiles = (registry['project_files'] as List)
        .cast<Map<String, dynamic>>();
    if (shared.existsSync() &&
        !projectFiles.any(
          (file) =>
              file['path'] == useCaseStatePath && file['owner'] == '@project',
        )) {
      throw const GenerationException(
        'The shared use case state file exists without Cleany ownership. Resolve its ownership before retrying.',
      );
    }
    _checkCollisions({
      ...newFiles,
      if (!shared.existsSync()) useCaseStatePath: useCaseStateTemplate(),
    }, includeRedirects: true);
    final changed = addUseCaseToFeature(context, operation, operations, inputs);
    final plan = GenerationPlan(project);
    for (final entry in changed.entries) {
      _write(
        plan,
        entry.key,
        entry.value,
        createOnly: newFiles.containsKey(entry.key),
      );
    }
    if (!shared.existsSync()) {
      _write(plan, useCaseStatePath, useCaseStateTemplate(), createOnly: true);
      projectFiles.add(
        Map<String, dynamic>.from(
          artifactRecord(
            useCaseStatePath,
            plan.files[useCaseStatePath]!.after!,
            '@project',
          ),
        ),
      );
    }
    _integrate(
      plan,
      feature,
      context.path,
      GenerationKind.feature,
      context.state,
      provider,
      package,
      specification: context.spec,
      repairMissing: true,
      useCases: operations,
    );
    final owned = (selected['files'] as List).cast<Map<String, dynamic>>();
    for (final entry in changed.entries) {
      final before = owned
          .where((file) => file['path'] == entry.key)
          .singleOrNull;
      owned.removeWhere((file) => file['path'] == entry.key);
      final bytes = plan.files[entry.key]?.after;
      if (bytes != null) {
        owned.add(
          Map<String, dynamic>.from(
            artifactRecord(
              entry.key,
              bytes,
              feature,
              origin: before?['origin'] as String? ?? 'use_case',
            ),
          ),
        );
      }
    }
    selected['use_cases'] = operations
        .map((operation) => operation.toJson())
        .toList();
    selected['files'] = owned;
    final previous = {
      for (final node in selected['integrations'] as List? ?? [])
        node['node']: node,
    };
    selected['integrations'] = [
      for (final node in integrationOwnership(
        plan,
        feature,
        useCases: operations,
      ))
        if (previous.containsKey(node['node']) &&
            contentDigest(
                  utf8.encode(
                    AstEditor(project.read(node['path'] as String))
                            .integrationNodes()[node['node']] ??
                        '',
                  ),
                ) !=
                previous[node['node']]['sha256'])
          previous[node['node']]
        else
          node,
    ];
    registry['project_files'] = projectFiles;
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
    final registry =
        jsonDecode(plan.read(registryPath)) as Map<String, dynamic>;
    final provider = ApiProvider.values.byName(
      registry['api_provider'] as String,
    );
    final active = (registry['features'] as List).cast<Map<String, dynamic>>();
    final activeNames = active.map((entry) => entry['name']).toSet();
    for (final stale in {
      for (final entry in entries) entry['name']: entry,
    }.values.where((entry) => !activeNames.contains(entry['name']))) {
      final name = stale['name'] as String;
      final ownership = (stale['integrations'] as List? ?? []).cast<Map>();
      if (ownership.isEmpty) {
        throw GenerationException(
          'Missing $name has no integration ownership metadata; inspect its bindings manually.',
        );
      }
      for (final record in ownership) {
        final path = record['path'] as String;
        final node = AstEditor(plan.read(path))
            .integrationNodes()[record['node']];
        if (node != null &&
            contentDigest(utf8.encode(node)) != record['sha256']) {
          throw GenerationException(
            'Customized binding ${record['node']} for missing $name was preserved; resolve it manually.',
          );
        }
      }
      final member = camelCase(name);
      final type = pascalCase(name);
      for (final path in [
        'lib/app/di/injection.dart',
        'lib/app/composition/feature_pages.dart',
        'lib/app/router/route_names.dart',
        'lib/app/router/app_router.dart',
      ]) {
        final editor = AstEditor(plan.read(path));
        if (path.endsWith('injection.dart')) {
          editor.removeRegistrations({
            '${type}Api',
            '${type}RemoteDataSource',
            '${type}Repository',
            'Get$type',
            '${type}Cubit',
            '${type}Bloc',
            for (final operation in entryUseCases(stale)) ...[
              operation.type,
              if (!operation.usesFeatureRepository) operation.repository,
            ],
          });
        }
        if (path.endsWith('feature_pages.dart')) {
          editor.removeMembers('FeaturePages', {member});
        }
        if (path.endsWith('route_names.dart')) {
          editor.removeMembers('RouteNames', {member});
        }
        if (path.endsWith('app_router.dart')) editor.removeRoutes({member});
        editor.removeImports((uri) {
          final resolved = uri.startsWith('package:')
              ? uri
              : 'package:${project.validate()}/${p.posix.normalize(p.posix.join(p.posix.dirname(path.substring(4)), uri))}';
          return resolved.startsWith(
                'package:${project.validate()}/${(stale['path'] as String).substring(4)}/',
              ) ||
              resolved ==
                  'package:${project.validate()}/core/network/retrofit/${name}_api.dart';
        });
        _write(plan, path, editor.source);
      }
    }
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
        repairMissing: true,
        useCases: entryUseCases(entry),
        legacyComponentWidgets: usesLegacyComponentWidgets(entry),
        specification: FeatureSpec.fromJson(
          Map<String, dynamic>.from(entry['specification'] as Map? ?? {}),
        ),
      );
    }
    for (final entry in active) {
      final previous = {
        for (final node in entry['integrations'] as List? ?? [])
          node['node']: node,
      };
      entry['integrations'] = [
        for (final node in integrationOwnership(
          plan,
          entry['name'] as String,
          useCases: entryUseCases(entry),
        ))
          if (previous.containsKey(node['node']))
            previous[node['node']]
          else
            {...node, 'origin': 'observed'},
      ];
    }
    plan.write(registryPath, prettyJson(registry));
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
        for (final operation in entryUseCases(entry)) ...[
          operation.type,
          if (!operation.usesFeatureRepository) operation.repository,
        ],
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

  void _checkCollisions(
    Map<String, String> templates, {
    bool includeRedirects = false,
  }) {
    Set<String> symbols(String content) => {
      ...declaredSymbols(content),
      if (includeRedirects) ...redirectedSymbols(content),
    };
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
    bool repairMissing = false,
    List<UseCaseSpec> useCases = const [],
    bool legacyComponentWidgets = false,
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
      final di = _editor(plan, 'lib/app/di/injection.dart')
        ..repairMissing = repairMissing;
      final originalDi = di.source;
      di.addStatements('registerFeatureDependencies', '''
${full ? '''
${provider == ApiProvider.retrofit ? '  container.registerLazySingleton<${type}Api>(() => ${type}Api(container<Dio>()));' : ''}
  container.registerLazySingleton<${type}RemoteDataSource>(() => ${type}RemoteDataSource(container<${provider == ApiProvider.retrofit ? '${type}Api' : 'Dio'}>()));
  container.registerLazySingleton<${type}Repository>(() => ${type}RepositoryImpl(container<${type}RemoteDataSource>()));
  container.registerLazySingleton<Get$type>(() => Get$type(container<${type}Repository>()));
''' : ''}
${stateful ? '  container.registerFactory<$controller>(() => $controller(${full ? 'container<Get$type>()' : ''}));' : ''}
''');
      if (useCases.isNotEmpty) {
        final actions = UseCaseEditor(di.source);
        actions.ensureRegistrations(controller, {
          for (final operation in useCases) ...{
            if (!operation.usesFeatureRepository)
              operation.repository:
                  'container.registerLazySingleton<${operation.repository}>(() => ${operation.repository}Impl(container<${type}RemoteDataSource>()));',
            operation.type:
                'container.registerLazySingleton<${operation.type}>(() => ${operation.type}(container<${operation.usesFeatureRepository ? '${type}Repository' : operation.repository}>()));',
          },
        });
        actions.injectController(controller, {
          for (final operation in useCases)
            operation.dependency: 'container<${operation.type}>()',
        });
        di.source = actions.source;
      }
      if (di.source != originalDi) {
        di.addImports([
          for (final operation in useCases) ...[
            if (di.usesUnqualified(operation.type))
              '$base/domain/usecases/${operation.name}.dart',
            if (!operation.usesFeatureRepository &&
                di.usesUnqualified(operation.repository))
              '$base/domain/repositories/${operation.name}_repository.dart',
            if (!operation.usesFeatureRepository &&
                di.usesUnqualified('${operation.repository}Impl'))
              '$base/data/repositories/${operation.name}_repository_impl.dart',
          ],
          ...imports,
          if (di.usesUnqualified('Dio')) 'package:dio/dio.dart',
          if (di.usesUnqualified('GetIt')) 'package:get_it/get_it.dart',
        ]);
        _write(plan, 'lib/app/di/injection.dart', di.source);
      }
    }
    final suffix = full ? 'page' : 'widget';
    final widget = '$type${full ? 'Page' : 'Widget'}';
    final factories = _editor(plan, 'lib/app/composition/feature_pages.dart');
    factories.repairMissing = repairMissing;
    final originalFactories = factories.source;
    final widgetLocation = full
        ? 'presentation/pages/'
        : legacyComponentWidgets
        ? 'widgets/'
        : '';
    final factoryImports = <String>[
      '$base/$widgetLocation${name}_$suffix.dart',
      if (stateful) ...[
        'package:flutter_bloc/flutter_bloc.dart',
        '$base/$statePath/${name}_${state.name}.dart',
        if (bloc && automaticRequest) '$base/$statePath/${name}_event.dart',
      ],
    ];
    factories.addMembers('FeaturePages', '''
  static Widget $member(GetIt container) => ${stateful ? '''BlocProvider<$controller>(
    create: (_) => container<$controller>()${automaticRequest ? (bloc ? '..add(const ${type}Event.requested())' : '..load()') : ''},
    child: const $widget(),
  )''' : 'const $widget()'};
''');
    if (factories.source != originalFactories) {
      factories.addImports([
        ...factoryImports,
        'package:flutter/widgets.dart',
        'package:get_it/get_it.dart',
      ]);
      _write(plan, 'lib/app/composition/feature_pages.dart', factories.source);
    }
    if (full) {
      final names = AstEditor(plan.read('lib/app/router/route_names.dart'));
      if (!repairMissing || !names.hasMember('RouteNames', member)) {
        names.requireUnusedRoutePath('/$name');
        names.addMembers('RouteNames', "static const $member = '/$name';");
        _write(plan, 'lib/app/router/route_names.dart', names.source);
      }
      final router = _editor(plan, 'lib/app/router/app_router.dart');
      router.repairMissing = repairMissing;
      final originalRouter = router.source;
      if (!repairMissing) router.requireUnusedRoutePath('/$name');
      router.addRoutes(
        'GoRoute(path: RouteNames.$member, builder: (context, state) => FeaturePages.$member(container)),',
      );
      if (router.source != originalRouter) {
        router.addImports([
          'route_names.dart',
          '../composition/feature_pages.dart',
          'package:go_router/go_router.dart',
        ]);
        _write(plan, 'lib/app/router/app_router.dart', router.source);
      }
    }
  }

  /// Records individual integration nodes rather than claiming shared files.
  List<Map<String, Object>> integrationOwnership(
    GenerationPlan plan,
    String name, {
    List<UseCaseSpec> useCases = const [],
  }) {
    final type = pascalCase(name);
    final member = camelCase(name);
    final featureNodes = {
      'DI.${type}Api',
      'DI.${type}RemoteDataSource',
      'DI.${type}Repository',
      'DI.Get$type',
      'DI.${type}Cubit',
      'DI.${type}Bloc',
    };
    final actionNodes = {
      for (final operation in useCases) ...[
        'DI.${operation.type}',
        if (!operation.usesFeatureRepository) 'DI.${operation.repository}',
      ],
    };
    return [
      for (final path in [
        'lib/app/di/injection.dart',
        'lib/app/composition/feature_pages.dart',
        'lib/app/router/route_names.dart',
        'lib/app/router/app_router.dart',
      ])
        for (final node in AstEditor(
          plan.read(path),
        ).integrationNodes().entries)
          if (node.key.endsWith('.$member') ||
              featureNodes.contains(node.key) ||
              actionNodes.contains(node.key))
            {
              'path': path,
              'node': node.key,
              'owner': name,
              'sha256': contentDigest(utf8.encode(node.value)),
            },
    ];
  }

  AstEditor _editor(GenerationPlan plan, String path) => AstEditor(
    plan.read(path),
    resolveUri: (uri) => project.dartUri(path, uri),
  );

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
