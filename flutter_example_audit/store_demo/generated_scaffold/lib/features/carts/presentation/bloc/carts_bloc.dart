// Runs presentation actions and emits the corresponding immutable states.
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cleany_store/features/carts/domain/usecases/get_carts.dart';

import 'carts_state.dart';
import 'carts_event.dart';

import 'package:cleany_store/features/carts/domain/usecases/create_cart.dart';
import 'package:cleany_store/core/state/use_case_state.dart';
import 'package:cleany_store/core/errors/failure.dart';
import 'package:cleany_store/features/carts/domain/entities/carts_entity.dart';
import 'package:cleany_store/features/carts/domain/usecases/delete_cart.dart';

/// Runs presentation actions and emits the corresponding immutable states.
class CartsBloc extends Bloc<CartsEvent, CartsState> {
  final GetCarts _getCarts;
  CartsBloc(this._getCarts, {this.createCartUseCase, this.deleteCartUseCase})
    : super(const CartsState.initial()) {
    on<CartsRequested>(_onRequested);

    on<CartsCreateCartRequested>(_onCreateCartRequested);

    on<CartsDeleteCartRequested>(_onDeleteCartRequested);
  }

  Future<void> _onRequested(
    CartsRequested event,
    Emitter<CartsState> emit,
  ) async {
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
      (entity) => emit(
        CartsState.success(
          entity,
          createCartStatus: state.createCartStatus,
          deleteCartStatus: state.deleteCartStatus,
        ),
      ),
      (failure) => emit(
        CartsState.failure(
          failure,
          createCartStatus: state.createCartStatus,
          deleteCartStatus: state.deleteCartStatus,
        ),
      ),
    );
  }

  /// Optional for existing manual construction; central DI always supplies this action.
  final CreateCart? createCartUseCase;

  /// Updates only createCartStatus; other actions keep their current state.
  Future<void> _onCreateCartRequested(
    CartsCreateCartRequested event,
    Emitter<CartsState> emit,
  ) async {
    if (state.createCartStatus is UseCaseLoading<CartsEntity>) {
      return;
    }
    emit(
      state.copyWith(
        createCartStatus: const UseCaseState<CartsEntity>.loading(),
      ),
    );
    final useCase = createCartUseCase;
    if (useCase == null) {
      emit(
        state.copyWith(
          createCartStatus: const UseCaseState<CartsEntity>.failure(
            UnexpectedFailure('This action is unavailable.'),
          ),
        ),
      );
      return;
    }
    final result = await useCase();
    if (emit.isDone) {
      return;
    }
    result.when(
      (entity) => emit(
        state.copyWith(
          createCartStatus: UseCaseState<CartsEntity>.success(entity),
        ),
      ),
      (failure) => emit(
        state.copyWith(
          createCartStatus: UseCaseState<CartsEntity>.failure(failure),
        ),
      ),
    );
  }

  /// Optional for existing manual construction; central DI always supplies this action.
  final DeleteCart? deleteCartUseCase;

  /// Updates only deleteCartStatus; other actions keep their current state.
  Future<void> _onDeleteCartRequested(
    CartsDeleteCartRequested event,
    Emitter<CartsState> emit,
  ) async {
    if (state.deleteCartStatus is UseCaseLoading<void>) {
      return;
    }
    emit(state.copyWith(deleteCartStatus: const UseCaseState<void>.loading()));
    final useCase = deleteCartUseCase;
    if (useCase == null) {
      emit(
        state.copyWith(
          deleteCartStatus: const UseCaseState<void>.failure(
            UnexpectedFailure('This action is unavailable.'),
          ),
        ),
      );
      return;
    }
    final result = await useCase();
    if (emit.isDone) {
      return;
    }
    result.when(
      (_) => emit(
        state.copyWith(
          deleteCartStatus: const UseCaseState<void>.success(null),
        ),
      ),
      (failure) => emit(
        state.copyWith(deleteCartStatus: UseCaseState<void>.failure(failure)),
      ),
    );
  }
}
