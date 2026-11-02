# CLEANY 2.0.4 Usage Guide

Cleany is an interactive Flutter architecture generator using a fixed Feature-Based + Clean Architecture template with Cubit or Bloc, Freezed, and multiple_result. It runs on Linux, macOS, and Windows and requires Dart 3.13 or newer within Dart 3.x, with Flutter available on PATH.

## Install and start

After the release is published to pub.dev:

```sh
dart pub global activate cleany 2.0.4
```

To use the local checkout, run this from the tool repository:

```sh
dart pub global activate --source path .
```

Enter the root of a Flutter project and start:

```sh
cleany
```

After updating a local installation, close the previous Cleany session and open a new one. The menu groups commands by Generation (1–3), Cleanup (4–5), Inspection & Management (6–8), Core & Setup (9–11), and Maintenance & Recovery (12–14). Every selection displays a short description before its prompts.

## 1 - Create a feature

Initialization includes Sizer 3.1.3 and three theme files in `core/theme`: `app_colors.dart`, `app_text_theme.dart`, and `app_theme.dart`. The generated App wraps MaterialApp.router with Sizer before evaluating its responsive themes. Light/dark palettes follow the system by default; pass an explicit `themeMode` to App to override it. Typography and spacing adapt within readable bounds while preserving Flutter accessibility text scaling. Customize palettes and text styles in their dedicated files. Doctor repairs missing files/dependencies and wraps recognizable older MaterialApp roots while preserving custom configuration; reset generates the full new structure.

Choose 1, enter a name such as `home`, and select Cubit or Bloc. Then select the default location, a custom directory inside lib, or an existing parent feature.

Choosing Define fields and API contract produces this workflow:

```text
Response field count (1 to 30): 3
Response field 1, lowerCamelCase:type:JSON key: userName:string:home
Nullable [1] (y/N): y
Response field 2, lowerCamelCase:type:JSON key: favourite:list<string>:favourite
Nullable [2] (y/N): y
Response field 3, lowerCamelCase:type:JSON key: age:int:age
Nullable [3] (y/N): y
```

After the final field, Cleany opens file review directly. It does not ask for a method, endpoint, or Request data. The generated API uses the default scaffold; adapt it when implementing your backend integration.

The format is `fieldName:type:jsonKey`, with a lowerCamelCase field name. Types are string, int, double, bool, datetime, list, list<string>, list<int>, list<num>, list<map<string,dynamic>>, map<string,dynamic>, set and dynamic, matched case insensitively. Bare collections use explicit dynamic elements; dynamic is inherently nullable. Nullable accepts y/n; Enter means No. Arabic/Persian digits are accepted for numeric selections. Invalid or duplicate fields are retried without losing earlier entries.

Location examples:

- Default location with home: `lib/features/home`.
- Custom parent `lib/modules/account` with auth: `lib/modules/account/auth`.
- Nested profile feature inside auth: `<auth path>/subfeatures/profile`.

A feature includes Data, Domain, and Presentation, with central DI, page factories, and routes. DataSource returns raw JSON; Repository decodes Model, creates Entity, and returns Result with Failure. Presentation consumes entities.

## 2 - Create a component

New Cubit/Bloc features and stateful components use one Freezed State with a single primary field such as `homeStatus`, typed as `UseCaseState<T>`. Feature T is its Entity; component sample T is int. The shared sealed union defines initial/loading/success/failure. Controllers use `copyWith` to update the primary union value, replacing the previous phase while preserving independent use-case progress. Generated UI renders `state.homeStatus.when(initial: ..., loading: ..., success: ..., failure: ...)`. Stateful components retain their local BlocProvider and Builder. Doctor records the primary field and distinguishes the current status-field contract from earlier three-field and union contracts. Missing files restore in their own style. Renaming an entry preserves its public primary field; custom source is retained.

Choose 2, enter `user_card`, and select Cubit, Bloc, or no state management. A custom parent such as `lib/shared/components` produces `lib/shared/components/user_card`.

A component places `<name>_widget.dart` directly in its directory, with optional `cubit/` or `bloc/` files beside it. No extra widgets folder is created. Existing nested widget layouts are retained by Doctor and refactoring. A component contains its widget and optional controller/state files. It does not add unnecessary Data/Domain layers or a route.

Embed the widget directly in feature UI, for example `const UserCardWidget()`. A new stateful component owns its Cubit/Bloc through a local `BlocProvider` and `Builder`; it reads that controller inside the provider and closes it automatically on removal. Instances do not share state. Components are recorded in the registry without adding `FeaturePages` or central DI registrations. Generation and Doctor remove obsolete generated component factories before validation, without filling required widget inputs with placeholder values. Doctor does not recreate component page factories or controller registrations; existing legacy external registrations and custom widget code are preserved. Supply inputs such as `phone` at the component's actual call site inside its feature.

## 3 - Add a use case to an existing feature

