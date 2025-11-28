import 'package:injectable/injectable.dart';

@Singleton(order: 1)
class LocalKeysService {
  LocalKeysService();

  // Auth Keys
  final String accessToken = 'access_token';
  final String refreshToken = 'refresh_token';
  final String userId = 'user_id';
  final String isLoggedIn = 'is_logged_in';

  // Settings Keys
  final String theme = 'theme_mode';
  final String language = 'language';
  final String notificationsEnabled = 'notifications_enabled';

  // User Preferences
  final String userName = 'user_name';
  final String userEmail = 'user_email';
  final String userAvatar = 'user_avatar';
}

