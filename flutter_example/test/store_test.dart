import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:cleany_store/core/errors/failure.dart';
import 'package:cleany_store/core/errors/repository_guard.dart';
import 'package:cleany_store/core/network/dio/dio_client.dart';
import 'package:cleany_store/core/network/retrofit/products_api.dart';
import 'package:cleany_store/core/network/retrofit/carts_api.dart';
import 'package:cleany_store/core/network/retrofit/users_api.dart';
import 'package:cleany_store/core/network/retrofit/auth_api.dart';
import 'package:cleany_store/core/storage/session_store.dart';
import 'package:cleany_store/core/state/use_case_state.dart';
import 'package:cleany_store/features/products/data/datasources/products_remote_data_source.dart';
import 'package:cleany_store/features/products/data/repositories/products_repository_impl.dart';
import 'package:cleany_store/features/products/domain/entities/products_entity.dart';
import 'package:cleany_store/features/products/domain/usecases/get_products.dart';
import 'package:cleany_store/features/products/domain/usecases/get_featured_product.dart';
import 'package:cleany_store/features/products/presentation/cubit/products_cubit.dart';
import 'package:cleany_store/features/products/presentation/cubit/products_state.dart';
import 'package:cleany_store/features/carts/data/datasources/carts_remote_data_source.dart';
import 'package:cleany_store/features/carts/data/repositories/carts_repository_impl.dart';
import 'package:cleany_store/features/carts/domain/entities/cart_draft.dart';
import 'package:cleany_store/features/carts/domain/usecases/get_carts.dart';
import 'package:cleany_store/features/carts/domain/usecases/create_cart.dart';
import 'package:cleany_store/features/carts/domain/usecases/delete_cart.dart';
import 'package:cleany_store/features/carts/presentation/bloc/carts_bloc.dart';
import 'package:cleany_store/features/carts/presentation/bloc/carts_event.dart';
import 'package:cleany_store/features/carts/presentation/bloc/carts_state.dart';
import 'package:cleany_store/features/users/data/datasources/users_remote_data_source.dart';
import 'package:cleany_store/features/users/data/repositories/users_repository_impl.dart';
import 'package:cleany_store/features/users/domain/usecases/get_user_profile.dart';
import 'package:cleany_store/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:cleany_store/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:cleany_store/features/auth/domain/usecases/sign_in.dart';
import 'package:cleany_store/features/auth/domain/usecases/sign_out.dart';
import 'package:cleany_store/components/quantity_stepper/cubit/quantity_stepper_cubit.dart';
import 'package:cleany_store/components/quantity_stepper/quantity_stepper_widget.dart';

