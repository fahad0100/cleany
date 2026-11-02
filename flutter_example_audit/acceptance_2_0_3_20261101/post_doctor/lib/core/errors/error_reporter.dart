import 'dart:developer' as developer;

typedef ErrorReporter = void Function(Object error, StackTrace stackTrace);

/// Logs diagnostics without serializing request bodies, credentials or tokens.
void reportUnexpectedError(Object error, StackTrace stackTrace) {
  developer.log(
    'Unexpected ${error.runtimeType}',
    name: 'cleany_store',
    stackTrace: stackTrace,
    level: 1000,
  );
}
