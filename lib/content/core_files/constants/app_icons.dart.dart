String appIconsFile() {
  return '''
abstract class AppIcons {
  // Base path
  static const String _iconsPath = 'assets/icons';

  // Icons
  static const String home = '\$_iconsPath/home.svg';
  static const String search = '\$_iconsPath/search.svg';
  static const String settings = '\$_iconsPath/settings.svg';
}

''';
}
