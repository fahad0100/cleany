String createGlobalStateFile() {
  return '''
import 'package:equatable/equatable.dart';

class ChangeState extends Equatable {
  const ChangeState();

  @override
  List<Object?> get props => [];
}

class ChangeImageLoadedState extends ChangeState {}

class ChangeImageLoadedState2 extends ChangeState {}

''';
}
