import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_carts.dart';
import '../../domain/usecases/create_cart.dart';
import '../../domain/usecases/delete_cart.dart';
import '../../domain/entities/carts_entity.dart';

import 'package:cleany_store/core/state/use_case_state.dart';

import 'carts_state.dart';
import 'carts_event.dart';

/// Generated operation wiring extended with typed requests for the real API.
class CartsBloc extends Bloc<CartsEvent, CartsState> {
  CartsBloc(
    this._getCarts, {
    required this.createCartUseCase,
    required this.deleteCartUseCase,
  }) : super(const CartsState.initial()) {
    on<CartsRequested>(_load);
    on<CartsCreateCartRequested>(_create);
    on<CartsDeleteCartRequested>(_delete);
  }
  final GetCarts _getCarts;
  final CreateCart createCartUseCase;
  final DeleteCart deleteCartUseCase;
  Future<void> reload() async {
    final done = stream
        .firstWhere((s) => s is CartsSuccess || s is CartsFailure)
        .timeout(const Duration(seconds: 40));
    add(const CartsEvent.requested());
    await done;
  }

  Future<void> _load(CartsRequested event, Emitter<CartsState> emit) async {
    if (state is CartsLoading) return;
    emit(
      CartsState.loading(
        createCartStatus: state.createCartStatus,
        deleteCartStatus: state.deleteCartStatus,
      ),
    );
    final result = await _getCarts();
    if (emit.isDone) return;
    result.when(
      (items) => emit(
        CartsState.success(
          items,
          createCartStatus: state.createCartStatus,
          deleteCartStatus: state.deleteCartStatus,
          deletedIds: state.deletedIds,
        ),
      ),
      (f) => emit(
        CartsState.failure(
          f,
          createCartStatus: state.createCartStatus,
          deleteCartStatus: state.deleteCartStatus,
          deletedIds: state.deletedIds,
        ),
      ),
    );
  }

  Future<void> _create(
    CartsCreateCartRequested event,
    Emitter<CartsState> emit,
  ) async {
    if (state.createCartStatus is UseCaseLoading<CartsEntity>) return;
    emit(state.copyWith(createCartStatus: const UseCaseState.loading()));
    final result = await createCartUseCase(event.draft);
    if (emit.isDone) return;
    result.when(
      (cart) =>
          emit(state.copyWith(createCartStatus: UseCaseState.success(cart))),
      (f) => emit(state.copyWith(createCartStatus: UseCaseState.failure(f))),
    );
  }

  Future<void> _delete(
    CartsDeleteCartRequested event,
    Emitter<CartsState> emit,
  ) async {
    if (state.deleteCartStatus is UseCaseLoading<void>) return;
    emit(state.copyWith(deleteCartStatus: const UseCaseState.loading()));
    final result = await deleteCartUseCase(event.id);
    if (emit.isDone) return;
    result.when(
      (_) => emit(
        state.copyWith(
          deleteCartStatus: const UseCaseState<void>.success(null),
          deletedIds: [...state.deletedIds, event.id],
        ),
      ),
      (f) => emit(state.copyWith(deleteCartStatus: UseCaseState.failure(f))),
    );
  }
}
