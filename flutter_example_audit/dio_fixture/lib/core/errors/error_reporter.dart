// Defines shared application values used by the generated architecture.
import 'dart:developer' as developer;

/// Defines shared application values used by the generated architecture.
/// Reports unexpected technical errors without exposing them through the domain.
typedef ErrorReporter = void Function(Object error, StackTrace stackTrace);

/// Defines shared application values used by the generated architecture.
void reportUnexpectedError(Object error, StackTrace stackTrace) {
  developer.log(
    'Unexpected application error',
    name: 'app.errors',
    error: error,
    stackTrace: stackTrace,
    level: 1000,
  );
}