1. Choose 3, then select a registered feature. Components are excluded.
2. Enter a snake_case operation name, for example `refresh_home`.
3. Choose 1 for void completion or 2 for the selected feature's existing Entity.
4. For an Entity result, press Enter to retain the feature Entity, or enter an existing Domain Entity class name (or its lib/.../domain/entities/...dart source path).
5. Review the added files and updates, then apply and validate or cancel.
6. Implement the documented connection method in the existing remote datasource. Cleany does not guess a backend endpoint or method; until connected, the operation returns Failure.

The operation gets a Domain use case and adds a method to the existing feature repository contract and its Data implementation. DI reuses the same feature repository; no separate operation repository is created. Update custom repository implementations and test fakes to implement the expanded contract before validation. Older operation-specific contracts remain supported without automatic migration. Entity operations reuse the current feature Model and Entity; void operations do not parse a response Entity. Existing models, entities, pages, and routes are preserved.

For a Cubit feature, invoke `context.read<HomeCubit>().refreshHome()`. For a Bloc feature, dispatch `context.read<HomeBloc>().add(const HomeEvent.refreshHomeRequested())`. Central DI supplies the operation automatically. Manual controller construction remains compatible, but must supply `refreshHomeUseCase` to run the action.

Observe `state.refreshHomeStatus`: `UseCaseInitial<T>`, `UseCaseLoading<T>`, `UseCaseSuccess<T>` with `value`, or `UseCaseFailure<T>` with `failure`. Here T is the feature Entity or void. Import the shared `core/state/use_case_state.dart` file to match these types. Each operation progresses independently, primary loads preserve its state, and repeated calls while it is loading are ignored. Existing sealed feature state variants and page switches remain valid.

Operation files and DI bindings participate in Doctor, rename/move, removal, and recovery. Explicit operation names are retained when the feature is renamed. Customized Model/Entity constructors or differing field types receive a typed Data mapping hook. Generation still succeeds; implement that hook before expecting a successful result. The chosen Entity propagates through all layers without creating or rewriting an Entity or Model.

## 4 and 5 - Remove entries

Choose 4 to remove a feature or 5 to remove a component. Select the entry by number, review the plan, and apply or cancel.

Folder removal includes handwritten edits and nested entries inside it. External files require recorded ownership; matching names alone never authorize deletion. DI, page factories, routes, and registry are updated together. Analysis prevents application when unresolved references remain.

## 6 and 7 - List entries

Choose 6 for features or 7 for components. Each entry shows its name, controller style, and path. These lists use the registry; use Doctor to reconcile registry/folder inconsistencies.

## 8 - Rename or move an entry

Select the entry, enter a new name such as `dashboard`, and choose a parent such as `lib/modules`. The resulting `lib/modules/dashboard` updates known symbols, URI directives, DI, router, registry, and descendants.

Backend endpoint strings are preserved. Runtime string references and references outside supported source roots need manual review.

## 9 - Initialize the project

1. Choose 9 from the menu.
2. Cleany discovers supported static Android/Apple app identifiers. Select the production identifier if there are multiple candidates, or enter one when discovery is unresolved.
3. Choose 1 for Retrofit over Dio, or 2 for direct Dio.
4. Review the files, then choose 1 to apply and validate or 2 to cancel.

For `com.example.playground`, production keeps that identifier, dev uses `com.example.playground.dev`, and UAT uses `com.example.playground.uat`.

Initialization creates app/core, environment configuration, and official English/Arabic localization. It preserves existing pubspec sections, dependencies, and configuration where possible and refuses to overwrite existing app/core directories. It is not an automatic migration for every older architecture.

## 10 - Configure native flavors

Choose an existing Android, iOS, or macOS platform, or all available platforms. After review, Flavorizr processors run in staging, and native changes participate in application and recovery.

Install the required platform tools and Ruby/Xcode dependencies where needed. Application signing, icons, and device QA remain application-specific work.

## 11 - App config value

Choose 11 after initialization. Enter an unused UPPER_SNAKE_CASE key, then its dev, uat and prod String values. Review the files and choose Apply and validate or Cancel. For example SUPPORT_EMAIL becomes `support_email` in each flavor YAML and `config.supportEmail` in AppConfig. A `String.fromEnvironment('SUPPORT_EMAIL')` override takes priority, even when explicitly empty. Whitespace in values is preserved. Invalid/reserved/duplicate keys are rejected before value input.

```sh
flutter run -t lib/main_dev.dart --dart-define=SUPPORT_EMAIL=local@example.com
```

AppConfig.isDebug is a read-only bool derived from Flutter kDebugMode, true only in Debug builds across all environments. It is false in Profile/Release and is not a YAML or custom dart-define setting.

Initialization automatically exposes AppConfig to pages via `context.read<AppConfig>()`, using the same instance owned by application DI. Import flutter_bloc and app/config/app_config.dart. Pass required configuration into Cubits, Blocs and Data services through constructors. Use these fields for public client settings. YAML assets and dart-defines do not protect secrets. The operation preserves custom code, tracks field names without copying values to the registry, and uses the standard validation/rollback. Reset preserves valid registered configuration choices; Doctor can recover missing registered fields when restoring a missing AppConfig file.

## 12 - Inspect and repair the project

Choose 12 to inspect metadata, folders, sources, bindings, routes, and dependencies. Supported automatic fixes appear as REPAIR; preserved edits or unsupported custom structures appear as NOTICE.

