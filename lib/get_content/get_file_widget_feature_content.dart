import 'package:cleany/get_content/content/features_files/date/base_remote_data_source_file.dart';
import 'package:cleany/get_content/content/features_files/date/model_file.dart';
import 'package:cleany/get_content/content/features_files/date/repository_data_file.dart';
import 'package:cleany/get_content/content/features_files/di/di.dart';
import 'package:cleany/get_content/content/features_files/domain/entity_domain_file.dart';
import 'package:cleany/get_content/content/features_files/domain/repository_domain_file.dart';
import 'package:cleany/get_content/content/features_files/domain/use_case_domain_file.dart';
import 'package:cleany/get_content/content/features_files/presentation/cubit.dart';
import 'package:cleany/get_content/content/features_files/presentation/state.dart';
import 'package:cleany/get_content/content/features_files/presentation/widget_feature.dart';

String getFileWidgetFeatureContent({
  required String fileName,
  required String featureName,
  String? ownFeaturesName,
}) {
  // Data Layer - Remote Data Source

  if (fileName.contains('_remote_data_source.dart')) {
    return baseRemoteDataScreenFeatureFile(
      featureName: featureName,
      ownFeaturesName: ownFeaturesName,
      isSub: true,
    );
  }
  // DI Layer feature

  if (fileName.contains('di.dart')) {
    return diFeatureFile(
      featureName: featureName,
      ownFeaturesName: ownFeaturesName,
      isSub: true,
    );
  }
  // Data Layer - Model
  if (fileName.contains('_model.dart')) {
    return modelDataScreenFeature(
      featureName: featureName,
      ownFeaturesName: ownFeaturesName,
      isSub: true,
    );
  }

  // Data Layer - Repository Implementation
  if (fileName.contains('_repository_data.dart')) {
    return createRepositoryDataScreenFeatureFile(
      featureName: featureName,
      ownFeaturesName: ownFeaturesName,
      isSub: true,
    );
  }

  // Domain Layer - Entity
  if (fileName.contains('_entity.dart')) {
    return entityDomainScreenFeatureFile(
      featureName: featureName,
      ownFeaturesName: ownFeaturesName,
    );
  }

  // Domain Layer - Repository Interface
  if (fileName.contains('_repository_domain.dart')) {
    return repositoryDomainScreenFeatureFile(
      featureName: featureName,
      ownFeaturesName: ownFeaturesName,
      isSub: true,
    );
  }

  // Domain Layer - Use Case
  if (fileName.contains('_use_case.dart')) {
    return useCaseScreenFeatureFile(
      featureName: featureName,
      ownFeaturesName: ownFeaturesName,
      isSub: true,
    );
  }

  // Presentation Layer - Cubit
  if (fileName.contains('_cubit.dart')) {
    return cubitScreenFeatureFile(
      featureName: featureName,
      ownFeaturesName: ownFeaturesName,
      isSub: true,
    );
  }

  // Presentation Layer - State
  if (fileName.contains('_state.dart')) {
    return stateScreenFeatureFile(
      featureName: featureName,
      ownFeaturesName: ownFeaturesName,
    );
  }

  // Presentation Layer - Widget
  if (fileName.contains('_feature_widget.dart')) {
    return widgetPageFeatureFile(
      featureName: featureName,
      ownFeaturesName: ownFeaturesName,
      isSub: true,
    );
  }

  return '// TODO: Implement $fileName\n';
}
