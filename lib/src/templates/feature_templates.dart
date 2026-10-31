import '../project.dart';
import '../specification.dart';
import 'feature_context.dart';
import 'feature_data.dart';
import 'feature_domain.dart';
import 'feature_presentation.dart';

/// One fixed architecture; modules separate rendering responsibilities by layer.
Map<String, String> featureTemplates({
  required String name,
  required String path,
  required String package,
  required GenerationKind kind,
  required StateManagement state,
  required ApiProvider provider,
  FeatureSpec? specification,
}) {
  final context = FeatureTemplateContext(
    name: name,
    path: path,
    package: package,
    kind: kind,
    state: state,
    provider: provider,
    specification: specification,
  );
  return {
    ...featureDomainFiles(context),
    ...featureDataFiles(context),
    ...featurePresentationFiles(context),
  };
}
