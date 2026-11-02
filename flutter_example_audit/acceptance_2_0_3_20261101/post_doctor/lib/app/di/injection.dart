// Registers application-scoped services and factory presentation controllers.
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../config/app_config.dart';
import '../config/store_preferences.dart';
import '../../core/storage/session_store.dart';
import '../../core/network/dio/dio_client.dart';

import 'package:cleany_store/features/carts/data/datasources/carts_remote_data_source.dart';
import 'package:cleany_store/features/carts/data/repositories/carts_repository_impl.dart';
import 'package:cleany_store/features/carts/domain/repositories/carts_repository.dart';
import 'package:cleany_store/features/carts/domain/usecases/get_carts.dart';
import 'package:cleany_store/core/network/retrofit/carts_api.dart';
import 'package:cleany_store/features/carts/presentation/bloc/carts_bloc.dart';
import 'package:cleany_store/features/users/data/datasources/users_remote_data_source.dart';
import 'package:cleany_store/features/users/data/repositories/users_repository_impl.dart';
import 'package:cleany_store/features/users/domain/repositories/users_repository.dart';
import 'package:cleany_store/features/users/domain/usecases/get_users.dart';
import 'package:cleany_store/core/network/retrofit/users_api.dart';
import 'package:cleany_store/features/users/presentation/cubit/users_cubit.dart';
import 'package:cleany_store/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:cleany_store/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:cleany_store/features/auth/domain/repositories/auth_repository.dart';
import 'package:cleany_store/features/auth/domain/usecases/get_auth.dart';
import 'package:cleany_store/core/network/retrofit/auth_api.dart';
import 'package:cleany_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cleany_store/features/products/data/datasources/products_remote_data_source.dart';
import 'package:cleany_store/features/products/data/repositories/products_repository_impl.dart';
import 'package:cleany_store/features/products/domain/repositories/products_repository.dart';
import 'package:cleany_store/features/products/domain/usecases/get_products.dart';
import 'package:cleany_store/core/network/retrofit/products_api.dart';
import 'package:cleany_store/features/products/presentation/cubit/products_cubit.dart';
import 'package:cleany_store/components/quantity_stepper/cubit/quantity_stepper_cubit.dart';
import 'package:cleany_store/features/products/domain/usecases/get_featured_product.dart';
import 'package:cleany_store/features/carts/domain/usecases/create_cart.dart';
import 'package:cleany_store/features/carts/domain/usecases/delete_cart.dart';
import 'package:cleany_store/features/users/domain/usecases/get_user_profile.dart';
import 'package:cleany_store/features/auth/domain/usecases/sign_in.dart';
import 'package:cleany_store/features/auth/domain/usecases/sign_out.dart';

// One composition root. Application services live in an explicit app scope.
// Repositories are lazy singletons; presentation controllers are factories.
/// Registers application-scoped services and factory presentation controllers.
Future<void> configureDependencies(GetIt container, AppConfig config) async {
  container.pushNewScope(scopeName: 'app');
  try {
    container.registerSingleton<AppConfig>(config);
    container.registerLazySingleton<SessionStore>(
      () => SessionStore(),
      dispose: (s) => s.dispose(),
    );
    container.registerLazySingleton<StorePreferences>(
      () => StorePreferences(),
      dispose: (s) => s.dispose(),
    );
    container.registerLazySingleton<Dio>(
      () => createDio(
        config.apiBaseUrl,
        tokenProvider: () async => container<SessionStore>().value?.accessToken,
      ),
      dispose: (dio) => dio.close(force: true),
    );
    registerFeatureDependencies(container);
  } catch (_) {
    await container.popScope();
    rethrow;
  }
}

/// Registers application-scoped services and factory presentation controllers.
void registerFeatureDependencies(GetIt container) {
  container.registerLazySingleton<CartsApi>(() => CartsApi(container<Dio>()));
  container.registerLazySingleton<CartsRemoteDataSource>(
    () => CartsRemoteDataSource(container<CartsApi>()),
  );
  container.registerLazySingleton<CartsRepository>(
    () => CartsRepositoryImpl(container<CartsRemoteDataSource>()),
  );
  container.registerLazySingleton<GetCarts>(
    () =>
        GetCarts(container<CartsRepository>(), container<ProductsRepository>()),
  );

  container.registerLazySingleton<CreateCart>(
    () => CreateCart(
      container<CartsRepository>(),
      container<ProductsRepository>(),
    ),
  );
  container.registerLazySingleton<DeleteCart>(
    () => DeleteCart(container<CartsRepository>()),
  );
  container.registerFactory<CartsBloc>(
    () => CartsBloc(
      container<GetCarts>(),
      createCartUseCase: container<CreateCart>(),
      deleteCartUseCase: container<DeleteCart>(),
    ),
  );

  container.registerLazySingleton<UsersApi>(() => UsersApi(container<Dio>()));
  container.registerLazySingleton<UsersRemoteDataSource>(
    () => UsersRemoteDataSource(container<UsersApi>()),
  );
  container.registerLazySingleton<UsersRepository>(
    () => UsersRepositoryImpl(container<UsersRemoteDataSource>()),
  );
  container.registerLazySingleton<GetUsers>(
    () => GetUsers(container<UsersRepository>()),
  );

  container.registerLazySingleton<GetUserProfile>(
    () => GetUserProfile(container<UsersRepository>()),
  );
  container.registerFactory<UsersCubit>(
    () => UsersCubit(
      container<GetUsers>(),
      getUserProfileUseCase: container<GetUserProfile>(),
    ),
  );

  container.registerLazySingleton<AuthApi>(() => AuthApi(container<Dio>()));
  container.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(container<AuthApi>()),
  );
  container.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      container<AuthRemoteDataSource>(),
      container<SessionStore>(),
    ),
  );
  container.registerLazySingleton<GetAuth>(
    () => GetAuth(container<AuthRepository>()),
  );

  container.registerLazySingleton<SignIn>(
    () => SignIn(container<AuthRepository>()),
  );
  container.registerLazySingleton<SignOut>(
    () => SignOut(container<AuthRepository>()),
  );
  container.registerFactory<AuthCubit>(
    () => AuthCubit(
      container<GetAuth>(),
      signInUseCase: container<SignIn>(),
      signOutUseCase: container<SignOut>(),
    ),
  );

  container.registerLazySingleton<ProductsApi>(
    () => ProductsApi(container<Dio>()),
  );
  container.registerLazySingleton<ProductsRemoteDataSource>(
    () => ProductsRemoteDataSource(container<ProductsApi>()),
  );
  container.registerLazySingleton<ProductsRepository>(
    () => ProductsRepositoryImpl(container<ProductsRemoteDataSource>()),
  );
  container.registerLazySingleton<GetProducts>(
    () => GetProducts(container<ProductsRepository>()),
  );

  container.registerLazySingleton<GetFeaturedProduct>(
    () => GetFeaturedProduct(container<ProductsRepository>()),
  );
  container.registerFactory<ProductsCubit>(
    () => ProductsCubit(
      container<GetProducts>(),
      getFeaturedProductUseCase: container<GetFeaturedProduct>(),
    ),
  );

  container.registerFactory<QuantityStepperCubit>(() => QuantityStepperCubit());
}

/// Registers application-scoped services and factory presentation controllers.
Future<void> disposeDependencies(GetIt container) => container.popScope();
