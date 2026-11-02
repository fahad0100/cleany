import 'dart:convert';
import 'dart:io';

import 'package:cleany/cleany.dart';
import 'package:test/test.dart';
import 'package:yaml_edit/yaml_edit.dart';

void main() {
  test(
    'generated config overrides and encrypted storage run on Flutter and compile for web',
    () async {
      final directory = Directory.systemTemp.createTempSync(
        'cleany_config_storage_',
      );
      try {
        final project = Project(directory.path);
        (await executeCommand('flutter', [
          'create',
          '--empty',
          '--no-pub',
          '--project-name',
          'storage_fixture',
          '--platforms',
          'web',
          directory.path,
        ], directory.parent.path)).requireSuccess('create web fixture');
        File(project.file('pubspec.yaml')).writeAsStringSync('''
name: storage_fixture
environment:
  sdk: ^3.13.0
dependencies:
  flutter:
    sdk: flutter
dev_dependencies:
  flutter_test:
    sdk: flutter
  path_provider_platform_interface: ^2.1.3
flutter:
  uses-material-design: true
''');
        final generator = Generator(project);
        Future<void> source(GenerationPlan plan) async {
          await GenerationTransaction(project)
              .apply(plan, install: false, build: false, analyze: false);
        }

        await source(
          generator.initialize(
            appId: 'com.example.storage',
            provider: ApiProvider.dio,
          ),
        );
        for (final key in ['SUPPORT_EMAIL', 'EMPTY_ALLOWED']) {
          await source(
            AppConfigValues(project).add(
              key: key,
              values: {
                for (final e in ['dev', 'uat', 'prod']) e: '$e-value',
              },
            ),
          );
        }
        for (final e in ['dev', 'uat', 'prod']) {
          final path = 'config/flavors/$e.yaml';
          final yaml = YamlEditor(project.read(path))
            ..update(['api_base_url'], 'https://$e.example.com');
          File(project.file(path)).writeAsStringSync(yaml.toString());
        }
        File(project.file('test/config_storage_test.dart'))
          ..parent.createSync(recursive: true)
          ..writeAsStringSync(_tests);
        Future<void> run(
          List<String> arguments, {
          String executable = 'flutter',
        }) async {
          final result = await executeCommand(
            executable,
            arguments,
            project.root,
          );
          print(result.output);
          result.requireSuccess('$executable ${arguments.join(' ')}');
        }

        await run(['pub', 'get']);
        await run(['gen-l10n']);
        await run(['run', 'build_runner', 'build'], executable: 'dart');
        await run(['analyze', '--no-pub']);
        await run([
          'test',
          '--no-pub',
          'test/config_storage_test.dart',
          '--reporter',
          'expanded',
        ]);
        await run([
          'test',
          '--no-pub',
          'test/config_storage_test.dart',
          '--dart-define=SUPPORT_EMAIL=override-value',
          '--dart-define=EMPTY_ALLOWED=',
          '--dart-define=DB_SECRET_KEY=${base64Encode(List.generate(32, (i) => i + 1))}',
          '--reporter',
          'expanded',
        ]);
        // No dart:io imports leak through the web adapter. This is compilation,
        // not a claim that browser vault integration has been tested on device.
        await run([
          'build',
          'web',
          '--debug',
          '--no-pub',
          '--target=lib/main_dev.dart',
          '--dart-define=API_BASE_URL=https://example.com',
        ]);
      } finally {
        directory.deleteSync(recursive: true);
      }
    },
    skip: Platform.environment['CLEANY_FLUTTER_INTEGRATION'] != 'true',
    timeout: const Timeout(Duration(minutes: 12)),
  );
}

