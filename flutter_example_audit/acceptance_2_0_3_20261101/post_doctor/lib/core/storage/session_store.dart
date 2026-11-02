import 'package:flutter/foundation.dart';

/// In-memory demo session. Never retains passwords or writes tokens to disk.
class SessionData {
  const SessionData({
    required this.accessToken,
    required this.username,
    required this.userId,
  });
  final String accessToken;
  final String username;
  final int userId;
  @override
  String toString() => 'SessionData(userId: $userId)';
}

class SessionStore extends ValueNotifier<SessionData?> {
  SessionStore() : super(null);
  void signIn(SessionData session) {
    value = session;
  }

  void signOut() {
    value = null;
  }
}
