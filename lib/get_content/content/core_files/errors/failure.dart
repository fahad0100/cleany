String failureFile() {
  return '''
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Internal Server Error']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No Internet Connection']);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Connection Timeout']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Unauthorized Access']);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission Denied']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache Error']);
}

class FormatFailure extends Failure {
  const FormatFailure([super.message = 'Data Parsing Error']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Unexpected Error']);
}

''';
}