const _tests = r'''
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:get_it/get_it.dart';
import 'package:storage_fixture/app/app.dart';
import 'package:storage_fixture/app/bootstrap.dart';
import 'package:storage_fixture/app/config/app_config.dart';
import 'package:storage_fixture/app/config/app_environment.dart';
import 'package:storage_fixture/app/config/flavor_config.dart';
import 'package:storage_fixture/app/di/injection.dart';
import 'package:storage_fixture/core/storage/app_local_storage.dart';
import 'package:storage_fixture/core/storage/storage_extension/storage_cipher.dart';
import 'package:storage_fixture/core/storage/storage_extension/storage_key_store.dart';
import 'package:storage_fixture/core/storage/storage_extension/storage_exceptions.dart';
import 'package:storage_fixture/core/storage/local_keys.dart';

class Vault implements StorageKeyStore {
  final data=<String,String>{};
  int writes=0;
  @override Future<String?> read(String key)async=>data[key];
  @override Future<void> write(String key,String value)async {
    writes++;
    await Future<void>.delayed(const Duration(milliseconds:10));
    data[key]=value;
  }
}
class Paths extends PathProviderPlatform {
  Paths(this.directory);
  final Directory directory;
  @override Future<String?> getApplicationSupportPath()async=>directory.path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  var sequence=0;
  Future<Database> memory(String name)=>databaseFactoryMemory.openDatabase('$name-${sequence++}');
  final key=base64Encode(List.generate(32,(i)=>i+1));

  testWidgets('real bootstrap makes AppConfig and owned storage readable from page context', (tester) async {
    final directory=Directory.systemTemp.createTempSync('bootstrap_context_');
    final previous=PathProviderPlatform.instance;
    AppLocalStorage? storage;
    try {
      PathProviderPlatform.instance=Paths(directory);
      await tester.runAsync(() => bootstrap(AppEnvironment.dev));
      await tester.pump();
      await tester.pump();
      final context=tester.element(find.descendant(of:find.byType(App),matching:find.byType(Text)).first);
      final config=context.read<AppConfig>();
      expect(config.environment,AppEnvironment.dev);
      expect(config.isDebug,kDebugMode);
      expect(config.apiBaseUrl,'https://dev.example.com');
      expect(config.supportEmail,const bool.hasEnvironment('SUPPORT_EMAIL')?'override-value':'dev-value');
      expect(identical(tester.element(find.byType(App)).read<AppConfig>(),config),isTrue);
      final providedStorage=context.read<AppLocalStorage>();
      storage=providedStorage;
      await tester.runAsync(() => providedStorage.put(key:'from-page',value:config.supportEmail));
      expect(await tester.runAsync(() => providedStorage.get<String>(key:'from-page')),config.supportEmail);
      await tester.pumpWidget(const SizedBox.shrink());
      // Allow the app-owned DI scope to finish asynchronous disposal.
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds:20)));
      await expectLater(providedStorage.get<String>(key:'from-page'),throwsStateError);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      final opened=storage;
      if (opened != null) { await tester.runAsync(opened.close); }
      PathProviderPlatform.instance=previous;
      directory.deleteSync(recursive:true);
    }
  });

  test('all flavor values flow into typed fields and explicit defines take precedence, including empty strings',()async {
    for (final environment in AppEnvironment.values) {
      final flavor=await FlavorConfig.load(environment);
      final config=AppConfig.fromEnvironment(environment, fallbackBaseUrl:flavor.apiBaseUrl,values:flavor.values);
      expect(config.apiBaseUrl,'https://${environment.name}.example.com');
      expect(config.isDebug,kDebugMode);
      expect(AppConfig(environment:environment,apiBaseUrl:config.apiBaseUrl).isDebug,kDebugMode);
      expect(config.supportEmail,const bool.hasEnvironment('SUPPORT_EMAIL')?'override-value':'${environment.name}-value');
      expect(config.emptyAllowed,const bool.hasEnvironment('EMPTY_ALLOWED')?'':'${environment.name}-value');
      expect(config.dbSecretKey,const bool.hasEnvironment('DB_SECRET_KEY')?const String.fromEnvironment('DB_SECRET_KEY'):'pass_key_storage');
      expect(flavor.values['db_secret_key'],'pass_key_storage');
    }
    if (!const bool.hasEnvironment('SUPPORT_EMAIL')) {
      expect(()=>AppConfig.fromEnvironment(AppEnvironment.dev,fallbackBaseUrl:'https://example.com',values:{'support_email':42}),throwsStateError);
    }
  });

  test('default password derives salted keys, reopens and rejects wrong passwords without resetting data',() async {
    final name='password-${sequence++}';
    final metadata=StoreRef<String,Object?>('cleany_storage_metadata');
    final vault=Vault();
    var db=await databaseFactoryMemory.openDatabase(name);
    var storage=await AppLocalStorage.open(environment:'dev',database:db,keyStore:vault);
    await storage.put(key:'keep',value:'original');
    final salt=await metadata.record('password_salt_v1').get(db);
    expect(base64Decode(salt as String),hasLength(32));
    expect(vault.writes,0,reason:'The default is a password, not an alias for auto.');
    await storage.close();
    db=await databaseFactoryMemory.openDatabase(name);
    await expectLater(AppLocalStorage.open(environment:'dev',database:db,dbSecretKey:'wrong-password'),throwsA(isA<StorageIntegrityException>()));
    db=await databaseFactoryMemory.openDatabase(name);
    storage=await AppLocalStorage.open(environment:'dev',database:db);
    expect(await storage.get<String>(key:'keep'),'original');
    expect(await metadata.record('password_salt_v1').get(db),salt);
    await storage.close();
    db=await databaseFactoryMemory.openDatabase(name);
    await metadata.record('password_salt_v1').delete(db);
    await db.close();
    db=await databaseFactoryMemory.openDatabase(name);
    await expectLater(AppLocalStorage.open(environment:'dev',database:db),throwsA(isA<StorageIntegrityException>()));
    db=await databaseFactoryMemory.openDatabase(name);
    expect(await metadata.record('password_salt_v1').exists(db),isFalse);
    await metadata.record('password_salt_v1').put(db,salt);
    await db.close();
    final otherDb=await memory('different-salt');
    final other=await AppLocalStorage.open(environment:'dev',database:otherDb);
    expect(await metadata.record('password_salt_v1').get(otherDb),isNot(salt));
    await other.close();
    await expectLater(AppLocalStorage.open(environment:'dev',dbSecretKey:''),throwsArgumentError);
  });

  test('real IO persistence uses the platform adapters, encrypts keys/values and reopens with the vault key',()async {
    final directory=Directory.systemTemp.createTempSync('storage_io_');
    final previous=PathProviderPlatform.instance;
    PathProviderPlatform.instance=Paths(directory);
    FlutterSecureStorage.setMockInitialValues({});
    try {
      var storage=await AppLocalStorage.open(environment:'dev',dbSecretKey:'auto');
      await storage.put(key:'private_user_profile_123456789',value:{'secret':'top-secret-value-123456789'});
      await storage.put(key:LocalKeys.languageCode,value:'ar');
      await storage.close();
      final bytes=File('${directory.path}/app_local_v1_dev.db').readAsStringSync();
      expect(bytes,isNot(contains('top-secret-value-123456789')));
      expect(bytes,isNot(contains('private_user_profile_123456789')));
      storage=await AppLocalStorage.open(environment:'dev',dbSecretKey:'auto');
      expect((await storage.get<Map<String,Object?>>(key:'private_user_profile_123456789'))!['secret'],'top-secret-value-123456789');
      expect(await storage.get<String>(key:LocalKeys.languageCode),'ar');
      await storage.clear();
      expect(await storage.containsKey(key:LocalKeys.languageCode),isFalse);
      await storage.close();
      storage=await AppLocalStorage.open(environment:'dev',dbSecretKey:'auto');
      expect(await storage.get<String>(key:LocalKeys.languageCode),isNull);
      await storage.close();
    } finally {
      PathProviderPlatform.instance=previous;
      directory.deleteSync(recursive:true);
    }
  });

  test('typed CRUD supports Sembast JSON/Blob/Timestamp, mismatch, decoder, removal and disposal',()async {
    final storage=await AppLocalStorage.open(environment:'dev',database:await memory('crud'),dbSecretKey:key);
    final stamp=Timestamp.fromDateTime(DateTime.utc(2026,11,2));
    final blob=Blob(Uint8List.fromList([1,2,3]));
    await storage.put(key:'json',value:{'list':[1,2,null],'enabled':true,'nested':{'value':3.5}});
    await storage.put(key:'stamp',value:stamp);
    await storage.put(key:'blob',value:blob);
    await storage.put(key:'ints',value:[1,2,3]);
    expect((await storage.get<Map<String,Object?>>(key:'json'))!['enabled'],isTrue);
    expect(await storage.get<Timestamp>(key:'stamp'),stamp);
    expect(await storage.get<Blob>(key:'blob'),blob);
    expect(await storage.get<int>(key:'json'),isNull);
    expect(await storage.get<List<int>>(key:'ints',decode:(value)=>(value as List).cast<int>()),[1,2,3]);
    await expectLater(storage.put<Object?>(key:'null',value:null),throwsArgumentError);
    await expectLater(storage.put(key:'bad',value:Object()),throwsArgumentError);
    expect(await storage.containsKey(key:'json'),isTrue);
    await storage.remove(key:'json');
    expect(await storage.get<Object>(key:'json'),isNull);
    await storage.close();
    await storage.close();
    await expectLater(storage.get<String>(key:'x'),throwsStateError);
  });

  test('same value has fresh nonces; tampering and copying envelopes to another key fail authentication',()async {
    final db=await memory('tamper');
    final storage=await AppLocalStorage.open(environment:'dev',database:db,dbSecretKey:key);
    final raw=StoreRef<String,Object?>.main();
    await storage.put(key:'first',value:'same');
    final a=(await raw.find(db)).single;
    final previous=a.value;
    await storage.put(key:'first',value:'same');
    final updated=(await raw.find(db)).single;
    expect(updated.value,isNot(equals(previous)));
    await storage.put(key:'second',value:'different');
    final second=(await raw.find(db)).singleWhere((item)=>item.key!=a.key);
    await raw.record(second.key).put(db,updated.value);
    await expectLater(storage.get<String>(key:'second'),throwsA(isA<StorageIntegrityException>()));
    final envelope=Map<String,Object?>.from(updated.value! as Map);
    final bytes=base64Decode(envelope['c']! as String)..[0]^=1;
    envelope['c']=base64Encode(bytes);
    await raw.record(a.key).put(db,envelope);
    await expectLater(storage.get<String>(key:'first'),throwsA(isA<StorageIntegrityException>()));
    await storage.close();
  });

  test('wrong keys and missing vault keys fail closed and preserve existing data',()async {
    final name='key-failure-${sequence++}';
    final vault=Vault();
    var db=await databaseFactoryMemory.openDatabase(name);
    var storage=await AppLocalStorage.open(environment:'uat',database:db,dbSecretKey:'auto',keyStore:vault);
    await storage.put(key:'keep',value:'original');
    await storage.close();
    db=await databaseFactoryMemory.openDatabase(name);
    await expectLater(AppLocalStorage.open(environment:'uat',database:db,dbSecretKey:base64Encode(List.filled(32,9))),throwsA(isA<StorageIntegrityException>()));
    final empty=Vault();
    db=await databaseFactoryMemory.openDatabase(name);
    await expectLater(AppLocalStorage.open(environment:'uat',database:db,dbSecretKey:'auto',keyStore:empty),throwsA(isA<StorageKeyUnavailableException>()));
    expect(empty.writes,0);
    db=await databaseFactoryMemory.openDatabase(name);
    storage=await AppLocalStorage.open(environment:'uat',database:db,dbSecretKey:'auto',keyStore:vault);
    expect(await storage.get<String>(key:'keep'),'original');
    await storage.close();
  });

  test('first-use key generation is serialized and data writes remain consistent',()async {
    final vault=Vault();
    final keys=await Future.wait(List.generate(10,(_)=>StorageKeyResolver.resolve(namespace:'prod',configuredKey:'auto',hasData:false,keyStore:vault)));
    expect(vault.writes,1);
    for(final value in keys) { expect(value,keys.first); }
    final storage=await AppLocalStorage.open(environment:'prod',database:await memory('concurrent'),dbSecretKey:'auto',keyStore:vault);
    await Future.wait(List.generate(20,(i)=>storage.put(key:'k$i',value:i)));
    for(var i=0;i<20;i++) { expect(await storage.get<int>(key:'k$i'),i); }
    await storage.close();
    final cipher=StorageCipher(keys.first,'prod');
    expect(cipher.recordId('key'),isNot('key'));
  });

  test('app DI owns the storage and closes it with its scope',()async {
    final storage=await AppLocalStorage.open(environment:'dev',database:await memory('di'),dbSecretKey:key);
    final container=GetIt.asNewInstance();
    await configureDependencies(container,const AppConfig(environment:AppEnvironment.dev,apiBaseUrl:'https://example.com'),localStorage:storage);
    expect(identical(container<AppLocalStorage>(),storage),isTrue);
    await storage.put(key:'value',value:1);
    await disposeDependencies(container);
    await expectLater(storage.get<int>(key:'value'),throwsStateError);
  });
}
''';
