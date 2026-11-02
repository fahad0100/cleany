# CLEANY

**Release 2.0.4** · Interactive architecture tooling for Flutter.

Cleany creates features and reusable components using one consistent **Feature-Based + Clean Architecture** template, with **Cubit or Bloc, Freezed, and multiple_result**. A numbered terminal menu guides each operation, validates the generated project in isolation, and applies changes with recoverable file updates.

[Installation](#installation) · [Quick start](#quick-start) · [Architecture](#generated-architecture) · [Menu guide](#menu-guide) · [AppConfig](#application-configuration) · [Storage](#encrypted-local-storage) · [Safety](#safety-and-recovery) · [Usage guide](doc/USAGE_AR.md)

## New in 2.0.4

- Generate one Freezed State with typed per-operation status fields, and render it consistently in Cubit/Bloc features and self-contained components.
- Include Sizer 3.1.3 responsive Material 3 themes with separate AppColors, AppTextTheme and AppTheme files.
- **11 — App config value** adds per-environment String values, typed AppConfig fields and dart-define overrides without replacing custom configuration code.
- Pages can read the same DI instances through `context.read<AppConfig>()` and `context.read<AppLocalStorage>()` immediately after initialization.
- `AppConfig.isDebug` reports the Flutter build mode independently of the selected dev, uat or prod environment.
- New projects include encrypted Sembast key/value storage, LocalKeys, typed CRUD, password derivation, optional vault keys and explicit service disposal.
- Storage helpers live in `core/storage/storage_extension`; generated `LOCAL_STORAGE.md` explains platform setup and key/password handling.
- The menu is numbered sequentially from **1 to 14**, with **Apply and validate** or **Cancel** for source changes.
- Doctor and archived reset understand registered configuration fields, environment choices and the generated storage profile. New ownership records use template version **2.0.4**.

## What you get

- Full features with Data, Domain, and Presentation layers.
- Lightweight components with optional Cubit/Bloc, without unnecessary data layers.
- Cubit/Bloc selection for every feature; one immutable Freezed State with an independent typed UseCaseState field per operation.
- Central GetIt composition, controller factories, and go_router integration through Dart AST edits.
- Direct Dio or Retrofit over Dio, with a dedicated client and auth interceptor.
- Raw JSON datasources; repository-owned Model → Entity and exception → Failure conversion.
- `Result<Entity, Failure>` from multiple_result; Domain stays independent of Dio, Retrofit, and GetIt.
- Compact response fields: `fieldName:type:jsonKey`, followed by y/n nullability.
- Add use cases to existing features, with typed operation progress, automatic Cubit/Bloc wiring, and central DI.
- Official Flutter Arabic/English localization, ARB files, gen-l10n, and RTL support.
- Dev/UAT/prod bootstrap, typed public AppConfig and guided native Flavorizr setup.
- Automatic UI access to configuration/storage, with application-scoped DI ownership.
- Encrypted local Sembast storage with centralized LocalKeys and native/web adapters.
- Sizer 3.1.3 responsive Material 3 themes, separate color/text/theme files, dark mode and accessibility text scaling.
- Custom locations inside `lib`, nested features, ownership tracking, safe removal, and rename/move.
- Project Doctor, interrupted-operation recovery, local cache cleanup, and archived reset.
- Progress, command deadlines, cancellation, and retryable input/operation errors.

The template is fixed. New projects include local encrypted Sembast storage; no remote database provider or custom template system is required.

## Requirements and platform support

| Requirement | Details |
| --- | --- |
| Dart for Cleany | **3.13.0 or newer within Dart 3.x** |
| Flutter | A stable Flutter SDK available on PATH for package resolution, builders, localization, and analysis |
| CLI host systems | Linux, macOS, Windows |
| Native flavor setup | Android, iOS, macOS folders already present in the project; platform-specific toolchains must be installed |
| Verified local environment | Flutter 3.47.7 / Dart 3.13.5 on macOS |

Cleany runs on the developer's computer. Its pub.dev platform declarations describe the **CLI host**, while the generated application uses Flutter. Cleany is not a mobile or browser runtime dependency. CI covers Linux/macOS/Windows; an available CI configuration does not by itself prove a successful run on every system. Native project configuration tests do not replace signed builds or device testing.

## Installation

After this release is published to pub.dev:

```sh
dart pub global activate cleany 2.0.4
```

For the current checkout, activate the local source instead:

```sh
# Run from the Cleany repository.
dart pub global activate --source path .
```

Add the pub-cache `bin` directory to PATH if `cleany` is not found. Typical locations are `$HOME/.pub-cache/bin` on macOS/Linux and `%LOCALAPPDATA%\Pub\Cache\bin` on Windows. You can also invoke the installed executable with:

```sh
dart pub global run cleany:cleany
```

After updating a local installation, close any running Cleany session and start it again.

## Quick start

1. Create or open a Flutter project and enter its root directory.
2. Run `cleany`.
3. Choose **9 — Initialize project**, select the production identity and API provider, then apply.
4. Choose **1 — Create feature**, enter a name, select Cubit/Bloc, and choose a location.
5. Select default response fields or define your own fields, then apply and validate.
6. Configure the API base URL and run the chosen application entrypoint.

```sh
flutter create playground
cd playground
cleany
```

Cleany presents:

```text
╭────────────────────────────────────────────╮
  CLEANY  ·  Flutter Architecture
╰────────────────────────────────────────────╯

  [ Generation ]
     1. Create feature
     2. Create component
     3. Add use case

  [ Cleanup ]
     4. Remove feature
     5. Remove component

  [ Inspection & Management ]
     6. List features
     7. List components
     8. Rename or move an entry

  [ Core & Setup ]
     9. Initialize project
    10. Configure native flavors
    11. App config value

  [ Maintenance & Recovery ]
    12. Project doctor / repair
    13. Recover interrupted operation
    14. Cleany maintenance / reset

     0. Exit
```

All normal actions use the menu. The direct shortcut `cleany maintenance` opens option 14. Feature/init flags and the old feature/component subcommands are not accepted.

## Generated architecture

```text
my_flutter_app/
├── android/
├── ios/
├── assets/
│   ├── images/
│   ├── icons/
│   └── translations/
│       ├── app_en.arb
│       └── app_ar.arb
├── config/flavors/
│   ├── dev.yaml
│   ├── uat.yaml
│   └── prod.yaml
├── lib/
│   ├── app/
│   │   ├── app.dart
│   │   ├── bootstrap.dart
│   │   ├── config/
│   │   │   ├── app_config.dart
│   │   │   ├── app_environment.dart
│   │   │   └── flavor_config.dart
│   │   ├── composition/feature_pages.dart
│   │   ├── di/injection.dart
│   │   └── router/
│   │       ├── app_router.dart
│   │       └── route_names.dart
│   ├── core/
│   │   ├── errors/
│   │   │   ├── failure.dart
│   │   │   └── error_reporter.dart
│   │   ├── network/
│   │   │   ├── api_endpoints.dart
│   │   │   ├── failure_mapper.dart
│   │   │   ├── dio/
│   │   │   │   ├── dio_client.dart
│   │   │   │   └── interceptors/auth_interceptor.dart
│   │   │   └── retrofit/home_api.dart
│   │   ├── localization/generated/
│   │   ├── state/use_case_state.dart
│   │   ├── storage/
│   │   │   ├── app_local_storage.dart
│   │   │   ├── local_keys.dart
│   │   │   └── storage_extension/
│   │   │       ├── storage_cipher.dart
│   │   │       ├── storage_key_store.dart
│   │   │       ├── storage_exceptions.dart
│   │   │       ├── database_factory.dart
│   │   │       ├── database_factory_io.dart
│   │   │       └── database_factory_web.dart
│   │   ├── theme/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_text_theme.dart
│   │   │   └── app_theme.dart
│   │   ├── constants/
│   │   ├── utils/
│   │   └── widgets/
│   ├── features/home/
│   │   ├── data/
│   │   │   ├── datasources/home_remote_data_source.dart
│   │   │   ├── models/home_model.dart
│   │   │   └── repositories/home_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/home_entity.dart
│   │   │   ├── repositories/home_repository.dart
│   │   │   └── usecases/get_home.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── home_cubit.dart
│   │       │   └── home_state.dart
│   │       ├── pages/home_page.dart
│   │       └── widgets/
│   ├── components/user_card/
│   │   ├── cubit/
│   │   └── user_card_widget.dart
│   ├── main.dart
│   ├── main_dev.dart
│   ├── main_uat.dart
│   └── main_prod.dart
├── test/
├── integration_test/
├── .cleany/features.json
├── .vscode/launch.json
├── CLEANY_RUN.md
├── LOCAL_STORAGE.md
├── flavorizr.yaml
├── l10n.yaml
├── analysis_options.yaml
└── pubspec.yaml
```

This example selects Cubit and Retrofit. Bloc uses a `bloc/` folder with event/state files. Direct Dio omits the Retrofit client. Components place their widget directly in the component directory. Components without state management have only that widget scaffold. Native folders are supplied by Flutter, not recreated by Cleany initialization.

Generated apps pin **Sizer 3.1.3** and wrap `MaterialApp.router` in `Sizer`. Theme getters run inside its builder, so viewport changes recalculate responsive typography, input padding, button height and corner radii. `AppColors` owns the light/dark palettes, `AppTextTheme` owns the text styles, and `AppTheme` composes Material 3 app-bar, button, input and card defaults. Text sizes scale proportionally with a bounded Sizer reference; Flutter's accessibility text scaling remains enabled. Buttons retain a minimum height of 48 logical pixels without forcing infinite width.

`App` follows the system theme by default. Set `App(router: router, themeMode: ThemeMode.dark)` or `ThemeMode.light` to choose explicitly. Evaluate responsive theme getters inside `Sizer.builder`, not in top-level or cached `static final` initializers. Doctor restores missing theme files and the Sizer dependency, preserves existing custom color/theme files, and wraps recognizable legacy MaterialApp roots without replacing their configuration. Reset creates the complete new theme structure. See the [Sizer 3.1.3 documentation](https://pub.dev/packages/sizer/versions/3.1.3) for responsive units in your own widgets.

### Data flow and ownership

```text
API JSON → DataSource → Repository → Model → Entity → UseCase → Cubit/Bloc → UI
                            └── exception → Failure → Result
```

The datasource returns raw JSON and propagates exceptions. The repository decodes a Freezed model, constructs the Entity, and returns one Success/Failure result. Presentation consumes entities rather than transport models. Failures distinguish network, unauthorized, validation, business, server, and unexpected errors; adapt the business mapping to your backend.

AppConfig and AppLocalStorage are application-scoped singletons. Dio and feature repositories are lazy singletons; feature controllers are factories owned by their page BlocProvider. Reusable components create and close their own local controllers. Feature registrations live in the application composition root; the router calls page factories without importing controllers. Root value providers expose the same AppConfig/storage objects to the UI, while DI keeps ownership of disposal. Authored generated Dart files include purpose comments.

## Menu guide

Selecting any command first displays a short explanation of its purpose and workflow. Commands are grouped into Generation, Cleanup, Inspection & Management, Core & Setup, and Maintenance & Recovery.

Examples below show representative inputs; native identifiers, file lists, and diagnostic results depend on your project. Mutating source plans finish with **1 — Apply and validate** or **2 — Cancel**. Enter defaults to Cancel at review.

### 1 — Create feature

```text
Choose a number: 1
Name (snake_case): home
State management: 1  # Cubit; 2 selects Bloc
Location [1]: 1      # Default: lib/features/home
Data contract [1]: 2
Response field count (1 to 30): 3
Response field 1, lowerCamelCase:type:JSON key: userName:string:home
Nullable [1] (y/N): y
Response field 2, lowerCamelCase:type:JSON key: favourite:list<string>:favourite
Nullable [2] (y/N): y
Response field 3, lowerCamelCase:type:JSON key: age:int:age
Nullable [3] (y/N): y
Continue [2]: 1
```

Each field uses `name:type:jsonKey`. Supported types are `string`, `int`, `double`, `bool`, `datetime`, `list`, `list<string>`, `list<int>`, `list<num>`, `list<map<string,dynamic>>`, `map<string,dynamic>`, `set`, and `dynamic`; type names are case insensitive. Nullable accepts y/n, yes/no, or legacy 2/1; Enter means No. Bare `list` and `set` become `List<dynamic>` and `Set<dynamic>`. `dynamic` already accepts null and never generates the invalid type `dynamic?`. Counts are 1–30. Names must be lowerCamelCase; field names and JSON keys must be unique. Invalid input is retried at the current question. Arabic/Persian digits are accepted in numeric choices.

After the last response field, Cleany opens review directly. It does not ask for a method, endpoint, or request data. The API scaffold defaults to GET and a path based on the feature name; adapt its data-layer API to your real backend. Library callers can supply advanced typed `FeatureSpec` request contracts.

Location choices:

| Choice | Example | Result |
| --- | --- | --- |
| 1 — Default directory | name `home` | `lib/features/home` |
| 2 — Custom directory inside lib | parent `lib/modules/account`, name `auth` | `lib/modules/account/auth` |
| 3 — Inside an existing feature | parent `auth`, name `profile` | `<auth path>/subfeatures/profile` |

Names use nonreserved snake_case and must not collide with existing public Dart symbols or registered entries. Paths remain inside `lib`.

Both Cubit and Bloc generate **one Freezed State composed of sealed `UseCaseState<T>` values**:

```dart
@freezed
sealed class HomeState with _$HomeState {
  const factory HomeState({
    @Default(UseCaseState.initial()) UseCaseState<HomeEntity> homeStatus,
  }) = _HomeState;
}
```

The generated file includes its Freezed, shared state, and Entity imports and `part` directive. `core/state/use_case_state.dart` is created during initialization. The primary operation has one field named after the entry, such as `homeStatus` or `userCardStatus`. Cubit and Bloc update this field with `copyWith` through initial/loading/success/failure. A single union value replaces the previous phase and preserves unrelated operation state. Added use cases receive independent typed fields such as `refreshHomeStatus`. The page returns `state.homeStatus.when(initial: ..., loading: ..., success: ..., failure: ...)` inside its BlocBuilder. Components use the same callback rendering inside their local BlocProvider and Builder. Stateful components use the same shape with `UseCaseState<int>` for their sample local value; adapt that type to your component's needs. Doctor records the state style and primary field name, and preserves existing legacy union and three-field contracts during repair, discovery, and use-case additions. Renaming an entry preserves its public primary field so existing consumers remain valid.

### 2 — Create component

```text
Choose a number: 2
Name (snake_case): user_card
State management: 1  # Cubit; 2 = Bloc; 3 = no state management
Location [1]: 2
Parent directory (example: lib/shared/components): lib/shared/components
Continue [2]: 1
```

Creates `lib/shared/components/user_card`. Every new component puts its widget directly in its own folder. Choose the state-management option according to its needs:

```text
# No state management
lib/components/empty_state/
└── empty_state_widget.dart

# Cubit
lib/components/user_card/
├── user_card_widget.dart
└── cubit/
    ├── user_card_cubit.dart
    └── user_card_state.dart

# Bloc
lib/components/status_badge/
├── status_badge_widget.dart
└── bloc/
    ├── status_badge_bloc.dart
    ├── status_badge_event.dart
    └── status_badge_state.dart
```

Cubit/Bloc imports are relative to the component root, for example `import 'cubit/user_card_cubit.dart';`. Components are embedded directly inside feature UI, such as `const UserCardWidget()`. Each stateful widget creates its own controller using `BlocProvider` and `Builder`, reads that local controller with `context.read`, and renders its state with `BlocBuilder`. The provider closes the controller when its widget is removed; separate widget instances have separate state. Components update the registry without adding entries to `FeaturePages`, `registerFeatureDependencies`, or GetIt. Components add no feature routes, Data/Domain layers, or response-field prompts. Generated Freezed outputs appear beside their state/event sources after validation.

Existing components retain their layout and custom widget code. Generation and Doctor remove obsolete generated component factories from `FeaturePages`, including calls that no longer compile after adding required widget inputs. Cleanup appears in the review plan and is validated before application; real feature factories and custom factories with explicit input contracts are preserved. Doctor never recreates component page factories or controller registrations. Existing external controller registrations are preserved for legacy widgets; new components own their controllers locally. Pass required component inputs directly from feature UI.

### 3 — Add use case

```text
Choose a number: 3
Feature: 1                         # Select home from registered features
Use case name (snake_case): refresh_home
Return type: 2                     # 1 = void; 2 = existing Entity
Existing Entity name or source path (Enter = feature Entity) [HomeEntity]:
Continue [2]: 1
```

Cleany adds `domain/usecases/refresh_home.dart` and extends the existing `HomeRepository` and `HomeRepositoryImpl` with `refreshHome()`. Both GetHome and RefreshHome use the same feature repository instance. No per-operation repository files or repository DI registrations are generated. Entity, Model, page, and routes are preserved. An entity result defaults to `HomeEntity`. Press Enter to keep it, or enter an existing Domain Entity class name, such as `ProfileSummaryEntity`, to use that type throughout the contract, repository, use case, controller and action state. A project-relative `lib/.../domain/entities/...dart` source path disambiguates duplicate class names. The feature Model remains in Data. Compatible flat fields map automatically; customized shapes get a typed `_map<Operation>Entity(HomeModel model)` connection hook to implement in the repository. Differing Model/Entity types do not block generation or rewrite schemas. A void result reports successful completion without parsing an Entity. No new Entity or Model is created.

The existing datasource receives a documented connection method. **No endpoint or HTTP method is guessed. Until you implement that connection, the repository returns `UnexpectedFailure`.** Connect the method to your backend, returning raw JSON for an entity operation or completing after a successful void operation. Exceptions are converted to `Failure` once, in the Data repository.

Central DI registers the new use case against the existing feature repository and supplies the existing controller. Custom implementations and test fakes that implement the repository must implement the added method too; staged analysis catches incomplete contracts before application. Older separately generated operation repositories remain supported and are never silently merged or deleted. For Cubit, call `context.read<HomeCubit>().refreshHome()`. For Bloc, dispatch `context.read<HomeBloc>().add(const HomeEvent.refreshHomeRequested())`. Each action exposes independent progress through `state.refreshHomeStatus`:

```dart
return state.refreshHomeStatus.when(
  initial: () => const SizedBox.shrink(),
  loading: () => const CircularProgressIndicator(),
  success: (entity) => Text(entity.toString()),
  failure: (failure) => Text(failure.message),
);
```

Import `core/state/use_case_state.dart` and the feature Entity in that widget. Use `void` instead of `HomeEntity` for completion actions and ignore the success value. Existing feature state variants and page switches remain valid; primary loads preserve action statuses, and duplicate in-flight calls are ignored. Existing manual controller constructors remain compatible through optional named dependencies; provide the new dependency when using its action outside central DI. Doctor, rename/move, removal, and recovery include the added operation records and files. Explicit use case names stay unchanged when their feature is renamed.

### 4 / 5 — Remove feature / component

```text
Choose a number: 4  # 5 selects component removal
Select feature to remove: 1  # Select from the displayed entries
Continue [2]: 1
```

Review every planned removal. Removing a parent removes its registered descendants and the contents of its folder, **including user edits inside that folder**. External files require recorded ownership; matching names alone do not authorize deletion. Cleany updates DI, page factories, routes, owned API outputs, and the registry together. Remaining unrelated references cause staged analysis to fail before application.

### 6 / 7 — List features / components

```text
Choose a number: 6
home  ·  cubit  ·  lib/features/home

Choose a number: 7
user_card  ·  cubit  ·  lib/shared/components/user_card
```

Lists the matching registered entry kind, its state-management style, and location. Missing/corrupt metadata can be inspected through Doctor.

### 8 — Rename or move an entry

```text
Choose a number: 8
Entry: 1
New name [home]: dashboard
Parent directory [lib/features]: lib/modules
Continue [2]: 1
```

Moves the entry to `lib/modules/dashboard`, updating known generated symbols, owned filenames, imports/exports/parts, DI, routes, child metadata, and registry paths. Backend API endpoint strings remain unchanged. References outside supported source roots or dynamic string references need manual review.

### 9 — Initialize project

Choose this first in an uninitialized Flutter project:

```text
Choose a number: 9
Detected production app id: com.example.playground
API provider: 1  # Retrofit over Dio; 2 selects direct Dio
Continue [2]: 1
```

Cleany resolves supported static Gradle properties and Apple project/xcconfig identifiers. If there are multiple candidates, select the production id; if unresolved, enter it. No platform script is executed just to discover the identifier.

| Environment | Application / bundle id |
| --- | --- |
| prod | com.example.playground |
| dev | com.example.playground.dev |
| uat | com.example.playground.uat |

Initialization adds the fixed architecture, required dependencies, localization, and public flavor configuration. Existing dependencies, comments, assets, overrides, custom entrypoints, and analysis rules are preserved where possible. Recognizable Flutter scaffold main functions are connected to dev after archiving their exact original bytes; widget declarations remain available to existing tests. Existing `lib/app` or `lib/core` directories are protected from initialization overwrite. Use Doctor for supported repairs; older unrelated architectures need an explicit migration.

### 10 — Configure native flavors

```text
Choose a number: 10
Platforms: 1  # Select an existing platform, or All available
Continue [2]: 1
```

Stages only selected Android/iOS/macOS folders and runs the configured Flavorizr platform processors in isolation. Native files participate in validation, ownership, and recovery. Your platform SDKs, Ruby/Xcode dependencies, signing, icons, and device QA remain application-specific work.

### 11 — App config value

Choose **11** after initialization. Enter an unused `UPPER_SNAKE_CASE` key and one String value per environment:

```text
Key (UPPER_SNAKE_CASE): SUPPORT_EMAIL
dev value: dev@example.com
uat value: qa@example.com
prod value: help@example.com
Continue [2]: 1
```

Cleany adds `support_email` to each `config/flavors/<environment>.yaml`, a typed `String supportEmail` field to AppConfig, and `String.fromEnvironment('SUPPORT_EMAIL')` handling. Bootstrap passes the selected flavor values into AppConfig. A supplied dart-define wins over YAML, including an explicitly empty String. Without either, custom fields default to an empty String. Existing custom declarations and YAML comments are preserved; invalid, reserved and duplicate names are rejected before asking for values.

```sh
flutter run -t lib/main_dev.dart --dart-define=SUPPORT_EMAIL=local@example.com
```

Initialization provides AppConfig to pages automatically. See [Application configuration](#application-configuration) for `context.read`, constructor injection, build modes and a complete Sentry configuration example.

This operation uses the normal review, validation and rollback. The registry stores field names, not their environment values. Doctor can recover registered field names and restore a missing AppConfig. Archived reset preserves valid registered YAML values. Existing flavor/bootstrap files receive supported value-loading edits when this command is used; unsupported custom structures require manual integration.

### 12 — Project Doctor / repair

```text
Choose a number: 12
REPAIR  ...missing registry, source, dependency, or binding...
NOTICE  ...preserved edit or unsupported custom structure...
Continue [2]: 1
```

Doctor compares folders, the ownership registry, required dependency constraints, DI, page factories, and routes. It proposes specific supported repairs, archives corrupt registry contents, and can infer supported field contracts when rebuilding metadata. Edited files are preserved. Unsupported composition structures require manual resolution rather than guessed edits. All proposed repairs pass the same validation transaction.

### 13 — Recover interrupted operation

```text
Choose a number: 13
Recovery [2]: 1
```

Attempts restoration from the durable journal. Kernel locks are released when their process dies, and dead legacy PID locks are reclaimed automatically. Safe files are restored even if another file conflicts. Conflicting edits and backups are retained for resolution and a later recovery attempt; first save edits you want to keep before resolving them.

### 14 — Maintenance / reset

```sh
cleany maintenance
```

Or choose **14** from the main menu:

| Subchoice | Example | Behavior |
| --- | --- | --- |
| 1 — Clean abandoned local cache | Action `1`, then Apply | Removes marked project-local staging folders; preserves recovery journals/backups and global pub/Flutter caches |
| 2 — Archive and reset | Action `2`, then Apply and validate | Archives managed files under `.cleany/backups/reset_<timestamp>/`, then installs a fresh architecture and empty entry registry |
| 3 — Set command timeout | Action `3`, timeout `600`, then Apply | Stores a 600-second deadline per command in `.cleany/settings.json` |
| 4 — Cancel | Action `4` | Returns to the main menu |

Reset archives app/core, registered folders, and managed configuration, including their edits. Unrelated source/dependencies and native projects remain. Unrelated imports of removed entries can prevent validation; the original project is then preserved. Default command timeout is 300 seconds; accepted values are 5–3600.

### 0 — Exit

Choose `0` to close the session. EOF cancels incomplete entry input. Failed operations offer retry or return to the main menu.

## Application configuration

AppConfig lives in `lib/app/config/app_config.dart`. Bootstrap creates it from the selected flavor and registers one instance in DI. Its root RepositoryProvider makes that same object available to every routed page and nested component.

| Property | Type | Source |
| --- | --- | --- |
| `environment` | `AppEnvironment` | Selected `main_dev`, `main_uat` or `main_prod` entrypoint |
| `apiBaseUrl` | `String` | Nonempty `API_BASE_URL` dart-define, then flavor `api_base_url` |
| `dbSecretKey` | `String` | `DB_SECRET_KEY` dart-define, then flavor `db_secret_key`; scaffold default `pass_key_storage` |
| `isDebug` | `bool` | Flutter `kDebugMode`; read-only and independent of environment |
| Custom fields, e.g. `sentryDsn` | `String` | Matching dart-define, then registered YAML value, then empty String |

In a page or component, import the types and read the configuration inside `build` or an event callback. Replace `playground` with your pubspec package name:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playground/app/config/app_config.dart';

class ConfigSummary extends StatelessWidget {
  const ConfigSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.read<AppConfig>();
    return Text('${config.environment.name}: debug=${config.isDebug}');
  }
}
```

Cubit, Bloc and Data services should receive required configuration/storage through their constructors. Resolve them from the existing `container<AppConfig>()` and `container<AppLocalStorage>()` in `lib/app/di/injection.dart`. Bootstrap uses a dedicated `GetIt.asNewInstance()` container; the global GetIt instance does not contain these registrations. Domain contracts remain independent of BuildContext and application/platform services. AppConfig is immutable; settings that change while the app runs need their own state management.

### Example: add a Sentry DSN

1. Run `cleany` and choose **11 — App config value**.
2. Enter the unused key **SENTRY_DSN**.
3. Enter the dev, uat and prod DSNs from your Sentry project.
4. Review and choose **1 — Apply and validate**.

Cleany adds `sentry_dsn` to the three flavor YAML files and a `String sentryDsn` property to AppConfig. Inside a widget callback or `build`, read it with `context.read<AppConfig>().sentryDsn`. The command adds configuration only; installing and initializing the Sentry SDK remains application code.

Override it for a particular run:

```sh
flutter run -t lib/main_dev.dart \
  --dart-define=API_BASE_URL=https://dev.example.com \
  --dart-define=SENTRY_DSN='YOUR_DEV_SENTRY_DSN'
```

Use the exact uppercase registered key in dart-define; YAML uses snake_case and Dart uses lowerCamelCase. Custom overrides, including an explicitly empty String, take precedence over YAML. An empty DB_SECRET_KEY override is invalid. API_BASE_URL retains its existing behavior: an empty override falls back to the YAML URL. Stop the app and rerun/rebuild when changing defines; hot reload does not change compilation environment values. Public client configuration is extractable from builds; keep privileged backend credentials out of YAML and dart-defines.

### Debug mode across environments

| Flutter build mode | `config.isDebug` in dev, uat and prod |
| --- | --- |
| Debug (default `flutter run`) | `true` |
| Profile (`flutter run --profile`) | `false` |
| Release (`flutter run --release` / release build) | `false` |

Running `main_prod.dart` in Debug still returns true. `isDebug` is derived from Flutter's [kDebugMode](https://api.flutter.dev/flutter/foundation/kDebugMode-constant.html), not a YAML key or custom dart-define. The key IS_DEBUG is reserved and cannot be added as a String setting through App config value.

## Run the generated application

Set a public API URL in `config/flavors/dev.yaml`, or pass it at launch:

```sh
# Add --flavor dev after applying native flavor setup for that platform.
flutter run --target lib/main_dev.dart --dart-define=API_BASE_URL=https://api.example.com
```

Use `main_uat.dart` or `main_prod.dart` for those environments. UAT and production require HTTPS. YAML assets and dart-define values are extractable public configuration; keep privileged credentials on the backend. Dio can fetch session tokens at request time via `TokenProvider` and attaches them only to the trusted origin.

Initialization supplies `.vscode/launch.json` and `CLEANY_RUN.md`. Choose **Cleany DEV**, **Cleany UAT**, or **Cleany PROD** in VS Code; each profile targets the matching `main_<environment>.dart` and prompts for the public API base URL. An empty answer uses the flavor YAML value; UAT/prod require HTTPS. Profiles marked **(native flavor)** additionally select `--flavor` and require menu 10 first. The plain environment profiles work before native flavor setup. Existing JSONC comments, custom profiles, and input definitions are preserved.

A missing or recognizable Flutter scaffold `main.dart` launches dev. Scaffold widget classes remain available to old tests, and the original main file is archived under `.cleany/backups/entrypoints/`. Custom startup code is preserved; use a named environment profile or migrate it explicitly. Doctor repairs missing profiles and supported scaffold entrypoints, and reset preserves custom launch settings. The initial UI is a scaffold: connect routes, forms, business rules, and backend contracts for your application.

## Localization

Edit `assets/translations/app_en.arb` and `app_ar.arb`. The official Flutter SDK `flutter_localizations` and gen-l10n produce source in `lib/core/localization/generated/`. The app follows the device language and supplies Material/Widgets/Cupertino delegates and Arabic RTL layout. No easy_localization dependency is added.

## Encrypted local storage

Initialization generates `AppLocalStorage` and `LocalKeys` under `lib/core/storage`, opens storage before starting the UI, registers one app-scoped instance in GetIt, and closes it when that scope is disposed. Widgets can obtain the same instance through `context.read<AppLocalStorage>()`; inject it into Data services/repositories through their constructors. Keep platform storage out of Domain contracts.

Replace `playground` with your pubspec package name. Use the operations below inside an async action, not as writes during `build`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playground/core/storage/app_local_storage.dart';
import 'package:playground/core/storage/local_keys.dart';

final storage = context.read<AppLocalStorage>();
await storage.put(key: LocalKeys.languageCode, value: 'ar');
final language = await storage.get<String>(key: LocalKeys.languageCode);
final exists = await storage.containsKey(key: LocalKeys.languageCode);
await storage.remove(key: LocalKeys.languageCode);
await storage.clear();
```

Add application-specific constants to LocalKeys. Values support Sembast JSON types, Blob and Timestamp; root null is rejected. `get<T>` returns null for a missing record or a type mismatch. Use its optional decoder for typed collections. Authentication failures throw a distinct storage exception instead of returning missing data. Tests can inject a Sembast database and a StorageKeyStore. For typed collections, supply a decoder:

```dart
final ids = await storage.get<List<int>>(
  key: 'recent_ids', // Add a matching constant to LocalKeys in your app.
  decode: (value) => (value as List).cast<int>(),
);
```

The public API is `put<T>`, `get<T>`, `containsKey`, `remove`, `clear` and idempotent `close`. Application DI closes its owned store; pages should use the provided instance without closing it. Authentication errors use StorageIntegrityException; a missing/invalid auto vault key uses StorageKeyUnavailableException. Import those types from `core/storage/storage_extension/storage_exceptions.dart` when handling them.

Generated dependencies include `sembast: ^3.9.0`, `crypto: ^3.0.6`, and `path_provider: ^2.1.2`. PointyCastle supplies AES-256-GCM, flutter_secure_storage holds keys, and sembast_web supplies browser persistence. Crypto supplies HMAC-SHA256; it is not an encryption library. Each value uses an authenticated envelope with a fresh nonce, bound to its environment and record; logical record names use HMAC. Database metadata remains visible. Sembast IO uses an application-support file; web uses IndexedDB.

`DB_SECRET_KEY` defaults to **pass_key_storage** in AppConfig, flavor YAML and AppLocalStorage. It is a public starter password and must be replaced before release. Passwords derive a 256-bit key using PBKDF2-HMAC-SHA256 (600,000 iterations) with a random 32-byte salt persisted per database. The salt is not secret. Encryption helpers and platform adapters live in `core/storage/storage_extension`; AppLocalStorage and LocalKeys stay at the storage root.

YAML/dart-define overrides are recoverable from client builds. The optional **auto** mode retains random vault-held keys, and existing base64-encoded 32-byte raw keys are supported. Wrong passwords, missing keys, malformed salts and tampered records fail without resetting existing data. Changing passwords/keys/modes needs an explicit data migration. `clear` deletes records and compacts the database; it does not promise physical erasure from backups or storage media.

Read the generated **LOCAL_STORAGE.md** before shipping: configure Android minSdk 23+ and backup exclusions, Apple Keychain Sharing per flavor, Linux native/keyring prerequisites, and HTTPS/localhost for web. Platform configuration remains an application setup step. Encryption at rest does not protect a compromised running app or injected browser scripts. Runtime tests exercise persistence and vault adapters using plugin mocks; real OS-vault/device qualification remains release QA.

## Safety and recovery

1. Build a CREATE/UPDATE/DELETE file plan and offer Apply and validate or Cancel.
2. Acquire a project lock and create a selective staging workspace.
3. Resolve packages, run gen-l10n and builders, and analyze the result.
4. Check original inputs and validated output fingerprints for changes.
5. Reject existing output targets absent from both the original staged inputs and the explicit plan, then apply the collected files with atomic replacement per file and a durable recovery journal.

The multi-file application is recoverable, not one indivisible filesystem operation. External observers can see intermediate states during application. Recovery preserves conflicting user edits and continues restoring safe records, including when another backup is damaged. Independent checksummed journal snapshots tolerate a missing or corrupt primary manifest; unknown transaction data and unreferenced backups are retained for inspection. File-state transitions are appended instead of rewriting the full manifest after each file. Ctrl+C requests controlled cancellation; active commands have deadlines and command-tree termination.

Relevant source/configuration, declared assets/fonts, and selected native folders are copied using filesystem operations and streaming hashes. Build caches, Pods, unselected native folders, and unrelated root binaries are excluded. Abandoned marked staging folders are cleaned automatically. Unexpected output locations and changes during/after analysis fail explicitly rather than silently discarding generated files.

Commit `.cleany/features.json`; it records schema/template versions, contracts, paths, types, file ownership, integration-node ownership, and hashes. Doctor adds missing integrations and preserves existing custom DI, factories, and route paths. Generated ignore entries exclude runtime cache/journal/backup files. Do not remove `.cleany/operation.lock` to bypass a live operation. Progress observers and log failures become warnings after successful application. The library returns an `OperationResult`; `OperationFailure.result` distinguishes completed rollback from required recovery. Progress is shown in the terminal and recorded in `.cleany/logs/operation_<id>.jsonl`.

## Limits and migration

Version 2.0.4 supplies the current template for new initialization, archived reset and supported missing-file repairs. Doctor preserves existing custom files; it does not replace an existing bootstrap just to add root providers, change storage passwords/modes or migrate an older architecture. Add supported wiring manually or review an archived reset when upgrading an existing application. Reset preserves valid environment choices, including an existing DB key choice; changing encryption settings is a separate data-migration task.

- One fixed template; existing 1.x layouts are not silently migrated by init.
- Pub workspaces and symlinked source paths are unsupported.
- AST edits support the fixed composition contracts and several function/list forms; arbitrary conditional DI or renamed composition entrypoints need manual integration.
- Native id discovery is static and conservative; dynamic scripts may require manual input.
- CLI field input supports flat response fields. Additional no-argument operations can be generated through option 3; their backend connections require application code. JSON maps and collections are supported. Named nested DTOs, envelopes, multipart, pagination, request parameters, and custom Entity/Model conversions require application code; Doctor preserves registered custom Models and reports unsupported unregistered contracts without aborting other diagnostics.
- Rename/move preserves unchanged files byte for byte and scopes known symbol edits to moved libraries and their imports, including aliases and conditional URI alternatives. Mixed owned/external conditional symbols and ambiguous references require manual review; runtime strings and dynamic references are not rewritten.
- Memory holds changed file contents and fingerprint metadata. Very large resets/moves still need performance evaluation for the particular repository.

See [CHANGELOG](CHANGELOG.md) for the release summary and [the usage guide](doc/USAGE_AR.md) for a guided walkthrough.

## Library example

`package:cleany/cleany.dart` exposes planning, transaction, recovery, and maintenance APIs. The [runnable example](example/cleany_example.dart) prepares a plan using a disposable project and cleans it up; it does not alter your application:

```sh
dart run example/cleany_example.dart
```

For real applications, leave package installation, builders, and analysis enabled in `GenerationTransaction.apply`.

## Validation cache and native test matrix

Cleany keeps a project-local compiler/builder state cache at `.cleany/cache/validation`. Every operation stages current sources and reruns dependency resolution, builders and analysis; cached source outputs are never applied directly. SDK identity changes, failed validation or interrupted cache preparation invalidate the cache. Menu **14 → Clean abandoned local cache** also clears the owned warm cache without touching recovery backups or global Flutter/pub caches.

Native flavor setup reuses an existing `AppIcon` catalog when no custom icon or icon build setting is configured. Explicit custom icons remain unchanged. This prevents missing `AppIcon-dev` catalogs when asset-generation processors are intentionally excluded.

Run deterministic generator tests with `dart test`. Real generated-contract tests are opt-in:

```sh
CLEANY_FLUTTER_INTEGRATION=true dart test test/generated_app_test.dart test/contract_flutter_test.dart --concurrency=1
CLEANY_NATIVE_INTEGRATION=true CLEANY_NATIVE_PLATFORMS=ios dart test test/native_flavors_test.dart
```

Select `android`, `ios`, or `macos` with `CLEANY_NATIVE_PLATFORMS`. Each native test configures Flavorizr and builds **dev, uat and prod** using the actual platform SDK. Setting `CLEANY_IOS_DEVICE` additionally launches each iOS flavor on that simulator. CI runs separate Android, iOS simulator and macOS jobs. Native tests produce debug artifacts, not signed store releases.

## Development and release checks

```sh
dart pub get
dart format --output=none --set-exit-if-changed lib bin test example
dart analyze --fatal-infos lib bin test example
dart test --concurrency=1
dart run example/cleany_example.dart
dart doc
dart pub outdated
dart pub publish --dry-run
```

The default unit suite skips SDK/native integration fixtures unless explicitly enabled. Actual generated-app tests resolve Flutter dependencies and run builders, analysis, runtime tests, refactoring, repair, removal, reset, and native flavor configuration:

```sh
# macOS: full suite, including Apple native configuration
CLEANY_FLUTTER_INTEGRATION=true dart test test/generated_app_test.dart --concurrency=1

# Generated AppConfig, context.read, encrypted storage and web compilation
CLEANY_FLUTTER_INTEGRATION=true dart test test/config_storage_flutter_test.dart --concurrency=1

# Responsive themes and self-contained components
CLEANY_FLUTTER_INTEGRATION=true dart test test/responsive_theme_flutter_test.dart test/component_flutter_test.dart --concurrency=1
```

On Linux, set `CLEANY_FLUTTER_INTEGRATION=true` and select `--name 'generated dio'` to run the Dio fixture without Apple native configuration. On PowerShell, set `$env:CLEANY_FLUTTER_INTEGRATION = 'true'`, then run `dart test test/generated_app_test.dart --name 'generated dio' --concurrency=1`. The complete native Apple configuration fixture requires macOS. CI uses stable toolchains and the minimum supported Dart SDK. Package review can additionally use [pana](https://pub.dev/packages/pana) on a disposable copy; pub.dev determines the final published score.

## Release verification scope

The [dated 2.0.0 local pana report](doc/PUBDEV_REPORT.md) is historical evidence, not a score for 2.0.4. Use the current release checks above before publishing. The generated Flutter tests verify configuration/context access, typed state, storage persistence and failure handling, and web compilation. Vault adapters use plugin mocks in these tests; they do not certify every OS keychain, browser or release-signing configuration. Native matrix jobs exercise actual toolchains when enabled. A publish dry run validates the package and its file list without uploading; pub.dev determines its own analysis results after publication.

## License and support

BSD 3-Clause; see [LICENSE](LICENSE). Report reproducible problems through [GitHub issues](https://github.com/fahad0100/cleany/issues), including the Cleany/Flutter/Dart versions, selected menu action, and sanitized diagnostics.
