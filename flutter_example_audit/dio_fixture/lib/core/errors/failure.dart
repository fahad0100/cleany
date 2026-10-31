// Defines domain-safe failures without transport or database dependencies.
// Domain-safe failures: no transport, framework, or database imports.
/// Defines domain-safe failures without transport or database dependencies.
sealed class Failure {
  const Failure(this.message);
  final String message;
}

/// Defines domain-safe failures without transport or database dependencies.
final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Check your connection.']);
}

/// Defines domain-safe failures without transport or database dependencies.
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Please sign in again.']);
}

/// Defines domain-safe failures without transport or database dependencies.
final class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Invalid data.']);
}

/// Defines domain-safe failures without transport or database dependencies.
final class BusinessFailure extends Failure {
  const BusinessFailure(super.message);
}

/// Defines domain-safe failures without transport or database dependencies.
final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'The service is unavailable.']);
}

/// Defines domain-safe failures without transport or database dependencies.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred.']);
}
