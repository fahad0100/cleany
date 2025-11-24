String failureFile() {
  return '''
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network connection failed']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Unauthorized access']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed']);
}

class OtherFailure extends Failure {
  const OtherFailure([super.message = 'Validation failed']);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Network connection failed']);
}

class CancelledFailure extends Failure {
  const CancelledFailure([super.message = 'Network connection failed']);
}

''';
}
