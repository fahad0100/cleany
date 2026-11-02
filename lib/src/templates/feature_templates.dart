import '../project.dart';
import '../specification.dart';
import 'feature_context.dart';
import 'feature_data.dart';
import 'feature_domain.dart';
import 'feature_presentation.dart';
import 'use_case_templates.dart';

/// One fixed architecture; modules separate rendering responsibilities by layer.
Map<String, String> featureTemplates({
  required String name,
  required String path,
  required String package,
  required GenerationKind kind,
  required StateManagement state,
  required ApiProvider provider,
  FeatureSpec? specification,
  List<UseCaseSpec> useCases = const [],
  bool legacyComponentWidgets = false,
  bool localComponentScope = true,
  bool singleState = true,
  bool splitPrimaryState = false,
  String? primaryStatus,
}) {
  final context = FeatureTemplateContext(
    name: name,
    path: path,
    package: package,
    kind: kind,
    state: state,
    provider: provider,
    specification: specification,
    legacyComponentWidgets: legacyComponentWidgets,
    localComponentScope: localComponentScope,
    singleState: singleState,
    splitPrimaryState: splitPrimaryState,
    primaryStatusName: primaryStatus,
  );
  final files = {
    ...featureDomainFiles(context),
    ...featureDataFiles(context),
    ...featurePresentationFiles(context),
  };
  final applied = <UseCaseSpec>[];
  for (final operation in useCases) {
    applied.add(operation);
    files.addAll(addUseCaseToFeature(context, operation, applied, files));
  }
  return files;
}
