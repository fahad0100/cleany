import 'package:cleany/content/features_files/date/base_remote_data_source_file.dart';
import 'package:cleany/content/features_files/date/model_file.dart';
import 'package:cleany/content/features_files/date/repository_data_file.dart';
import 'package:cleany/content/features_files/domain/entity_domain_file.dart';
import 'package:cleany/content/features_files/domain/repository_domain_file.dart';
import 'package:cleany/content/features_files/domain/use_case_domain_file.dart';
import 'package:cleany/content/features_files/presentation/cubit.dart';
import 'package:cleany/content/features_files/presentation/screen_feature.dart';
import 'package:cleany/content/features_files/presentation/state.dart';
import 'package:cleany/content/features_files/presentation/widget.dart';
import 'package:cleany/content/sub_features_files/date/base_local_data_source_file.dart';

String returnFileScreenFeatureContent({
  required String fileName,
  required String featureName,
}) {
  // Data Layer - Remote Data Source
  if (fileName.contains('_remote_data_source.dart')) {
    return baseRemoteDataScreenFeatureFile(featureName: featureName);
  }

  // Data Layer - Local Data Source
  if (fileName.contains('_local_data_source.dart')) {
    return baseLocalDataSourceWidgetFeatureFile(featureName: featureName);
  }

  // Data Layer - Model
  if (fileName.contains('_model.dart')) {
    return modelDataScreenFeature(featureName: featureName);
  }

  // Data Layer - Repository Implementation
  if (fileName.contains('_repository_data.dart')) {
    return createRepositoryDataScreenFeatureFile(featureName: featureName);
  }

  // Domain Layer - Entity
  if (fileName.contains('_entity.dart')) {
    return entityDomainScreenFeatureFile(featureName: featureName);
  }

  // Domain Layer - Repository Interface
  if (fileName.contains('_repository_domain.dart')) {
    return repositoryDomainScreenFeatureFile(featureName: featureName);
  }

  // Domain Layer - Use Case
  if (fileName.contains('_use_case.dart')) {
    return useCaseScreenFeatureFile(featureName: featureName);
  }

  // Presentation Layer - Cubit
  if (fileName.contains('_cubit.dart')) {
    return cubitScreenFeatureFile(featureName: featureName);
  }

  // Presentation Layer - State
  if (fileName.contains('_state.dart')) {
    return stateScreenFeatureFile(featureName: featureName);
  }

  // Presentation Layer - Page
  if (fileName.contains('_feature_screen.dart')) {
    return screenPageFeatureFile(featureName: featureName);
  }

  // Presentation Layer - Widget
  if (fileName.contains('_widget.dart')) {
    return widgetScreenFeatureFile(featureName: featureName);
  }

  return '// TODO: Implement $fileName\n';
}
