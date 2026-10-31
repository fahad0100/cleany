# CLEANY

**Release 2.0.2** · Interactive architecture tooling for Flutter.

Cleany creates features and reusable components using one consistent **Feature-Based + Clean Architecture** template, with **Cubit or Bloc, Freezed, and multiple_result**. A numbered terminal menu guides each operation, validates the generated project in isolation, and applies changes with recoverable file updates.

[Installation](#installation) · [Quick start](#quick-start) · [Architecture](#generated-architecture) · [Menu guide](#menu-guide) · [Safety](#safety-and-recovery) · [Usage guide](doc/USAGE_AR.md)

## What you get

- Full features with Data, Domain, and Presentation layers.
- Lightweight components with optional Cubit/Bloc, without unnecessary data layers.
- Cubit/Bloc selection for every feature; immutable Freezed states.
- Central GetIt composition, controller factories, and go_router integration through Dart AST edits.
- Direct Dio or Retrofit over Dio, with a dedicated client and auth interceptor.
- Raw JSON datasources; repository-owned Model → Entity and exception → Failure conversion.
- `Result<Entity, Failure>` from multiple_result; Domain stays independent of Dio, Retrofit, and GetIt.
- Compact response fields: `fieldName:type:jsonKey`, followed by y/n nullability.
- Add use cases to existing features, with typed operation progress, automatic Cubit/Bloc wiring, and central DI.
- Official Flutter Arabic/English localization, ARB files, gen-l10n, and RTL support.
- Dev/UAT/prod bootstrap and guided native Flavorizr setup.
- Custom locations inside `lib`, nested features, ownership tracking, safe removal, and rename/move.
- Project Doctor, interrupted-operation recovery, local cache cleanup, and archived reset.
- Progress, command deadlines, cancellation, and retryable input/operation errors.

The template is fixed. Cleany does not require a database SDK or a custom template system.

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
dart pub global activate cleany 2.0.2
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

  [ Maintenance & Recovery ]
    11. Project doctor / repair
    12. Recover interrupted operation
    13. Cleany maintenance / reset

     0. Exit
```

All normal actions use the menu. The direct shortcut `cleany maintenance` opens option 13. Feature/init flags and the old feature/component subcommands are not accepted.

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
│   │   ├── storage/
│   │   ├── theme/
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
│   ├── main_dev.dart
│   ├── main_uat.dart
│   └── main_prod.dart
├── test/
├── integration_test/
├── .cleany/features.json
├── flavorizr.yaml
├── l10n.yaml
├── analysis_options.yaml
└── pubspec.yaml
```

This example selects Cubit and Retrofit. Bloc uses a `bloc/` folder with event/state files. Direct Dio omits the Retrofit client. Components place their widget directly in the component directory. Components without state management have only that widget scaffold. Native folders are supplied by Flutter, not recreated by Cleany initialization.

### Data flow and ownership

```text
API JSON → DataSource → Repository → Model → Entity → UseCase → Cubit/Bloc → UI
                            └── exception → Failure → Result
```

The datasource returns raw JSON and propagates exceptions. The repository decodes a Freezed model, constructs the Entity, and returns one Success/Failure result. Presentation consumes entities rather than transport models. Failures distinguish network, unauthorized, validation, business, server, and unexpected errors; adapt the business mapping to your backend.

Application services/repositories use lazy singletons inside an application GetIt scope. Controllers are factories owned by BlocProvider. All registrations live in the application composition root; the router calls page factories without importing controllers. Authored generated Dart files include purpose comments.

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

Each field uses `name:type:jsonKey`. Supported types are `string`, `int`, `double`, `bool`, `datetime`, `list<string>`, and `list<int>`; type names are case insensitive. Nullable accepts y/n, yes/no, or legacy 2/1; Enter means No. Counts are 1–30. Names must be lowerCamelCase; field names and JSON keys must be unique. Invalid input is retried at the current question. Arabic/Persian digits are accepted in numeric choices.

After the last response field, Cleany opens review directly. It does not ask for a method, endpoint, or request data. The API scaffold defaults to GET and a path based on the feature name; adapt its data-layer API to your real backend. Library callers can supply advanced typed `FeatureSpec` request contracts.

Location choices:

| Choice | Example | Result |
| --- | --- | --- |
| 1 — Default directory | name `home` | `lib/features/home` |
| 2 — Custom directory inside lib | parent `lib/modules/account`, name `auth` | `lib/modules/account/auth` |
| 3 — Inside an existing feature | parent `auth`, name `profile` | `<auth path>/subfeatures/profile` |

Names use nonreserved snake_case and must not collide with existing public Dart symbols or registered entries. Paths remain inside `lib`.

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

Cubit/Bloc imports are relative to the component root, for example `import 'cubit/user_card_cubit.dart';`. Every component updates the central page factory and registry; stateful components also update central DI. Components add no feature routes, Data/Domain layers, or response-field prompts. Generated Freezed outputs appear beside their state/event sources after validation.

Existing components with a `widgets/` subfolder retain their layout during Doctor repair, registry recovery, rename/move, and removal. Cleany records the layout per component instead of creating a second widget in another location.

### 3 — Add use case

```text
Choose a number: 3
Feature: 1                         # Select home from registered features
Use case name (snake_case): refresh_home
Return type: 2                     # 1 = void; 2 = existing HomeEntity
Continue [2]: 1
```

Cleany adds `domain/usecases/refresh_home.dart` and extends the existing `HomeRepository` and `HomeRepositoryImpl` with `refreshHome()`. Both GetHome and RefreshHome use the same feature repository instance. No per-operation repository files or repository DI registrations are generated. Entity, Model, page, and routes are preserved. An entity result reuses `HomeModel.fromJson` and maps its fields into `HomeEntity`; a void result reports successful completion without parsing an Entity. No new Entity or Model is created.

The existing datasource receives a documented connection method. **No endpoint or HTTP method is guessed. Until you implement that connection, the repository returns `UnexpectedFailure`.** Connect the method to your backend, returning raw JSON for an entity operation or completing after a successful void operation. Exceptions are converted to `Failure` once, in the Data repository.

Central DI registers the new use case against the existing feature repository and supplies the existing controller. Custom implementations and test fakes that implement the repository must implement the added method too; staged analysis catches incomplete contracts before application. Older separately generated operation repositories remain supported and are never silently merged or deleted. For Cubit, call `context.read<HomeCubit>().refreshHome()`. For Bloc, dispatch `context.read<HomeBloc>().add(const HomeEvent.refreshHomeRequested())`. Each action exposes independent progress through `state.refreshHomeStatus`:

```dart
switch (state.refreshHomeStatus) {
  case UseCaseInitial<HomeEntity>():
    return const SizedBox.shrink();
  case UseCaseLoading<HomeEntity>():
    return const CircularProgressIndicator();
  case UseCaseSuccess<HomeEntity>(:final value):
    return Text(value.id);
  case UseCaseFailure<HomeEntity>(:final failure):
    return Text(failure.message);
}
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

### 11 — Project Doctor / repair

```text
Choose a number: 11
REPAIR  ...missing registry, source, dependency, or binding...
NOTICE  ...preserved edit or unsupported custom structure...
Continue [2]: 1
```

Doctor compares folders, the ownership registry, required dependency constraints, DI, page factories, and routes. It proposes specific supported repairs, archives corrupt registry contents, and can infer supported field contracts when rebuilding metadata. Edited files are preserved. Unsupported composition structures require manual resolution rather than guessed edits. All proposed repairs pass the same validation transaction.

### 12 — Recover interrupted operation

```text
Choose a number: 12
Recovery [2]: 1
```

Attempts restoration from the durable journal. Kernel locks are released when their process dies, and dead legacy PID locks are reclaimed automatically. Safe files are restored even if another file conflicts. Conflicting edits and backups are retained for resolution and a later recovery attempt; first save edits you want to keep before resolving them.

### 13 — Maintenance / reset

```sh
cleany maintenance
```

Or choose **13** from the main menu:

| Subchoice | Example | Behavior |
| --- | --- | --- |
| 1 — Clean abandoned local cache | Action `1`, then Apply | Removes marked project-local staging folders; preserves recovery journals/backups and global pub/Flutter caches |
| 2 — Archive and reset | Action `2`, then Apply and validate | Archives managed files under `.cleany/backups/reset_<timestamp>/`, then installs a fresh architecture and empty entry registry |
| 3 — Set command timeout | Action `3`, timeout `600`, then Apply | Stores a 600-second deadline per command in `.cleany/settings.json` |
| 4 — Cancel | Action `4` | Returns to the main menu |

Reset archives app/core, registered folders, and managed configuration, including their edits. Unrelated source/dependencies and native projects remain. Unrelated imports of removed entries can prevent validation; the original project is then preserved. Default command timeout is 300 seconds; accepted values are 5–3600.

### 0 — Exit

Choose `0` to close the session. EOF cancels incomplete entry input. Failed operations offer retry or return to the main menu.

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

## Safety and recovery

1. Build a plan and show source changes for review.
2. Acquire a project lock and create a selective staging workspace.
3. Resolve packages, run gen-l10n and builders, and analyze the result.
4. Check original inputs and validated output fingerprints for changes.
5. Reject existing output targets absent from both the original staged inputs and the explicit plan, then apply the collected files with atomic replacement per file and a durable recovery journal.

The multi-file application is recoverable, not one indivisible filesystem operation. External observers can see intermediate states during application. Recovery preserves conflicting user edits and continues restoring safe records, including when another backup is damaged. Independent checksummed journal snapshots tolerate a missing or corrupt primary manifest; unknown transaction data and unreferenced backups are retained for inspection. File-state transitions are appended instead of rewriting the full manifest after each file. Ctrl+C requests controlled cancellation; active commands have deadlines and command-tree termination.

Relevant source/configuration, declared assets/fonts, and selected native folders are copied using filesystem operations and streaming hashes. Build caches, Pods, unselected native folders, and unrelated root binaries are excluded. Abandoned marked staging folders are cleaned automatically. Unexpected output locations and changes during/after analysis fail explicitly rather than silently discarding generated files.

Commit `.cleany/features.json`; it records schema/template versions, contracts, paths, types, file ownership, integration-node ownership, and hashes. Doctor adds missing integrations and preserves existing custom DI, factories, and route paths. Generated ignore entries exclude runtime cache/journal/backup files. Do not remove `.cleany/operation.lock` to bypass a live operation. Progress observers and log failures become warnings after successful application. The library returns an `OperationResult`; `OperationFailure.result` distinguishes completed rollback from required recovery. Progress is shown in the terminal and recorded in `.cleany/logs/operation_<id>.jsonl`.

## Limits and migration

- One fixed template; existing 1.x layouts are not silently migrated by init.
- Pub workspaces and symlinked source paths are unsupported.
- AST edits support the fixed composition contracts and several function/list forms; arbitrary conditional DI or renamed composition entrypoints need manual integration.
- Native id discovery is static and conservative; dynamic scripts may require manual input.
- CLI field input supports flat response fields. Additional no-argument operations can be generated through option 3; their backend connections require application code. Nested DTOs, envelopes, multipart, pagination, request parameters, and custom Entity/Model conversions also require application code.
- Rename/move preserves unchanged files byte for byte and scopes known symbol edits to moved libraries and their imports, including aliases and conditional URI alternatives. Mixed owned/external conditional symbols and ambiguous references require manual review; runtime strings and dynamic references are not rewritten.
- Memory holds changed file contents and fingerprint metadata. Very large resets/moves still need performance evaluation for the particular repository.

See [CHANGELOG](CHANGELOG.md) for the release summary and [the usage guide](doc/USAGE_AR.md) for a guided walkthrough.

## Library example

`package:cleany/cleany.dart` exposes planning, transaction, recovery, and maintenance APIs. The [runnable example](example/cleany_example.dart) prepares a plan using a disposable project and cleans it up; it does not alter your application:

```sh
dart run example/cleany_example.dart
```

For real applications, leave package installation, builders, and analysis enabled in `GenerationTransaction.apply`.

## Development and release checks

```sh
dart pub get
dart format --output=none --set-exit-if-changed lib bin test example
dart analyze --fatal-infos
dart test test/generator_test.dart test/advanced_test.dart test/safety_regression_test.dart test/use_case_test.dart test/run_configuration_test.dart test/cli_menu_test.dart test/component_layout_test.dart
dart run example/cleany_example.dart
dart doc
dart pub outdated
dart pub publish --dry-run
```

Actual generated-app tests resolve Flutter dependencies and run builders, analysis, runtime tests, refactoring, repair, removal, reset, and native flavor configuration:

```sh
# macOS: full suite, including Apple native configuration
CLEANY_FLUTTER_INTEGRATION=true dart test test/generated_app_test.dart --concurrency=1
```

On Linux, set `CLEANY_FLUTTER_INTEGRATION=true` and select `--name 'generated dio'` to run the Dio fixture without Apple native configuration. On PowerShell, set `$env:CLEANY_FLUTTER_INTEGRATION = 'true'`, then run `dart test test/generated_app_test.dart --name 'generated dio' --concurrency=1`. The complete native Apple configuration fixture requires macOS. CI uses stable toolchains and the minimum supported Dart SDK. Package review can additionally use [pana](https://pub.dev/packages/pana) on a disposable copy; pub.dev determines the final published score.

## Local release audit

The previous 2.0.0 local pana audit achieved **160/160**, with **100% public API documentation**, clean analysis, and current dependency support. See the [dated report and verification details](doc/PUBDEV_REPORT.md). pub.dev determines the final published score after upload.

## License and support

BSD 3-Clause; see [LICENSE](LICENSE). Report reproducible problems through [GitHub issues](https://github.com/fahad0100/cleany/issues), including the Cleany/Flutter/Dart versions, selected menu action, and sanitized diagnostics.