Review the proposed plan before applying. Corrupt registry contents are archived before replacement. Doctor does not guess how to rewrite complex conditional integrations or unknown custom code.

## 13 - Recover an interrupted operation

Choose 13, then 1 to attempt recovery. The operating system releases locks when their process dies, and dead legacy PID locks are reclaimed automatically.

Safe files are restored even if another file conflicts. Backups and unresolved records remain for another attempt. Save edits you want to keep before resolving conflicts. Do not delete operation.lock to bypass a live operation.

## 14 - Maintenance and reset

Open maintenance directly with:

```sh
cleany maintenance
```

Then choose:

| Choice | Result |
| --- | --- |
| 1 | Clean abandoned local staging folders while preserving backups, recovery data, and global caches. |
| 2 | Archive app/core, registered entries, and managed configuration, then install a fresh architecture and empty registry after successful validation. |
| 3 | Set a per-command deadline from 5 to 3600 seconds; the default is 300 seconds. |
| 4 | Return to the main menu. |

Reset archives are stored under `.cleany/backups/reset_<timestamp>/`. Unrelated files, dependencies, and native projects remain. References in unrelated code to removed features may prevent analysis from passing; the original project is then preserved.

## Encrypted local storage

New initialization supplies core/storage/AppLocalStorage and LocalKeys, a single instance owned by application DI, and a RepositoryProvider for UI access. Inject storage into Data services; widgets can obtain it with `context.read<AppLocalStorage>()`. Add application keys to LocalKeys. The API offers typed put/get, optional decoding, containsKey, remove, clear and idempotent close. Root null and unsupported Sembast values are rejected. Type mismatches return null; authentication errors throw.

DB_SECRET_KEY defaults to pass_key_storage in AppConfig, all environments and AppLocalStorage. Replace this public scaffold password before release. Password mode uses PBKDF2-HMAC-SHA256 (600,000 iterations) with a random persisted salt per database; AES-256-GCM authenticates values and their record/environment binding. HMAC hides logical record names; metadata and salts are visible. Optional auto mode keeps random keys in the platform vault, and existing 32-byte base64 raw keys remain supported. Bundled passwords/keys are public. Wrong passwords, lost keys and malformed salts never trigger a silent reset; changing passwords or modes needs an explicit migration.

AppLocalStorage and LocalKeys live at the storage root. The six adapter, cipher, exception and key-store files live in storage/storage_extension.

Read the generated LOCAL_STORAGE.md for platform setup: Android minSdk 23+/backup exclusions, iOS/macOS Keychain Sharing, Linux keyring prerequisites, and HTTPS/localhost for web. These native settings are documented rather than automatically rewritten. Tests inject a database/key store or plugin mocks; real platform-vault testing is still required before release. Older initialized projects keep their existing storage profile during Doctor repair; an archived reset installs the new storage architecture.

## 0 - Exit

Choose 0 to end the session. EOF cancels incomplete input. Errors offer retry or return to the main menu.

## Environment launch profiles

Initialization and Doctor supply `.vscode/launch.json` and `CLEANY_RUN.md`. Select Cleany DEV, Cleany UAT, or Cleany PROD in VS Code and enter the public API URL when prompted. Empty input uses the configured flavor YAML URL. UAT/prod require HTTPS. Profiles marked (native flavor) also select the native app identity; run menu 10 before using them. Plain profiles select Dart environments without requiring native flavor setup.

Missing/default Flutter main entrypoints delegate to dev. Recognizable scaffold main functions are archived and rewired while their widget declarations remain valid for existing tests. Custom entrypoints, JSONC comments, and customized existing profiles are preserved. Reset retains custom launch configuration.

## Run the generated application

Set the public API URL in `config/flavors/dev.yaml` or provide it at launch:

```sh
flutter run --target lib/main_dev.dart --dart-define=API_BASE_URL=https://api.example.com
```

After configuring native flavors, add `--flavor dev` for the selected platform. Use main_uat or main_prod for other environments; UAT and production require HTTPS. Assets and dart-define values are public configuration, so keep privileged credentials on the backend.

Edit ARB files under assets/translations to customize localization. The app follows the device language and enables RTL for Arabic. The initial UI is a scaffold; complete your forms, business rules, and backend integration before release.

## Limits and verification

Application is recoverable with atomic replacement per file, rather than a single atomic filesystem operation for the whole project. Pub workspaces, symlinked source paths, and complex conditional DI structures are unsupported. Flat response fields are supported; nested DTOs, pagination, multipart, and broader API contracts need application code.

See [README](../README.md) for architecture and examples, [CHANGELOG](../CHANGELOG.md) for release notes, and the [runnable example](../example/cleany_example.dart) for safe use of the library API.


The project-local validation cache retains compiler/builder state without reusing project source roots. Current inputs are staged and validated on every operation. Maintenance cache cleanup clears this warm cache; SDK changes or failed validation reset it automatically. Doctor uses registered contracts for known entries, preserves customized Models, and reports unsupported unregistered data shapes without aborting its other checks.
