import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/cart_draft.dart';
part 'carts_event.freezed.dart';

@freezed
sealed class CartsEvent with _$CartsEvent {
  const factory CartsEvent.requested() = CartsRequested;
  const factory CartsEvent.createCartRequested(CartDraft draft) =
      CartsCreateCartRequested;
  const factory CartsEvent.deleteCartRequested(int id) =
      CartsDeleteCartRequested;
}
