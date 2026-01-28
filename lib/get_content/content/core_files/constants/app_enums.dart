String appEnumsFile() {
  return '''

enum LoadingState { initial, loading, success, error }

enum NetworkStatus { connected, disconnected, unknown }

enum StateLoadUser { local, remote }

enum AuthStatus { authenticated, unauthenticated, unknown }

enum LanguagesEnum {
  ar,
  en;

  String get displayCode => name.toUpperCase();
  String get displayName {
    switch (name) {
      case 'ar':
        return "العربية";
      default:
        return "English";
    }
  }
}

''';
}
