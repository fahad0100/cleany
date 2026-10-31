# Changelog

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

