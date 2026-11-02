# Changelog

- Add **App config value** to collect dev, uat and prod String values, preserve flavor YAML/custom code, and generate typed AppConfig fields with String.fromEnvironment overrides, including explicitly empty custom values.
- Expose the same DI-owned AppConfig and AppLocalStorage instances through root providers for context.read access in pages; preserve constructor injection for controllers and Data services and app-owned disposal.
- Add read-only bool AppConfig.isDebug based on Flutter kDebugMode across all environments; reserve IS_DEBUG against custom configuration keys.
- Initialize encrypted Sembast key/value storage with typed CRUD, LocalKeys, optional collection decoding, authenticated AES-256-GCM values and HMAC record identifiers. Use pass_key_storage as the scaffold password with PBKDF2-HMAC-SHA256 and a random persisted salt; retain optional auto vault keys and 32-byte base64 raw keys.
- Group the six database, cipher, key-store and exception helpers under core/storage/storage_extension; document platform prerequisites, public configuration limits and explicit key/password migrations.
- Keep menu numbering sequential: App config value 11, Project Doctor 12, recovery 13 and maintenance/reset 14; retain Apply and validate / Cancel review.
- Recover registered configuration field names with Doctor, restore missing generated configuration/bootstrap/storage files, preserve valid environment choices during archived reset, and retain legacy storage profiles during repair. Archive malformed flavor YAML before resetting to defaults.
- Add configuration key/CLI/rollback/repair tests and generated Flutter checks for context access, all flavor values, dart-define precedence, encryption, password/key loss, tampering, persistence, concurrent vault initialization, DI disposal and web compilation.
- Synchronize the package and generated-template version at 2.0.4 and refresh the README, installation examples and English usage guide for pub.dev.
- Pin generated apps to Sizer 3.1.3, wrap MaterialApp.router before evaluating responsive themes, and split light/dark Material 3 styling into AppColors, AppTextTheme and AppTheme. Add bounded responsive typography/spacing and preserve system text scaling.
- Support explicit/system theme modes and safe Doctor integration for recognizable legacy MaterialApp roots; keep theme repair, dependencies, reset and responsive widget tests consistent.
- Generate Cubit/Bloc features and components with one typed primary status field, such as homeStatus, inside their Freezed State; update it with copyWith and render initial/loading/success/failure using when callbacks. Added operations keep their own independent typed status fields.
- Include shared operation state during bootstrap and track presentation state style and primary field names through Doctor, registry recovery, refactoring, and use-case additions, preserving existing legacy union and three-field contracts.
- Remove obsolete generated component page factories before generation/Doctor validation, preserve required widget constructor inputs, and stop recreating legacy component factories or controller registrations during repair.

## [2.0.3] - 2026-11-01

- Generate self-contained components with local Cubit/Bloc providers and automatic disposal, without central DI or FeaturePages entries; preserve previous component wiring during repair and refactoring.
- Preserve customized Models during Doctor inspection and report unsupported discovered schemas without aborting the project report.
- Default added use cases to the feature Entity, allow selecting another existing Domain Entity, and create typed Data mapping hooks when Model and Entity shapes differ.
- Track selected Entity references through repair, discovery and rename/move without rewriting existing schemas.
- Support raw lists, numeric lists, lists of JSON maps, JSON maps, sets and dynamic fields, with case-insensitive input and correct Dart type normalization.
- Reuse project-local validated compiler metadata while staging fresh inputs and rerunning builders and analysis; clear failed/interrupted caches and support maintenance cleanup.
- Preserve default native app icons when Flavorizr does not generate per-flavor catalogs.
- Add actual generated-contract runtime tests and Android/iOS/macOS dev, uat and prod native build jobs.

## [2.0.2] - 2026-10-31

