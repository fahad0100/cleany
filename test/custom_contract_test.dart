import 'dart:io';

import 'package:cleany/cleany.dart';
import 'package:cleany/src/cli.dart';
import 'package:cleany/src/registry.dart';
import 'package:cleany/src/workspace.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  late Directory root;
  late Project project;
  late Generator generator;
  setUp(() async {
    root = Directory.systemTemp.createTempSync('cleany_custom_contract_');
    project = Project(root.path);
    File(project.file('pubspec.yaml')).writeAsStringSync('''
name: custom_app
environment:
  sdk: ^3.13.0
dependencies:
  flutter:
    sdk: flutter
''');
    generator = Generator(project);
    await apply(generator.initialize(appId: 'com.example.custom'));
  });
  tearDown(() => root.deleteSync(recursive: true));

  for (final entry in {
    'string': 'String',
    'int': 'int',
    'double': 'double',
    'bool': 'bool',
    'datetime': 'DateTime',
    'list': 'List<dynamic>',
    'list<string>': 'List<String>',
    'list<int>': 'List<int>',
    'list<num>': 'List<num>',
    'list<map<string,dynamic>>': 'List<Map<String, dynamic>>',
    'map<string,dynamic>': 'Map<String, dynamic>',
    'set': 'Set<dynamic>',
    'dynamic': 'dynamic',
  }.entries) {
    test('normalizes ${entry.key} and nullable round trips', () {
      final field = FieldSpec('value', entry.key);
      expect(field.type, entry.value);
      final nullable = FieldSpec('value', '${entry.key}?');
      expect(nullable.nullable, isTrue);
      expect(
        nullable.type,
        entry.value == 'dynamic' ? 'dynamic' : '${entry.value}?',
      );
      expect(FieldSpec.fromJson(nullable.toJson()).type, nullable.type);
    });
  }

  test('Doctor preserves known nested Models and continues past unsupported discoveries', () async {
    await apply(
      generator.generate(name: 'catalog', state: StateManagement.cubit),
    );
    final path = 'lib/features/catalog/data/models/catalog_model.dart';
    final file = File(project.file(path));
    file.writeAsStringSync(
      file.readAsStringSync().replaceFirst(
        'required String id',
        'required String id, required RatingModel rating',
      ),
    );
    final before = file.readAsBytesSync();
    // A second, unregistered customized feature must not stop all diagnosis.
    final source = Directory(project.file('lib/features/catalog'));
    final other = Directory(project.file('lib/features/custom'));
    for (final original in source.listSync(recursive: true).whereType<File>()) {
      final relative = p
          .relative(original.path, from: source.path)
          .replaceAll('catalog', 'custom');
      final destination = File(p.join(other.path, relative))
        ..parent.createSync(recursive: true);
      destination.writeAsStringSync(
        original
            .readAsStringSync()
            .replaceAll('Catalog', 'Custom')
            .replaceAll('catalog', 'custom'),
      );
    }
    final report = ProjectDoctor(project).inspect();
    expect(
      report.issues.any(
        (issue) =>
            issue.code == 'custom_specification' &&
            !issue.repairable &&
            issue.message.contains('custom'),
      ),
      isTrue,
    );
    expect(report.plan.files.containsKey(path), isFalse);
    await apply(report.plan);
    expect(file.readAsBytesSync(), before);
    expect(Directory(project.file('lib/features/custom')).existsSync(), isTrue);
  });

  test('mismatched Entity and Model get a typed mapping hook without schema changes', () async {
    await apply(
      generator.generate(name: 'catalog', state: StateManagement.cubit),
    );
    final model = File(
      project.file('lib/features/catalog/data/models/catalog_model.dart'),
    );
    model.writeAsStringSync(
      model.readAsStringSync().replaceFirst('String id', 'int id'),
    );
    final before = model.readAsBytesSync();
    final plan = generator.addUseCase(
      feature: 'catalog',
      name: 'refresh_catalog',
      returnType: UseCaseReturnType.entity,
    );
    final implementation = plan.read(
      'lib/features/catalog/data/repositories/catalog_repository_impl.dart',
    );
    expect(
      implementation,
      contains('CatalogEntity _mapRefreshCatalogEntity(CatalogModel model)'),
    );
    expect(
      implementation,
      contains('return Success(_mapRefreshCatalogEntity(model))'),
    );
    expect(implementation, contains("Map CatalogModel to CatalogEntity"));
    await apply(plan);
    expect(model.readAsBytesSync(), before);
    final entry = (FeatureRegistry(project).read()['features'] as List).single;
    final operation = UseCaseSpec.fromJson(
      Map<String, dynamic>.from((entry['use_cases'] as List).single),
    );
    expect(operation.mappingPending, isTrue);
    expect(operation.entityType, 'CatalogEntity');
    final useCase = File(
      project.file('lib/features/catalog/domain/usecases/refresh_catalog.dart'),
    );
    useCase.deleteSync();
    final repair = ProjectDoctor(project).inspect().plan;
    expect(
      repair.read('lib/features/catalog/domain/usecases/refresh_catalog.dart'),
      contains('Result<CatalogEntity, Failure>'),
    );
  });

  test('alternate existing Entity propagates to repository, Cubit/Bloc states and recovery', () async {
    for (final mode in [StateManagement.cubit, StateManagement.bloc]) {
      final name = 'catalog_${mode.name}';
      await apply(generator.generate(name: name, state: mode));
      final entity = File(
        project.file('lib/shared/domain/entities/summary_entity.dart'),
      )..parent.createSync(recursive: true);
      entity.writeAsStringSync(
        'class SummaryEntity { const SummaryEntity({required this.total}); final double total; }\n',
      );
      final operationName = 'summarize_${mode.name}';
      final plan = generator.addUseCase(
        feature: name,
        name: operationName,
        returnType: UseCaseReturnType.entity,
        entityName: 'SummaryEntity',
      );
      for (final path in [
        'domain/usecases/$operationName.dart',
        'domain/repositories/${name}_repository.dart',
        'data/repositories/${name}_repository_impl.dart',
        'presentation/${mode.name}/${name}_state.dart',
        'presentation/${mode.name}/${name}_${mode.name}.dart',
      ]) {
        expect(
          plan.read('lib/features/$name/$path'),
          contains('SummaryEntity'),
          reason: path,
        );
        expect(
          plan.read('lib/features/$name/$path'),
          contains('shared/domain/entities/summary_entity.dart'),
          reason: path,
        );
      }
      expect(
        plan.files.containsKey(
          'lib/shared/domain/entities/summary_entity.dart',
        ),
        isFalse,
      );
      await apply(plan);
      File(
        project.file('lib/features/$name/domain/usecases/$operationName.dart'),
      ).deleteSync();
      final repair = ProjectDoctor(project).inspect().plan;
      expect(
        repair.read('lib/features/$name/domain/usecases/$operationName.dart'),
        contains('Result<SummaryEntity, Failure>'),
      );
      await apply(repair);
    }
  });

  test(
    'Entity selection rejects missing and ambiguous names without writing',
    () async {
      await apply(
        generator.generate(name: 'catalog', state: StateManagement.cubit),
      );
      expect(
        () => generator.addUseCase(
          feature: 'catalog',
          name: 'refresh_catalog',
          returnType: UseCaseReturnType.entity,
          entityName: 'MissingEntity',
        ),
        throwsA(isA<GenerationException>()),
      );
      for (final folder in ['one', 'two']) {
        final file = File(
          project.file('lib/$folder/domain/entities/summary_entity.dart'),
        )..parent.createSync(recursive: true);
        file.writeAsStringSync('class SummaryEntity {}\n');
      }
      expect(
        () => generator.addUseCase(
          feature: 'catalog',
          name: 'refresh_catalog',
          returnType: UseCaseReturnType.entity,
          entityName: 'SummaryEntity',
        ),
        throwsA(isA<GenerationException>()),
      );
      final plan = generator.addUseCase(
        feature: 'catalog',
        name: 'refresh_catalog',
        returnType: UseCaseReturnType.entity,
        entityName: 'lib/one/domain/entities/summary_entity.dart',
      );
      expect(
        plan.read('lib/features/catalog/domain/usecases/refresh_catalog.dart'),
        contains('one/domain/entities/summary_entity.dart'),
      );
      expect(
        File(
          project.file(
            'lib/features/catalog/domain/usecases/refresh_catalog.dart',
          ),
        ).existsSync(),
        isFalse,
      );
    },
  );

  test('cross-feature Entity metadata follows rename/move', () async {
    await apply(
      generator.generate(name: 'catalog', state: StateManagement.cubit),
    );
    await apply(
      generator.generate(name: 'account', state: StateManagement.cubit),
    );
    await apply(
      generator.addUseCase(
        feature: 'account',
        name: 'read_catalog',
        returnType: UseCaseReturnType.entity,
        entityName: 'CatalogEntity',
      ),
    );
    await apply(
      FeatureLifecycle(project).renameMove(
        name: 'catalog',
        kind: GenerationKind.feature,
        newName: 'inventory',
        destination: 'lib/modules',
      ),
    );
    final entry = (FeatureRegistry(project).read()['features'] as List)
        .firstWhere((e) => e['name'] == 'account');
    expect(
      (entry['use_cases'] as List).single['entity_type'],
      'InventoryEntity',
    );
    expect(
      (entry['use_cases'] as List).single['entity_path'],
      'lib/modules/inventory/domain/entities/inventory_entity.dart',
    );
    expect(
      project.read('lib/features/account/domain/usecases/read_catalog.dart'),
      contains('Result<InventoryEntity, Failure>'),
    );
  });

  test(
    'CLI accepts all requested compact types and selected Entity name',
    () async {
      final types = [
        'string',
        'int',
        'double',
        'bool',
        'datetime',
        'list',
        'list<string>',
        'list<num>',
        'list<map<string,dynamic>>',
        'map<string,dynamic>',
        'set',
        'dynamic',
      ];
      final input = [
        '1',
        'catalog',
        '1',
        '1',
        '2',
        '${types.length}',
        for (var i = 0; i < types.length; i++) ...[
          'field$i:${types[i]}:key$i',
          'n',
        ],
        '1',
        '3',
        '1',
        'refresh_catalog',
        '2',
        '',
        '1',
        '0',
      ].iterator;
      final output = StringBuffer();
      expect(
        await runCli(
          [],
          projectRoot: project.root,
          output: output,
          error: StringBuffer(),
          readLine: () => input.moveNext() ? input.current : null,
          executor: (_, _, _) async => const CommandResult(0, '', ''),
        ),
        0,
        reason: '$output',
      );
      final entry =
          (FeatureRegistry(project).read()['features'] as List).single;
      final fields = (entry['specification']['fields'] as List);
      expect(fields[5]['type'], 'List<dynamic>');
      expect(fields.last['type'], 'dynamic');
      expect(
        (entry['use_cases'] as List).single['entity_type'],
        'CatalogEntity',
      );
    },
  );

  test('native flavor setup reuses the real default icon and preserves explicit icon settings', () {
    Directory(project.file('ios/Runner/Assets.xcassets/AppIcon.appiconset'))
        .createSync(recursive: true);
    var plan = planPlatformFlavors(project, {'ios'});
    var config = loadYaml(plan.stageOverrides['flavorizr.yaml']!) as Map;
    for (final flavor in ['dev', 'uat', 'prod']) {
      expect(
        config['flavors'][flavor]['ios']['buildSettings']['ASSETCATALOG_COMPILER_APPICON_NAME'],
        'AppIcon',
      );
    }
    final flavorFile = File(project.file('flavorizr.yaml'));
    flavorFile.writeAsStringSync(
      flavorFile.readAsStringSync().replaceFirst(
        'bundleId: "com.example.custom.dev"',
        'bundleId: "com.example.custom.dev"\n      buildSettings:\n        ASSETCATALOG_COMPILER_APPICON_NAME: CustomIcon',
      ),
    );
    plan = planPlatformFlavors(project, {'ios'});
    config = loadYaml(plan.stageOverrides['flavorizr.yaml']!) as Map;
    expect(
      config['flavors']['dev']['ios']['buildSettings']['ASSETCATALOG_COMPILER_APPICON_NAME'],
      'CustomIcon',
    );
    flavorFile.writeAsStringSync(
      flavorFile.readAsStringSync().replaceFirst(
        'bundleId: "com.example.custom.uat"',
        'bundleId: "com.example.custom.uat"\n      icon: assets/custom.png',
      ),
    );
    config = loadYaml(
      planPlatformFlavors(project, {'ios'}).stageOverrides['flavorizr.yaml']!,
    ) as Map;
    expect(
      (config['flavors']['uat']['ios'] as Map).containsKey('buildSettings'),
      isFalse,
    );
  });

  test(
    'interrupted caches reset while unrecognized cache contents are preserved',
    () async {
      var workspace = StagedWorkspace(
        project,
        OperationContext(),
        cacheIdentity: 'sdk',
      );
      await workspace.create();
      final metadata = File(
        p.join(workspace.directory.path, '.dart_tool/build/stale'),
      )..parent.createSync(recursive: true);
      metadata.writeAsStringSync('incomplete');
      // Simulate a process dying before dispose: marker stays active.
      workspace = StagedWorkspace(
        project,
        OperationContext(),
        cacheIdentity: 'sdk',
      );
      await workspace.create();
      expect(metadata.existsSync(), isFalse);
      await workspace.dispose();
      final foreign = File(project.file('.cleany/cache/validation/user_file'))
        ..parent.createSync(recursive: true);
      foreign.writeAsStringSync('preserve');
      final context = OperationContext();
      workspace = StagedWorkspace(project, context, cacheIdentity: 'sdk');
      await workspace.create();
      expect(workspace.directory.path, contains('stage_'));
      expect(context.warnings, isNotEmpty);
      await workspace.dispose();
      expect(foreign.readAsStringSync(), 'preserve');
    },
  );

  test('compiler cache retains only metadata, refreshes sources and resets after failure/SDK changes', () async {
    final context = OperationContext();
    var workspace = StagedWorkspace(project, context, cacheIdentity: 'sdk-one');
    await workspace.create();
    final firstPath = workspace.directory.path;
    final metadata = File(
      p.join(firstPath, '.dart_tool/build/entrypoint/compiled'),
    )..parent.createSync(recursive: true);
    metadata.writeAsStringSync('compiler');
    final output = File(p.join(firstPath, 'lib/stale.dart'))
      ..parent.createSync(recursive: true);
    output.writeAsStringSync('stale');
    await workspace.dispose(preserveCache: true);
    expect(output.existsSync(), isFalse);
    expect(metadata.existsSync(), isTrue);
    workspace = StagedWorkspace(project, context, cacheIdentity: 'sdk-one');
    await workspace.create();
    expect(workspace.directory.path, firstPath);
    expect(metadata.existsSync(), isTrue);
    expect(File(p.join(firstPath, 'lib/stale.dart')).existsSync(), isFalse);
    await workspace.dispose(preserveCache: true);
    workspace = StagedWorkspace(project, context, cacheIdentity: 'sdk-two');
    await workspace.create();
    expect(metadata.existsSync(), isFalse);
    await workspace.dispose();
    expect(Directory(firstPath).existsSync(), isFalse);
  });

  test(
    'maintenance clears only owned warm caches and preserves backups',
    () async {
      final workspace = StagedWorkspace(
        project,
        OperationContext(),
        cacheIdentity: 'sdk',
      );
      await workspace.create();
      await workspace.dispose(preserveCache: true);
      final backup = File(project.file('.cleany/backups/keep.txt'))
        ..parent.createSync(recursive: true);
      backup.writeAsStringSync('keep');
      expect(await ProjectMaintenance(project).cleanCache(), 1);
      expect(backup.readAsStringSync(), 'keep');
    },
  );
}

Future<void> apply(GenerationPlan plan) async {
  await GenerationTransaction(plan.project)
      .apply(plan, install: false, build: false, analyze: false);
}
