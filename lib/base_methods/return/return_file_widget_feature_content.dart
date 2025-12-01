import 'package:cleany/content/sub_features_files/date/base_local_data_source_file.dart';
import 'package:cleany/content/sub_features_files/date/base_remote_data_source_file.dart';
import 'package:cleany/content/sub_features_files/date/model_file.dart';
import 'package:cleany/content/sub_features_files/date/repository_data_file.dart';
import 'package:cleany/content/sub_features_files/domain/entity_domain_file.dart';
import 'package:cleany/content/sub_features_files/domain/repository_domain_file.dart';
import 'package:cleany/content/sub_features_files/domain/use_case_domain_file.dart';
import 'package:cleany/content/sub_features_files/presentation/cubit.dart';
import 'package:cleany/content/sub_features_files/presentation/state.dart';
import 'package:cleany/content/sub_features_files/presentation/widget_feature.dart';

String returnFileWidgetFeatureContent({
  required String fileName,
  required String featureName,
  required String basePath,
}) {
  // Data Layer - Remote Data Source
  if (fileName.contains('_remote_data_source.dart')) {
    return baseRemoteDataSourceWidgetFeatureFile(featureName: featureName);
  }

  // Data Layer - Local Data Source
  if (fileName.contains('_local_data_source.dart')) {
    return baseLocalDataSourceWidgetFeatureFile(featureName: featureName);
  }

  // Data Layer - Model
  if (fileName.contains('_model.dart')) {
    return modelDataWidgetFeatureFile(featureName: featureName);
  }

  // Data Layer - Repository Implementation
  if (fileName.contains('_repository_data.dart')) {
    return createRepositoryDataWidgetFeatureFile(featureName: featureName);
  }

  // Domain Layer - Entity
  if (fileName.contains('_entity.dart')) {
    return entityDomainWidgetFeatureFile(featureName: featureName);
  }

  // Domain Layer - Repository Interface
  if (fileName.contains('_repository_domain.dart')) {
    return repositoryDomainWidgetFeatureFile(featureName: featureName);
  }

  // Domain Layer - Use Case
  if (fileName.contains('_use_case.dart')) {
    return useCaseWidgetFeatureFile(featureName: featureName);
  }

  // Presentation Layer - Cubit
  if (fileName.contains('_cubit.dart')) {
    return cubitWidgetFeatureFile(featureName: featureName);
  }

  // Presentation Layer - State
  if (fileName.contains('_state.dart')) {
    return stateWidgetFeatureFile(featureName: featureName);
  }

  // Presentation Layer - Widget
  if (fileName.contains('_feature_widget.dart')) {
    return widgetPageFeatureFile(featureName: featureName);
  }

  return '// TODO: Implement $fileName\n';
}
