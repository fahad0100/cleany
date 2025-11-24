String appImagesFile() {
  return '''
class AppImages {
  AppImages._();
  // Base path
  static const String _basePath = 'assets/images';
  static const String _iconsPath = 'assets/icons';
  
  // Images
  static const String logo = '\$_basePath/logo.png';
  static const String placeholder = '\$_basePath/placeholder.png';
  static const String profile = '\$_basePath/profile.png';
  static const String emptyState = '\$_basePath/empty_state.png';
  
  // Icons
  static const String home = '\$_iconsPath/home.svg';
  static const String search = '\$_iconsPath/search.svg';
  static const String settings = '\$_iconsPath/settings.svg';
  
  // Illustrations
  static const String success = '\$_basePath/success.png';
  static const String error = '\$_basePath/error.png';
  static const String noInternet = '\$_basePath/no_internet.png';
}

''';
}
