String failureFile() {
  return '''
import 'package:equatable/equatable.dart';

/// Base failure class
abstract class Failure extends Equatable {
  final String message;

  const Failure([this.message = 'Something went wrong']);

  @override
  List<Object?> get props => [message];
}

// ──────────────────────────────────────────────────────────────
// Network
// ──────────────────────────────────────────────────────────────

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Connection timeout']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found']);
}

class TooManyRequestsFailure extends Failure {
  const TooManyRequestsFailure([super.message = 'Too many requests']);
}

// ──────────────────────────────────────────────────────────────
// Auth
// ──────────────────────────────────────────────────────────────

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Unauthorized']);
}

class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure([super.message = 'Session expired']);
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure([super.message = 'Invalid credentials']);
}

class EmailAlreadyExistsFailure extends Failure {
  const EmailAlreadyExistsFailure([super.message = 'Email already exists']);
}

class WeakPasswordFailure extends Failure {
  const WeakPasswordFailure([super.message = 'Password is too weak']);
}

class AccountDisabledFailure extends Failure {
  const AccountDisabledFailure([super.message = 'Account disabled']);
}

// ──────────────────────────────────────────────────────────────
// Data
// ──────────────────────────────────────────────────────────────

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed']);
}

class EmptyDataFailure extends Failure {
  const EmptyDataFailure([super.message = 'No data available']);
}

class FormatFailure extends Failure {
  const FormatFailure([super.message = 'Invalid data format']);
}

// ──────────────────────────────────────────────────────────────
// Storage
// ──────────────────────────────────────────────────────────────

class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Storage error']);
}

class UploadFailure extends Failure {
  const UploadFailure([super.message = 'Upload failed']);
}

class DownloadFailure extends Failure {
  const DownloadFailure([super.message = 'Download failed']);
}

// ──────────────────────────────────────────────────────────────
// Device
// ──────────────────────────────────────────────────────────────

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission denied']);
}

class LocationFailure extends Failure {
  const LocationFailure([super.message = 'Location error']);
}

class CameraFailure extends Failure {
  const CameraFailure([super.message = 'Camera error']);
}

// ──────────────────────────────────────────────────────────────
// Payment
// ──────────────────────────────────────────────────────────────

class PaymentFailure extends Failure {
  const PaymentFailure([super.message = 'Payment failed']);
}

class SubscriptionFailure extends Failure {
  const SubscriptionFailure([super.message = 'Subscription error']);
}

// ──────────────────────────────────────────────────────────────
// Generic
// ──────────────────────────────────────────────────────────────

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Unknown error']);
}

class CancelledFailure extends Failure {
  const CancelledFailure([super.message = 'Cancelled']);
}


''';
}
