# CLEANY 2.0.0 Usage Guide

Cleany is an interactive Flutter architecture generator using a fixed Feature-Based + Clean Architecture template with Cubit or Bloc, Freezed, and multiple_result. It runs on Linux, macOS, and Windows and requires Dart 3.13 or newer within Dart 3.x, with Flutter available on PATH.

## Install and start

After the release is published to pub.dev:

```sh
dart pub global activate cleany 2.0.0
```

To use the local checkout, run this from the tool repository:

```sh
dart pub global activate --source path .
```

Enter the root of a Flutter project and start:

```sh
cleany
```

After updating a local installation, close the previous Cleany session and open a new one.

## 7 - Initialize the project

1. Choose 7 from the menu.
2. Cleany discovers supported static Android/Apple app identifiers. Select the production identifier if there are multiple candidates, or enter one when discovery is unresolved.
3. Choose 1 for Retrofit over Dio, or 2 for direct Dio.
4. Review the files, then choose 1 to apply and validate or 2 to cancel.

For `com.example.playground`, production keeps that identifier, dev uses `com.example.playground.dev`, and UAT uses `com.example.playground.uat`.

Initialization creates app/core, environment configuration, and official English/Arabic localization. It preserves existing pubspec sections, dependencies, and configuration where possible and refuses to overwrite existing app/core directories. It is not an automatic migration for every older architecture.

## 1 - Create a feature

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

The format is `fieldName:type:jsonKey`, with a lowerCamelCase field name. Types are string, int, double, bool, datetime, list<string>, and list<int>, matched case insensitively. Nullable accepts y/n; Enter means No. Arabic/Persian digits are accepted for numeric selections. Invalid or duplicate fields are retried without losing earlier entries.

Location examples:

- Default location with home: `lib/features/home`.
- Custom parent `lib/modules/account` with auth: `lib/modules/account/auth`.
- Nested profile feature inside auth: `<auth path>/subfeatures/profile`.

A feature includes Data, Domain, and Presentation, with central DI, page factories, and routes. DataSource returns raw JSON; Repository decodes Model, creates Entity, and returns Result with Failure. Presentation consumes entities.

## 2 - Create a component

Choose 2, enter `user_card`, and select Cubit, Bloc, or no state management. A custom parent such as `lib/shared/components` produces `lib/shared/components/user_card`.

A component contains its widget and optional controller/state files. It does not add unnecessary Data/Domain layers or a route.

## 3 and 4 - List entries

Choose 3 for features or 4 for components. Each entry shows its name, controller style, and path. These lists use the registry; use Doctor to reconcile registry/folder inconsistencies.

## 5 and 6 - Remove entries

Choose 5 to remove a feature or 6 to remove a component. Select the entry by number, review the plan, and apply or cancel.

Folder removal includes handwritten edits and nested entries inside it. External files require recorded ownership; matching names alone never authorize deletion. DI, page factories, routes, and registry are updated together. Analysis prevents application when unresolved references remain.

## 8 - Recover an interrupted operation

Choose 8, then 1 to attempt recovery. The operating system releases locks when their process dies, and dead legacy PID locks are reclaimed automatically.

Safe files are restored even if another file conflicts. Backups and unresolved records remain for another attempt. Save edits you want to keep before resolving conflicts. Do not delete operation.lock to bypass a live operation.

## 9 - Maintenance and reset

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

## 10 - Inspect and repair the project

Choose 10 to inspect metadata, folders, sources, bindings, routes, and dependencies. Supported automatic fixes appear as REPAIR; preserved edits or unsupported custom structures appear as NOTICE.

Review the proposed plan before applying. Corrupt registry contents are archived before replacement. Doctor does not guess how to rewrite complex conditional integrations or unknown custom code.

## 11 - Rename or move an entry

Select the entry, enter a new name such as `dashboard`, and choose a parent such as `lib/modules`. The resulting `lib/modules/dashboard` updates known symbols, URI directives, DI, router, registry, and descendants.

Backend endpoint strings are preserved. Runtime string references and references outside supported source roots need manual review.

## 12 - Configure native flavors

Choose an existing Android, iOS, or macOS platform, or all available platforms. After review, Flavorizr processors run in staging, and native changes participate in application and recovery.

Install the required platform tools and Ruby/Xcode dependencies where needed. Application signing, icons, and device QA remain application-specific work.

## 0 - Exit

Choose 0 to end the session. EOF cancels incomplete input. Errors offer retry or return to the main menu.

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
