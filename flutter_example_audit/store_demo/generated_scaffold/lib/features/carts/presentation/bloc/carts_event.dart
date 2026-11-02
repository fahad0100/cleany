// Defines the events that trigger operations in the generated Bloc.
import 'package:freezed_annotation/freezed_annotation.dart';

part 'carts_event.freezed.dart';

/// Defines the events that trigger operations in the generated Bloc.
@freezed
sealed class CartsEvent with _$CartsEvent {
  const factory CartsEvent.requested() = CartsRequested;

  /// Requests createCart; observe its status on the feature State.
  const factory CartsEvent.createCartRequested() = CartsCreateCartRequested;

  /// Requests deleteCart; observe its status on the feature State.
  const factory CartsEvent.deleteCartRequested() = CartsDeleteCartRequested;
}
