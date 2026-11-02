# Cleany Store

A working Flutter application originally scaffolded with **local Cleany 2.0.2**, now validated using **local Cleany 2.0.3** and connected to [Fake Store API](https://fakestoreapi.com/). The app uses real HTTPS requests, not a production fixture adapter.

## Run

From this repository:

```sh
cd flutter_example
flutter pub get
flutter gen-l10n
dart run build_runner build
flutter run --flavor dev -d 189091C8-6638-4DAD-94BA-0C39D8BB606C -t lib/main_dev.dart
```

`flutter run --flavor dev` also starts development through `lib/main.dart`. The `main_uat.dart` and `main_prod.dart` entrypoints select their matching YAML configuration. All three environments currently use `https://fakestoreapi.com` because this is a public demo.

Override the API without editing source:

```sh
flutter run --flavor dev -t lib/main_dev.dart --dart-define=API_BASE_URL=https://fakestoreapi.com
```

Native dev/uat/prod flavors are now configured for Android and iOS through Cleany 2.0.3. Select the matching **native flavor** launch profile in VS Code, or pass `--flavor dev`, `--flavor uat`, or `--flavor prod` with its matching Dart entrypoint. Existing public API configurations and application source were preserved.

## Local Cleany

The app's `pubspec.yaml` contains:

```yaml
dev_dependencies:
  cleany:
    path: ..
```

Open Cleany inside the app:

```sh
dart run cleany
```

The following operations were actually executed through the interactive CLI:

| Menu | Generated items |
| --- | --- |
| 9 · Initialize project | App, Core, centralized DI, router, official localization, environment entrypoints/configuration |
| 1 · Create feature | `products` Cubit, `carts` Bloc, `users` Cubit, `auth` Cubit |
| 2 · Create component | `product_card` and `status_panel` without state; `quantity_stepper` with Cubit |
| 3 · Add use case | `get_featured_product`, `create_cart`, `delete_cart`, `get_user_profile`, `sign_in`, `sign_out` |
| 6 / 7 · List | Verified all four features and three components in Cleany's registry |

For a feature, choose its name, state manager and location, then review and apply. For a use case, select the existing feature, enter its name and choose Entity or void. Cleany generates and wires the operation; its Data hook must then be connected to the actual API.

**Generation and app implementation are distinct.** Cleany generated the initial scaffolds and six additional operation integrations. The real API requires list results, nested rating/name/address DTOs, typed request parameters and authentication. These were implemented in the generated app afterward. Widgets, navigation shell and tests were also tailored to the store. Cleany itself was not changed. Original scaffolds, CLI transcripts and a file comparison are preserved in `../flutter_example_audit/store_demo/`.

## What to try

- **Discover:** load 20 products, search, choose categories, sort by price and open product details. The spotlight calls the additional `GetFeaturedProduct` use case.
- **Quantity:** increase or decrease the Cubit component, then create a demo cart from product details.
- **Carts:** view public carts with product names, photos and totals. Create and delete use separate operation states.
- **Community:** search the public user directory and open a profile using `GetUserProfile`.
- **Account:** select **Use public demo account**, then sign in. Invalid credentials display an error. Sign out clears the in-memory session.
- **العربية:** switch between English and Arabic, including RTL layout, through the app bar.

Fake Store exposes public sample accounts. The demo account button fills the service's published sample credentials. Passwords are not retained in the session or user entities; tokens are never displayed, logged or written to disk. This demo intentionally clears authentication when restarted.

**Fake Store simulates writes:** creating or deleting carts does not permanently change its dataset. A newly created cart is shown locally; a successful delete removes it from the current view. Refreshing can restore the original public dataset. There is no payment, inventory checkout or persistent shopping account.

## Architecture

```text
lib/
  app/                  # Bootstrap, composition root, DI, router, shell, preferences
  core/
    errors/             # Domain-safe Failure and one repository Result boundary
    network/dio/        # Timeouts and trusted-origin token interceptor
    network/retrofit/   # Generated clients returning raw JSON
    localization/       # Official Flutter localization and typed access
    state/              # Per-operation UseCaseState<T>
    storage/            # In-memory session, no password persistence
    theme/
  features/
    products/           # data / domain / presentation (Cubit)
    carts/              # data / domain / presentation (Bloc)
    users/              # data / domain / presentation (Cubit)
    auth/               # data / domain / presentation (Cubit)
  components/
    product_card/product_card_widget.dart
    status_panel/status_panel_widget.dart
    quantity_stepper/
      quantity_stepper_widget.dart
      cubit/
  main_dev.dart
  main_uat.dart
  main_prod.dart
```

Data sources return JSON. Repositories construct Freezed Models and map them into Entities, and return `multiple_result` results. Domain contracts do not depend on Dio, Retrofit or Flutter. Cart use cases join cart and product domain contracts instead of linking their Data layers. Presentation consumes Entities and explicit typed operation states. A shared repository represents each feature's cohesive capabilities.

App DI owns repositories and services for the app scope. `BlocProvider` owns/disposes presentation controllers created by factories. Router delegates page construction to App composition; feature widgets do not resolve GetIt directly.

## Endpoints

| Feature | Actual requests |
| --- | --- |
| Products | `GET /products`, `GET /products/1` |
| Carts | `GET /carts`, `POST /carts`, `DELETE /carts/{id}` |
| Users | `GET /users`, `GET /users/{id}` |
| Auth | `POST /auth/login`, `GET /users` to resolve the public identity; local sign-out |

Delete deliberately has a `void` transport result: the service may return HTTP 200 with JSON `null` for a non-persisted demo cart.

## Tests

```sh
flutter analyze --no-pub
flutter test test
flutter test integration_test/store_flow_test.dart --flavor dev -d <device-id>
```

The 19 deterministic tests use a test-only transport adapter for DTO mapping, error classification, request payloads, business validation, cart enrichment, Cubit/Bloc behavior, token origin protection and the quantity widget. Fixture users have their password fields removed. The integration test exercises the real API through the UI, including cart creation/deletion, invalid and valid login, logout and RTL.

Capture screenshots on iOS while running the same live flow:

```sh
flutter drive --driver=test_driver/store_driver.dart \
  --target=integration_test/store_flow_test.dart \
  --flavor dev -d <device-id> --dart-define=CAPTURE_SCREENSHOTS=true
```

Images are saved under `build/store_screenshots/`. Live tests require internet access and an available Fake Store service; they are kept separate from deterministic tests.

An Arabic execution report and collected evidence are available in `../flutter_example_audit/store_demo/REPORT_AR.md`. iOS simulator testing does not imply Android validation or a signed release build.


## CLEANY 2.0.3 acceptance

The current project was exercised through the local interactive CLI: Doctor, adding a default and alternate Entity use case to the customized products feature, all thirteen field types, Cubit components, rename/move, removal, cache cleanup and native flavor configuration. Temporary acceptance entries were archived outside this app and removed after testing; the four business features and three reusable components remain.

See the [Arabic acceptance report](../flutter_example_audit/acceptance_2_0_3_20261101/REPORT_AR.md) for results, measured timings and remaining release considerations.
