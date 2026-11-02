import 'dart:io';

import 'package:cleany/cleany.dart';
import 'package:test/test.dart';

/// Exercises real builders and Flutter runtime after customization, for both
/// transport providers. No external API is required for deterministic behavior.
void main() {
  for (final provider in ApiProvider.values) {
    test(
      'custom contracts, alternate Entity and warm validation (${provider.name})',
      () async {
        final directory = Directory.systemTemp.createTempSync(
          'cleany_contract_${provider.name}_',
        );
        try {
          final project = Project(directory.path);
          File(project.file('pubspec.yaml')).writeAsStringSync('''
name: contract_fixture
environment:
  sdk: ^3.13.0
dependencies:
  flutter:
    sdk: flutter
dev_dependencies:
  flutter_test:
    sdk: flutter
flutter:
  uses-material-design: true
''');
          final generator = Generator(project);
          final progress = <OperationEvent>[];
          final transaction = GenerationTransaction(
            project,
            context: OperationContext(
              onProgress: (e) {
                progress.add(e);
                print(
                  '[${provider.name}] ${e.command ?? e.stage} ${e.detail ?? ''}',
                );
              },
            ),
          );
          Future<void> source(GenerationPlan plan) async {
            await transaction.apply(
              plan,
              install: false,
              build: false,
              analyze: false,
            );
          }

          await source(
            generator.initialize(
              appId: 'com.cleany.contract',
              provider: provider,
            ),
          );
          await source(
            generator.generate(name: 'catalog', state: StateManagement.cubit),
          );
          await source(
            generator.generate(name: 'profile', state: StateManagement.bloc),
          );
          await source(
            generator.generate(
              name: 'types',
              state: StateManagement.cubit,
              specification: FeatureSpec(
                fields: [
                  FieldSpec('id', 'string'),
                  FieldSpec('count', 'int'),
                  FieldSpec('price', 'double'),
                  FieldSpec('enabled', 'bool'),
                  FieldSpec('createdAt', 'datetime'),
                  FieldSpec('values', 'list'),
                  FieldSpec('tags', 'list<string>'),
                  FieldSpec('integers', 'list<int>'),
                  FieldSpec('numbers', 'list<num>'),
                  FieldSpec('rows', 'list<map<string,dynamic>>'),
                  FieldSpec('metadata', 'map<string,dynamic>'),
                  FieldSpec('selection', 'set'),
                  FieldSpec('payload', 'dynamic'),
                  FieldSpec('optionalValues', 'list?'),
                  FieldSpec('optionalRows', 'list<map<string,dynamic>>?'),
                  FieldSpec('optionalMap', 'map<string,dynamic>?'),
                  FieldSpec('optionalSet', 'set?'),
                ],
              ),
            ),
          );
          final entity = File(
            project.file(
              'lib/features/catalog/domain/entities/catalog_entity.dart',
            ),
          );
          entity.writeAsStringSync(
            entity.readAsStringSync().replaceFirst(
              'required String id',
              'required String id, required double rating',
            ),
          );
          final model = File(
            project.file('lib/features/catalog/data/models/catalog_model.dart'),
          );
          model.writeAsStringSync(
            '''${model.readAsStringSync().replaceFirst('required String id', 'required String id, required RatingModel rating')}
class RatingModel {
 const RatingModel(this.rate);
 final double rate;
 factory RatingModel.fromJson(Map<String,dynamic> json)=>RatingModel((json['rate'] as num).toDouble());
 Map<String,dynamic> toJson()=>{'rate':rate};
}
''',
          );
          final repository = File(
            project.file(
              'lib/features/catalog/data/repositories/catalog_repository_impl.dart',
            ),
          );
          repository.writeAsStringSync(
            repository.readAsStringSync().replaceFirst(
              'CatalogEntity(id: model.id)',
              'CatalogEntity(id: model.id, rating: model.rating.rate)',
            ),
          );
          // Existing Data code can use its own error helper and omit the
          // template's mapper import; the new method must add its own imports.
          repository.writeAsStringSync(
            '${repository.readAsStringSync().replaceAll(RegExp(r"import '[^']*failure_mapper.dart';\n"), '').replaceAll('mapFailure(error)', '_mapExistingFailure(error)')}\nFailure _mapExistingFailure(Object error) => const UnexpectedFailure();\n',
          );
          await source(
            generator.addUseCase(
              feature: 'catalog',
              name: 'refresh_catalog',
              returnType: UseCaseReturnType.entity,
            ),
          );
          final summary = File(
            project.file(
              'lib/features/catalog/domain/entities/summary_entity.dart',
            ),
          );
          summary.writeAsStringSync(
            'class SummaryEntity { const SummaryEntity({required this.total}); final int total; }\n',
          );
          await source(
            generator.addUseCase(
              feature: 'profile',
              name: 'summarize_profile',
              returnType: UseCaseReturnType.entity,
              entityName: 'SummaryEntity',
            ),
          );
          // A developer connects only the explicit Data mapping hook.
          final profile = File(
            project.file(
              'lib/features/profile/data/repositories/profile_repository_impl.dart',
            ),
          );
          profile.writeAsStringSync(
            profile.readAsStringSync().replaceFirst(
              RegExp(
                r"throw UnimplementedError\(\s*'Map ProfileModel to SummaryEntity for summarizeProfile\.'\s*,?\s*\);",
              ),
              'return SummaryEntity(total: model.id.length);',
            ),
          );
          expect(
            profile.readAsStringSync(),
            contains('return SummaryEntity(total: model.id.length)'),
          );
          final test = File(project.file('test/contract_test.dart'))
            ..parent.createSync(recursive: true);
          test.writeAsStringSync(_runtimeTests(provider));
          final beforeModels = [
            entity.readAsBytesSync(),
            model.readAsBytesSync(),
            summary.readAsBytesSync(),
          ];
          final report = ProjectDoctor(project).inspect();
          expect(
            report.plan.files.containsKey(
              'lib/features/catalog/data/models/catalog_model.dart',
            ),
            isFalse,
          );
          await transaction.apply(report.plan);
          (await executeCommand('flutter', [
            'test',
            '--no-pub',
            'test/contract_test.dart',
          ], project.root)).requireSuccess('custom contract runtime');
          // Compare two equivalent stateless component operations. Only the
          // second can reuse metadata; neither skips builders or analysis.
          await ProjectMaintenance(project).cleanCache();
          final cold = Stopwatch()..start();
          await transaction.apply(
            generator.generate(
              name: 'cold_card',
              state: StateManagement.none,
              kind: GenerationKind.component,
            ),
          );
          cold.stop();
          final warm = Stopwatch()..start();
          await transaction.apply(
            generator.generate(
              name: 'plain_card',
              state: StateManagement.none,
              kind: GenerationKind.component,
            ),
          );
          warm.stop();
          expect(
            progress.any((e) => e.detail == 'reusing validated compiler cache'),
            isTrue,
          );
          expect(entity.readAsBytesSync(), beforeModels[0]);
          expect(model.readAsBytesSync(), beforeModels[1]);
          expect(summary.readAsBytesSync(), beforeModels[2]);
          print(
            'VALIDATION_TIMING ${provider.name}: cold=${cold.elapsedMilliseconds}ms warm=${warm.elapsedMilliseconds}ms',
          );
          // Missing operation files restore their chosen Entity, without resetting Models.
          File(
            project.file(
              'lib/features/profile/domain/usecases/summarize_profile.dart',
            ),
          ).deleteSync();
          await transaction.apply(ProjectDoctor(project).inspect().plan);
          (await executeCommand('flutter', [
            'test',
            '--no-pub',
            'test/contract_test.dart',
          ], project.root)).requireSuccess('repaired custom contracts');
        } finally {
          directory.deleteSync(recursive: true);
        }
      },
      skip: Platform.environment['CLEANY_FLUTTER_INTEGRATION'] != 'true',
      timeout: const Timeout(Duration(minutes: 15)),
    );
  }
}

String _runtimeTests(ApiProvider provider) =>
    '''
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:contract_fixture/core/errors/failure.dart';
import 'package:contract_fixture/core/state/use_case_state.dart';
${provider == ApiProvider.retrofit ? "import 'package:contract_fixture/core/network/retrofit/catalog_api.dart';\nimport 'package:contract_fixture/core/network/retrofit/profile_api.dart';\nimport 'package:contract_fixture/core/network/retrofit/types_api.dart';" : ''}
import 'package:contract_fixture/features/catalog/data/datasources/catalog_remote_data_source.dart';
import 'package:contract_fixture/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:contract_fixture/features/catalog/domain/usecases/get_catalog.dart';
import 'package:contract_fixture/features/catalog/domain/usecases/refresh_catalog.dart';
import 'package:contract_fixture/features/catalog/presentation/cubit/catalog_cubit.dart';
import 'package:contract_fixture/features/catalog/domain/entities/catalog_entity.dart';
import 'package:contract_fixture/features/catalog/domain/entities/summary_entity.dart';
import 'package:contract_fixture/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:contract_fixture/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:contract_fixture/features/profile/domain/usecases/get_profile.dart';
import 'package:contract_fixture/features/profile/domain/usecases/summarize_profile.dart';
import 'package:contract_fixture/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:contract_fixture/features/profile/presentation/bloc/profile_event.dart';
import 'package:contract_fixture/features/types/data/models/types_model.dart';
import 'package:contract_fixture/features/types/data/datasources/types_remote_data_source.dart';
import 'package:contract_fixture/features/types/data/repositories/types_repository_impl.dart';
class CatalogRemote extends CatalogRemoteDataSource {
 CatalogRemote():super(${provider == ApiProvider.retrofit ? 'CatalogApi(Dio())' : 'Dio()'});
 @override Future<Map<String,dynamic>> fetch()async=>{'id':'one','rating':{'rate':3.5}};
 @override Future<Map<String,dynamic>> refreshCatalog()=>fetch();
}
class ProfileRemote extends ProfileRemoteDataSource {
 ProfileRemote():super(${provider == ApiProvider.retrofit ? 'ProfileApi(Dio())' : 'Dio()'});
 @override Future<Map<String,dynamic>> fetch()async=>{'id':'profile'};
 @override Future<Map<String,dynamic>> summarizeProfile()=>fetch();
}
final json=<String,dynamic>{'id':'one','count':2,'price':3.5,'enabled':true,
 'createdAt':'2026-11-01T00:00:00.000Z','values':[1,'two',null],
 'tags':['one'],'integers':[1,2],'numbers':[1,2.5],
 'rows':[{'name':'one','count':1}],'metadata':{'active':true},
 'selection':['one','two'],'payload':{'nested':[null,1]},
 'optionalValues':null,'optionalRows':null,'optionalMap':null,'optionalSet':null};
class TypesRemote extends TypesRemoteDataSource {
 TypesRemote():super(${provider == ApiProvider.retrofit ? 'TypesApi(Dio())' : 'Dio()'});
 @override Future<Map<String,dynamic>> fetch()async=>json;
}
void main(){
 test('all supported JSON types serialize and map into domain',()async{
  final model=TypesModel.fromJson(json);expect(model.toJson(),json);
  final entity=(await TypesRepositoryImpl(TypesRemote()).fetch()).tryGetSuccess()!;
  expect(entity.selection,{'one','two'});expect(entity.rows.single['name'],'one');
  expect(entity.numbers,[1,2.5]);expect(entity.values,[1,'two',null]);expect(entity.createdAt,DateTime.utc(2026,11,1));
  expect(entity.payload,{'nested':[null,1]});
  expect(entity.optionalRows,isNull);expect(entity.optionalSet,isNull);
 });
 test('mismatched data/domain shapes preserve the primary mapping and action Failure',()async{
  final repository=CatalogRepositoryImpl(CatalogRemote());
  final cubit=CatalogCubit(GetCatalog(repository),refreshCatalogUseCase:RefreshCatalog(repository));addTearDown(cubit.close);
  await cubit.load();expect((cubit.state.catalogStatus as UseCaseSuccess<CatalogEntity>).value.rating,3.5);
  await cubit.refreshCatalog();expect(cubit.state.refreshCatalogStatus,isA<UseCaseFailure<CatalogEntity>>());
  expect((cubit.state.refreshCatalogStatus as UseCaseFailure<CatalogEntity>).failure,isA<UnexpectedFailure>());
 });
 test('alternate Entity action runs through shared repository, Data hook and Bloc',()async{
  final repository=ProfileRepositoryImpl(ProfileRemote());
  final bloc=ProfileBloc(GetProfile(repository),summarizeProfileUseCase:SummarizeProfile(repository));addTearDown(bloc.close);
  final done=bloc.stream.firstWhere((s)=>s.summarizeProfileStatus is UseCaseSuccess<SummaryEntity>);
  bloc.add(const ProfileEvent.summarizeProfileRequested());await done;
  expect((bloc.state.summarizeProfileStatus as UseCaseSuccess<SummaryEntity>).value.total,7);
 });
}
''';