/// Deterministic transport fixture. Production always uses the real HTTPS API.
class FixtureAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  int status = 200;
  bool offline = false;
  bool malformed = false;
  Object fixture(String name) =>
      jsonDecode(File('test/fixtures/$name.json').readAsStringSync());
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (offline) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'offline',
      );
    }
    final Object? data;
    if (status != 200) {
      data = {'error': 'demo failure'};
    } else if (malformed) {
      data = [
        {'unexpected': true},
      ];
    } else if (options.path == '/auth/login') {
      data = {'token': 'test-only-token'};
    } else if (options.method == 'POST' && options.path == '/carts') {
      data = {...(options.data as Map<String, dynamic>), 'id': 11};
    } else if (options.method == 'DELETE') {
      data = null;
    } else if (options.path == '/products/1') {
      data = (fixture('products') as List).first;
    } else if (options.path.startsWith('/users/')) {
      data = (fixture('users') as List).firstWhere(
        (u) => u['id'] == int.parse(options.path.split('/').last),
      );
    } else {
      data = fixture(options.uri.path.substring(1));
    }
    return ResponseBody.fromString(
      jsonEncode(data),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Dio dio;
  late FixtureAdapter adapter;
  late ProductsRepositoryImpl products;
  late CartsRepositoryImpl carts;
  late UsersRepositoryImpl users;
  late AuthRepositoryImpl auth;
  late SessionStore session;
  setUp(() {
    adapter = FixtureAdapter();
    session = SessionStore();
    dio = createDio(
      'https://fakestoreapi.com',
      tokenProvider: () async => session.value?.accessToken,
    )..httpClientAdapter = adapter;
    products = ProductsRepositoryImpl(
      ProductsRemoteDataSource(ProductsApi(dio)),
    );
    carts = CartsRepositoryImpl(CartsRemoteDataSource(CartsApi(dio)));
    users = UsersRepositoryImpl(UsersRemoteDataSource(UsersApi(dio)));
    auth = AuthRepositoryImpl(AuthRemoteDataSource(AuthApi(dio)), session);
  });
  tearDown(() {
    dio.close(force: true);
    session.dispose();
  });
  test('products: array and nested rating become domain entities', () async {
    final result = await products.fetch();
    final list = result.tryGetSuccess()!;
    expect(list, hasLength(20));
    expect(list.first.rating, 3.9);
    expect(list.first.reviewCount, 120);
    expect(list.first.id, 1);
    expect((await GetFeaturedProduct(products)()).tryGetSuccess(), list.first);
  });
  test(
    'carts: domain joins product details without coupling data layers',
    () async {
      final result = await GetCarts(carts, products)();
      final line = result.tryGetSuccess()!.first.products.first;
      expect(line.title, isNotEmpty);
      expect(line.unitPrice, 109.95);
      expect(line.quantity, 4);
    },
  );
  test(
    'create cart sends typed IDs and quantities and enriches the response',
    () async {
      final cart = (await CreateCart(carts, products)(
        const CartDraft(productId: 1, quantity: 2, userId: 2),
      )).tryGetSuccess()!;
      expect(cart.id, 11);
      expect(cart.userId, 2);
      expect(cart.products.single.quantity, 2);
      expect(cart.products.single.title, isNotEmpty);
      final request = adapter.requests.last;
      expect(request.method, 'POST');
      expect((request.data as Map)['products'], [
        {'productId': 1, 'quantity': 2},
      ]);
    },
  );
  test('invalid cart quantities fail before network activity', () async {
    for (final qty in [0, 100]) {
      expect(
        (await CreateCart(carts, products)(
          CartDraft(productId: 1, quantity: qty),
        )).tryGetError(),
        isA<ValidationFailure>(),
      );
    }
    expect(adapter.requests, isEmpty);
  });
  test('delete cart uses DELETE with the selected ID', () async {
    expect((await DeleteCart(carts)(3)).isSuccess(), isTrue);
    expect(adapter.requests.single.method, 'DELETE');
    expect(adapter.requests.single.path, '/carts/3');
  });
  test('users: nested profile maps into a password-free entity', () async {
    final list = (await users.fetch()).tryGetSuccess()!;
    expect(list, hasLength(10));
    expect(list.first.firstName, 'john');
    expect(list.first.city, 'kilcoole');
    final user = (await GetUserProfile(users)(2)).tryGetSuccess()!;
    expect(user.username, 'mor_2314');
    expect(user.toString(), isNot(contains('password')));
  });
  test('profile validation avoids invalid network calls', () async {
    expect(
      (await GetUserProfile(users)(0)).tryGetError(),
      isA<ValidationFailure>(),
    );
    expect(adapter.requests, isEmpty);
  });
  test(
    'sign in resolves identity, redacts token, and sign out clears memory',
    () async {
      final result = await SignIn(auth)(
        username: ' mor_2314 ',
        password: 'public-test',
      );
      final entity = result.tryGetSuccess()!;
      expect(entity.userId, 2);
      expect((await auth.fetch()).tryGetSuccess()?.userId, 2);
      expect(session.value?.username, 'mor_2314');
      expect(entity.toString(), isNot(contains('test-only-token')));
      expect(session.value.toString(), isNot(contains('test-only-token')));
      expect((await SignOut(auth)()).isSuccess(), isTrue);
      expect(session.value, isNull);
      expect((await auth.fetch()).tryGetError(), isA<UnauthorizedFailure>());
    },
  );
  test('failed login never creates a session', () async {
    adapter.status = 401;
    expect(
      (await SignIn(auth)(
        username: 'someone',
        password: 'wrong',
      )).tryGetError(),
      isA<UnauthorizedFailure>(),
    );
    expect(session.value, isNull);
  });
  test('blank credentials fail before transport', () async {
    expect(
      (await SignIn(auth)(username: ' ', password: '')).tryGetError(),
      isA<ValidationFailure>(),
    );
    expect(adapter.requests, isEmpty);
  });
  test('offline transport maps once to NetworkFailure', () async {
    adapter.offline = true;
    expect((await products.fetch()).tryGetError(), isA<NetworkFailure>());
  });
  test('malformed JSON maps to ValidationFailure', () async {
    adapter.malformed = true;
    expect((await products.fetch()).tryGetError(), isA<ValidationFailure>());
  });
  test(
    'unexpected reporter errors cannot escape the Result boundary',
    () async {
      var reports = 0;
      final result = await repositoryGuard<int>(
        () async => throw StateError('fault'),
        (e, s) {
          reports++;
          throw StateError('reporter failed');
        },
      );
      expect(result.tryGetError(), isA<UnexpectedFailure>());
      expect(reports, 1);
    },
  );
  test('session token is attached only to the trusted API origin', () async {
    session.signIn(
      const SessionData(
        accessToken: 'test-only-token',
        username: 'demo',
        userId: 1,
      ),
    );
    await dio.get<Object>('/products');
    expect(
      adapter.requests.last.headers['Authorization'],
      'Bearer test-only-token',
    );
    await dio.get<Object>('https://other.example/products');
    expect(adapter.requests.last.headers.containsKey('Authorization'), isFalse);
  });
  test(
    'products cubit loads, filters, sorts and runs its generated use case',
    () async {
      final cubit = ProductsCubit(
        GetProducts(products),
        getFeaturedProductUseCase: GetFeaturedProduct(products),
      );
      addTearDown(cubit.close);
      final states = <ProductsState>[];
      final sub = cubit.stream.listen(states.add);
      addTearDown(sub.cancel);
      await cubit.load();
      await cubit.getFeaturedProduct();
      await Future<void>.delayed(Duration.zero);
      expect(states.first, isA<ProductsLoading>());
      expect(cubit.state, isA<ProductsSuccess>());
      expect(
        cubit.state.getFeaturedProductStatus,
        isA<UseCaseSuccess<ProductsEntity>>(),
      );
      cubit.search('backpack');
      expect(cubit.visibleProducts, hasLength(1));
      cubit.search('');
      cubit.selectCategory('jewelery');
      cubit.toggleSort();
      expect(cubit.visibleProducts, hasLength(4));
      expect(
        cubit.visibleProducts.first.price,
        lessThan(cubit.visibleProducts.last.price),
      );
    },
  );
  test('products cubit presents failures', () async {
    adapter.offline = true;
    final cubit = ProductsCubit(
      GetProducts(products),
      getFeaturedProductUseCase: GetFeaturedProduct(products),
    );
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state, isA<ProductsFailure>());
  });
  test(
    'cart bloc keeps load, create and delete operation states independent',
    () async {
      final bloc = CartsBloc(
        GetCarts(carts, products),
        createCartUseCase: CreateCart(carts, products),
        deleteCartUseCase: DeleteCart(carts),
      );
      addTearDown(bloc.close);
      final loaded = bloc.stream.firstWhere((s) => s is CartsSuccess);
      bloc.add(const CartsEvent.requested());
      await loaded;
      final created = bloc.stream.firstWhere(
        (s) => s.createCartStatus is UseCaseSuccess,
      );
      bloc.add(const CartsEvent.createCartRequested(CartDraft(productId: 1)));
      await created;
      final deleted = bloc.stream.firstWhere((s) => s.deletedIds.contains(1));
      bloc.add(const CartsEvent.deleteCartRequested(1));
      await deleted;
      expect(bloc.state, isA<CartsSuccess>());
      expect(bloc.state.createCartStatus, isA<UseCaseSuccess>());
    },
  );
  test('closed controllers ignore late requests', () async {
    final cubit = ProductsCubit(
      GetProducts(products),
      getFeaturedProductUseCase: GetFeaturedProduct(products),
    );
    await cubit.close();
    await cubit.load();
    await cubit.getFeaturedProduct();
    expect(adapter.requests, isEmpty);
  });
  testWidgets('flat quantity component enforces bounds and reports changes', (
    tester,
  ) async {
    final cubit = QuantityStepperCubit();
    addTearDown(cubit.close);
    int? quantity;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: QuantityStepperWidget(onChanged: (v) => quantity = v),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('quantity-plus')));
    await tester.pump();
    expect(quantity, 2);
    await tester.tap(find.byKey(const Key('quantity-minus')));
    await tester.pump();
    expect(quantity, 1);
    await tester.tap(find.byKey(const Key('quantity-minus')));
    await tester.pump();
    expect(quantity, 1);
    cubit.update(200);
    await tester.pump();
    expect(quantity, 99);
    expect(tester.takeException(), isNull);
  });
}
