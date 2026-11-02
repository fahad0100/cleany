import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

/// Gives each authored generated file a purpose and documents its entry points.
String documentGeneratedDart(String path, String source) {
  final purpose = switch (path) {
    _ when path.contains('/storage/') => 'Provides encrypted local persistence, platform key management, and storage key definitions.',
    _ when path.endsWith('/app.dart') => 'Builds the application with routing, theme, and Arabic/English localization.',
    _ when path.endsWith('/bootstrap.dart') =>
      'Loads environment settings and dependencies before starting Flutter.',
    _ when path.contains('/config/') =>
      'Defines and validates public application environment configuration.',
    _ when path.contains('/di/') => 'Registers application-scoped services and factory presentation controllers.',
    _ when path.contains('/composition/') =>
      'Creates presentation widgets and owns their Cubit/Bloc providers.',
    _ when path.contains('/router/') =>
      'Defines navigation paths and connects routes to presentation factories.',
    _ when path.endsWith('/failure.dart') => 'Defines domain-safe failures without transport or database dependencies.',
    _ when path.endsWith('/failure_mapper.dart') =>
      'Maps technical exceptions to Failure values at the repository boundary.',
    _ when path.contains('/interceptors/') =>
      'Adds a session token only to requests for the trusted API origin.',
    _ when path.contains('/dio/') =>
      'Configures Dio timeouts, headers, and request interceptors.',
    _ when path.contains('/retrofit/') => 'Declares API endpoints returning raw JSON; Retrofit generates the HTTP implementation.',
    _ when path.contains('/datasources/') =>
      'Fetches raw JSON and propagates exceptions to the repository.',
    _ when path.contains('/models/') =>
      'Defines the API data model and its generated JSON serialization.',
    _ when path.contains('/entities/') =>
      'Defines immutable business data consumed by use cases and presentation.',
    _ when path.endsWith('_repository_impl.dart') => 'Converts JSON/models into entities and returns Success or Failure exactly once.',
    _ when path.contains('/repositories/') => 'Defines the domain repository contract returning an Entity or Failure in a Result.',
    _ when path.contains('/usecases/') =>
      'Exposes one business operation through the domain repository contract.',
    _ when path.endsWith('/use_case_state.dart') => 'Tracks each use case independently with typed loading, success, and failure states.',
    _ when path.endsWith('_state.dart') =>
      'Defines immutable presentation states for the generated Cubit or Bloc.',
    _ when path.endsWith('_event.dart') =>
      'Defines the events that trigger operations in the generated Bloc.',
    _ when path.endsWith('_cubit.dart') || path.endsWith('_bloc.dart') =>
      'Runs presentation actions and emits the corresponding immutable states.',
    _ when path.contains('/pages/') => 'Builds the feature page and renders loading, entity success, and failure states.',
    _ when path.contains('/widgets/') || path.endsWith('_widget.dart') =>
      'Builds a reusable widget and renders its optional presentation state.',
    _ when path.contains('/theme/') =>
      'Provides the shared Material theme for the application.',
    _ when path.contains('main_') || path.endsWith('/main.dart') =>
      'Starts the application using the selected flavor entry point.',
    _ =>
      'Defines shared application values used by the generated architecture.',
  };
  final declarations = parseString(content: source).unit.declarations;
  for (final declaration in declarations.toList().reversed) {
    if (declaration is ClassDeclaration ||
        declaration is FunctionDeclaration ||
        declaration is EnumDeclaration ||
        declaration is GenericTypeAlias) {
      source = source.replaceRange(
        declaration.offset,
        declaration.offset,
        '/// $purpose\n',
      );
    }
  }
  return '// $purpose\n$source';
}
