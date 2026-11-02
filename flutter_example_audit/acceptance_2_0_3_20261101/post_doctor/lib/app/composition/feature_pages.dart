// One composition root owns controller lifetimes; routes know only page factories.
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../components/product_card/product_card_widget.dart';
import '../../components/status_panel/status_panel_widget.dart';
import '../../components/quantity_stepper/quantity_stepper_widget.dart';
import '../../features/products/domain/entities/products_entity.dart';

import '../../core/storage/session_store.dart';
import '../../components/quantity_stepper/cubit/quantity_stepper_cubit.dart';
import '../../features/products/presentation/cubit/products_cubit.dart';
import '../../features/products/presentation/pages/products_page.dart';
import '../../features/carts/domain/entities/cart_draft.dart';
import '../../features/carts/presentation/bloc/carts_bloc.dart';
import '../../features/carts/presentation/bloc/carts_event.dart';
import '../../features/carts/presentation/pages/carts_page.dart';
import '../../features/users/presentation/cubit/users_cubit.dart';
import '../../features/users/presentation/pages/users_page.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/pages/auth_page.dart';

class FeaturePages {
  FeaturePages._();
  static Widget products(GetIt container) => BlocProvider(
    create: (_) => container<ProductsCubit>()
      ..load()
      ..getFeaturedProduct(),
    child: ProductsPage(
      createQuantityController: () => container<QuantityStepperCubit>(),
    ),
  );
  static Widget carts(GetIt container, {CartDraft? draft}) => BlocProvider(
    create: (_) {
      final bloc = container<CartsBloc>()..add(const CartsEvent.requested());
      if (draft != null) {
        bloc.add(
          CartsEvent.createCartRequested(
            CartDraft(
              productId: draft.productId,
              quantity: draft.quantity,
              userId: container<SessionStore>().value?.userId ?? 1,
            ),
          ),
        );
      }
      return bloc;
    },
    child: const CartsPage(),
  );
  static Widget users(GetIt container) => BlocProvider(
    create: (_) => container<UsersCubit>()..load(),
    child: const UsersPage(),
  );
  static Widget auth(GetIt container) => BlocProvider(
    create: (_) => container<AuthCubit>(),
    child: AuthPage(session: container<SessionStore>()),
  );

  /// Keeps Cleany's reusable component entrypoints while requiring real inputs.
  static Widget productCard(
    GetIt container, {
    required ProductsEntity product,
    required VoidCallback onTap,
    required VoidCallback onAdd,
  }) => ProductCardWidget(product: product, onTap: onTap, onAdd: onAdd);

  static Widget statusPanel(GetIt container, {required String title}) =>
      StatusPanelWidget(title: title);

  static Widget quantityStepper(
    GetIt container, {
    ValueChanged<int>? onChanged,
  }) => BlocProvider(
    create: (_) => container<QuantityStepperCubit>(),
    child: QuantityStepperWidget(onChanged: onChanged),
  );
}
