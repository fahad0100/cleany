// Defines and validates public application environment configuration.
import 'app_environment.dart';

/// Defines and validates public application environment configuration.
class AppConfig {
  const AppConfig({required this.environment, required this.apiBaseUrl});
  final AppEnvironment environment;
  final String apiBaseUrl;

  factory AppConfig.fromEnvironment(
    AppEnvironment environment, {
    String fallbackBaseUrl = '',
  }) {
    const override = String.fromEnvironment('API_BASE_URL');
    final baseUrl = override.isEmpty ? fallbackBaseUrl : override;
    final uri = Uri.tryParse(baseUrl);
    if (uri == null ||
        !uri.hasAuthority ||
        !{'http', 'https'}.contains(uri.scheme) ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        (environment != AppEnvironment.dev && uri.scheme != 'https')) {
      throw StateError(
        'Provide a valid API_BASE_URL; UAT and prod require HTTPS.',
      );
    }
    return AppConfig(environment: environment, apiBaseUrl: baseUrl);
  }
}
