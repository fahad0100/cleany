String appEnumsFile() {
  return '''

enum LoadingState { initial, loading, success, error }

enum NetworkStatus { connected, disconnected, unknown }

enum AuthStatus { authenticated, unauthenticated, unknown }

''';
}