- Reorganize the colored CLI into Generation, Cleanup, Inspection & Management, Core & Setup, and Maintenance & Recovery, using the new 1–13 numbering.
- Explain each command before its prompts, including listing, recovery, maintenance, and exit; keep retry and maintenance-shortcut routing independent of menu numbers.
- Generate component widgets directly inside their component folder, with sibling Cubit/Bloc directories and corrected imports and page factories.
- Track component layouts so Doctor, registry recovery, rename/move, and removal preserve components generated with the previous widgets subfolder.
- Refresh the pub.dev README, command examples, environment setup guide, and CLI/generated Flutter regression coverage.
- Add menu option 3 to create entity-returning or void use cases on existing features, with shared feature repository contracts and Data implementations, central DI, independent typed Cubit/Bloc action state, and a documented backend connection hook that returns Failure until implemented.
- Include added use cases in ownership, Doctor repair/discovery, rename/move, removal, and generated Flutter runtime tests for both API providers.
- Extend the existing feature repository for new use cases instead of creating one repository per operation; retain compatibility with legacy operation contracts.
- Add environment/native VS Code launch profiles with public API URL prompts and a generated run guide. Connect recognizable Flutter scaffold main functions to dev with exact original backups, preserve custom entrypoints/profiles, and support Doctor/reset.
- Prevent builders from replacing existing unstaged files; freeze validated plans and preserve output permissions.
- Preserve customized Doctor integrations and unrelated refactoring bytes; track ownership of individual integration nodes.
- Retain unknown recovery backups, add independent checksummed journal snapshots, and append per-file transitions.
- Separate application outcomes from progress/log/cleanup warnings, retain retry inputs, and isolate operation logs.
- Share pubspec repair/reset settings, follow referenced configurations, validate SDK consistency and flavor prerequisites, and improve startup/service lifecycle diagnostics.

## [2.0.1]

### Fixed

- fix some bugs file

## [2.0.0] - 2026-10-31

- Replace legacy commands with a colored numbered CLI for initialization, feature/component generation, listing, removal, repair, refactoring, maintenance, and native flavors.
- Generate one Feature-Based + Clean Architecture template with Cubit/Bloc, Freezed, multiple_result, central DI, and optional Retrofit over Dio.
- Add compact response fields (`name:type:jsonKey`) with y/n nullability and direct review; fix repository constructor lints on current Dart.
- Add isolated validation, versioned file ownership, selective staging, kernel locks, per-file rollback/recovery, and archived reset.
- Support official Arabic/English localization, dev/UAT/prod identities, and transactional Android/iOS/macOS Flavorizr configuration.
- Refresh pub.dev metadata, API documentation, runnable examples, usage guides, and current dependencies. Cleany now requires Dart 3.13+.
- **Breaking:** replace the 1.x template/helper APIs and command aliases; existing generated layouts require an explicit migration. No database SDK is forced.

## [1.0.22] 

### ✨ Improvements
* General library updates and minor bug fixes to enhance overall performance and stability.

## [1.0.20] - 31-03-2025

### ✨ Improvements
* General library updates and minor bug fixes to enhance overall performance and stability.

## [1.0.19] - 31-03-2025

### ✨ Improvements
* General library updates and minor bug fixes to enhance overall performance and stability.

## [1.0.18] - 31-03-2025

### ♻️ Changed
* **Models:** Fully migrated from `dart_mappable` to `freezed` for data classes and code generation.

### 🐛 Fixed
* **Localization:** Resolved the naming issue for language files in the `assets` directory. Renamed the files from `ar-Ar.json` and `en-US.json` to the standard format `ar.json` and `en.json`.

### ✨ Improvements
* General library updates and minor bug fixes to enhance overall performance and stability.


## [1.0.16] - 07-03-2025

### Added
- **Smart Collision Detection:** The tool now recursively scans all feature directories (`lib/features/`, `lib/features/sub/`, and parent sub-folders) to prevent duplicate feature names and avoid import conflicts.
- **Full Windows Support:** Enhanced CLI commands execution for Windows OS using shell resolution.

### Fixed
- **Improved Output Logging:** Refactored all console outputs using a dedicated `Logger` for a cleaner and more professional terminal experience.
- **Optimized README.md:** Completely redesigned the documentation with clear guides for installation, Windows setup, and usage examples.
- **Modular DI Structure:** Each generated feature now has its own isolated `di/` folder and dependency injection file for better maintainability and cleaner code.
- **Performance Optimization:** Eliminated redundant `build_runner` calls during the generation process to speed up feature creation.

## [1.0.15] 

### Fixed
- Bug di file


## [1.0.14] 

### Fixed
- Bug di file


## [1.0.13]

### Changed
- Changed the flag from `-p` to `-f` for adding sub-features to a main feature.

### Improved
- General code improvements and under-the-hood optimizations.

## [1.0.7] 

### Fixed
- Bug name file feature

## [1.0.6] 

### Fixed
- Bug create files

## [1.0.4] 

### Fixed
- Bug when creating new feature

## 1.0.1

- 🛠 Fixed bug with package installation on Windows.

## 1.0.0

- Initial release of **Cleany**.
- First public version published.
- Core structure generation.
- Feature generation (Screen & Widget) with Clean Architecture.
- Automatic Dependency Injection and Routing setup.

