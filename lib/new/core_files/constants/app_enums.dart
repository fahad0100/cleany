String getAppEnumsContent() {
  return """
/// Define available environments.
enum FlavorEnum { dev, prod }

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

""";
}
