String getAppIconsContent() {
  return '''abstract class AppImageIcons {
  // icons path in assets
  static const String _iconsPath = 'assets/icons';
  // Images path in assets
  static const String _imagesPath = 'assets/images';
  // Icons
  static const String home = '\$_iconsPath/home.svg';
  static const String search = '\$_iconsPath/search.svg';
  static const String settings = '\$_iconsPath/settings.svg';

  // Images
  static const String logo = '\$_imagesPath/logo.png';
  static const String placeholder = '\$_imagesPath/placeholder.png';
  static const String profile = '\$_imagesPath/profile.png';
  static const String emptyState = '\$_imagesPath/empty_state.png';

  // Illustrations
  static const String success = '\$_imagesPath/success.png';
  static const String error = '\$_imagesPath/error.png';
  static const String noInternet = '\$_imagesPath/no_internet.png';
}
''';
}
