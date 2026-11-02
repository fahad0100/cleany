// Creates presentation widgets and owns their Cubit/Bloc providers.
// Presentation factories are wired here, keeping the router independent of
// controllers and data-layer implementation details.
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import '../../core/localization/generated/app_localizations.dart';

import 'package:cleany_store/features/carts/presentation/pages/carts_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cleany_store/features/carts/presentation/bloc/carts_bloc.dart';
import 'package:cleany_store/features/carts/presentation/bloc/carts_event.dart';
import 'package:cleany_store/features/users/presentation/pages/users_page.dart';
import 'package:cleany_store/features/users/presentation/cubit/users_cubit.dart';
import 'package:cleany_store/features/auth/presentation/pages/auth_page.dart';
import 'package:cleany_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cleany_store/components/product_card/product_card_widget.dart';
import 'package:cleany_store/features/products/presentation/pages/products_page.dart';
import 'package:cleany_store/features/products/presentation/cubit/products_cubit.dart';
import 'package:cleany_store/components/status_panel/status_panel_widget.dart';
import 'package:cleany_store/components/quantity_stepper/quantity_stepper_widget.dart';
import 'package:cleany_store/components/quantity_stepper/cubit/quantity_stepper_cubit.dart';

/// Creates presentation widgets and owns their Cubit/Bloc providers.
class FeaturePages {
  FeaturePages._();
  static Widget placeholder(GetIt container) => Builder(
    builder: (context) =>
        Center(child: Text(AppLocalizations.of(context).welcome)),
  );

  static Widget carts(GetIt container) => BlocProvider<CartsBloc>(
    create: (_) => container<CartsBloc>()..add(const CartsEvent.requested()),
    child: const CartsPage(),
  );

  static Widget users(GetIt container) => BlocProvider<UsersCubit>(
    create: (_) => container<UsersCubit>()..load(),
    child: const UsersPage(),
  );

  static Widget auth(GetIt container) => BlocProvider<AuthCubit>(
    create: (_) => container<AuthCubit>()..load(),
    child: const AuthPage(),
  );

  static Widget productCard(GetIt container) => const ProductCardWidget();

  static Widget products(GetIt container) => BlocProvider<ProductsCubit>(
    create: (_) => container<ProductsCubit>()..load(),
    child: const ProductsPage(),
  );

  static Widget statusPanel(GetIt container) => const StatusPanelWidget();

  static Widget quantityStepper(GetIt container) =>
      BlocProvider<QuantityStepperCubit>(
        create: (_) => container<QuantityStepperCubit>(),
        child: const QuantityStepperWidget(),
      );
}
