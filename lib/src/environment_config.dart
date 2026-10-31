import 'package:yaml/yaml.dart';

import 'project.dart';

/// Checks public runtime flavor data before dependency/build commands start.
/// An empty URL is intentional when API_BASE_URL will be supplied at runtime.
void validatePublicFlavor(String source, String environment, String path) {
  final yaml = loadYaml(source);
  if (yaml is! Map ||
      yaml['environment'] != environment ||
      yaml['api_base_url'] is! String) {
    throw GenerationException(
      'Invalid $path: set environment: $environment and a public api_base_url string.',
    );
  }
  final url = yaml['api_base_url'] as String;
  if (url.isEmpty) return;
  final uri = Uri.tryParse(url);
  if (uri == null ||
      !uri.hasAuthority ||
      !{'http', 'https'}.contains(uri.scheme) ||
      uri.userInfo.isNotEmpty ||
      uri.hasQuery ||
      uri.hasFragment ||
      (environment != 'dev' && uri.scheme != 'https')) {
    throw GenerationException(
      'Invalid URL in $path. Use HTTP/HTTPS for dev, HTTPS for uat/prod, or an empty string with API_BASE_URL at runtime.',
    );
  }
}
