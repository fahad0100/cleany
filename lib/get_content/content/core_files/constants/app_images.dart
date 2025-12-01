String appImagesFile() {
  return '''
abstract class AppImages {
  // Base path
  static const String _basePath = 'assets/images';

  // Images
  static const String logo = '\$_basePath/logo.png';
  static const String placeholder = '\$_basePath/placeholder.png';
  static const String profile = '\$_basePath/profile.png';
  static const String emptyState = '\$_basePath/empty_state.png';

  // Illustrations
  static const String success = '\$_basePath/success.png';
  static const String error = '\$_basePath/error.png';
  static const String noInternet = '\$_basePath/no_internet.png';
}

''';
}
