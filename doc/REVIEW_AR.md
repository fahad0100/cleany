# Cleany 2.0 Architecture Review

Review date: October 31, 2026. Cleany is a Dart tool that generates Flutter applications. This review covers the CLI, generation, templates, Dart/YAML integration, registry, execution and recovery, maintenance, repair, refactoring, and tests.

## Architectural assessment

The implementation follows sound practices for a structured generator and a professional Flutter starter: separated tool responsibilities, clear application layers, independent Domain contracts, and operations that can be validated and recovered. The approximate engineering assessment is **8/10**. This is a review judgment, not an automated metric or a guarantee that every generated application is ready for commercial release.

The fixed template is a suitable shared starting point for teams using Feature-Based Architecture, Clean Architecture, Cubit/Bloc, and Freezed. Full layering suits features with data access and business rules; smaller components use a simpler structure to avoid unnecessary layers.

## Implemented capabilities

| Area | Current behavior |
| --- | --- |
| User interface | A colored numbered menu, apply-and-validate or cancel review, and retry or return-to-menu choices after errors. |
| Maintenance | Option 9 or `cleany maintenance`: clean abandoned local workspaces, archive and reset, or configure command deadlines. |
| Reset | Archive app/core, registered entries, and managed configuration, including user edits, then install the fixed template and an empty registry. Preserve unrelated code, dependencies, and native projects. |
| Ownership registry | Schema v2 stores each entry's name, kind, path, controller style, contract, and template version. File records include path, kind, owner, hash, and ownership origin. |
| Removal | Reviewed removal includes the entry folder and its edits. Files outside it require recorded ownership; matching names alone never authorize deletion. |
| Recovery | Disk backups, hashes, and independent file states. A conflict or damaged backup for one file does not block restoration of other safe files. Unresolved records remain available for another attempt. |
| Locking | The operating system releases a lock when its owner process dies. Dead legacy PID locks are reclaimed automatically. |
| Output consistency | Collect source, test, resource, and selected native outputs. Reject unsupported locations and changes during or after analysis. Apply the collected results after checking original inputs. |
| Large projects | Copy relevant inputs, excluding build/Pods/cache and unselected platforms. Use filesystem copies and streaming hashes; retain changed file contents in the plan. |
| Execution progress | Display stages, elapsed time, and active commands, with progress logs, per-command deadlines, command-tree cancellation, and rollback. |
| Doctor | Option 10 detects missing/corrupt metadata, unregistered folders, stale entries, missing files/bindings/routes, and dependency constraints outside supported ranges. |
| Registry reconstruction | Preserve corrupt metadata, discover recognizable features/components, and infer supported contracts and nested relationships without claiming unverified handwritten external APIs. |
| Rename and move | Option 11 updates known filenames, symbols, imports/exports/parts, DI, router, registry, and descendants while preserving backend endpoint strings. |
| Data contracts | The menu collects Entity/Model fields as `name:type:jsonKey`, followed by Nullable. The Dart library also supports advanced typed request contracts. |
| Write requests | Opening a page does not automatically send POST/PUT/PATCH/DELETE. Contracts with input fields require an explicit Request and a user action. |
| Environments | Option 12 runs selected Android/iOS/macOS Flavorizr processors in isolation, with native files included in recoverable application. |
| App identity | Resolve supported static Gradle properties, xcconfig references, and Apple project identifiers without executing project scripts. Manual input handles unresolved cases. |
| Template maintenance | Fixed template version 2.0.0, separated app/network/localization and Data/Domain/Presentation modules, and explanatory source comments. |

## Generated application quality

- DataSource returns raw JSON and propagates exceptions. Repository decodes a Model, creates an Entity, and returns `Result<Entity, Failure>` using multiple_result.
- Domain contains Entity, Request, Repository contracts, and UseCases. It does not depend on Dio, Retrofit, GetIt, or data-layer models.
- Presentation uses entities and Freezed states, including loading, success, and failure, with protection against emission after disposal. Domain input types contain no HTTP transport details.
- Failure distinguishes network, unauthorized, validation, business, server, and unexpected errors. Technical exception mapping occurs once at the repository boundary, with an unexpected-error reporting callback.
- A central composition root registers application-scoped lazy singletons and factory controllers owned by BlocProvider. Router uses page factories without importing Cubit/Bloc implementations.
- Bootstrap awaits environment setup and DI in sequence. YAML is public configuration; UAT and production require HTTPS.
- Dio has a dedicated client/interceptor structure, and Retrofit is optional. The template does not force Supabase, another database SDK, or unused storage/UI dependencies.
- Official flutter_localizations, English/Arabic ARB files, gen-l10n, and automatic RTL support are included. easy_localization is not added.

## Deliberate limits and future work

1. **Application is recoverable across files, rather than one atomic operation over the entire project.** External observers may see intermediate states. Forced interruption can require option 8, and conflicts may need resolution. This is not a guarantee against every disk-corruption or power-loss scenario.
2. **AST integration supports the fixed composition contracts and several structural forms.** Direct, returned, local-variable, and field-backed route lists are supported. Complex conditional registrations are rejected to preserve their meaning. Composition entrypoint names remain part of the template contract.
3. **Refactoring recognizes template symbols and Dart directives.** It does not replace full semantic language-server refactoring. Runtime string references and references outside lib/test/integration_test/tool require review.
4. **Identity discovery uses conservative static analysis.** Dynamic Gradle calculations, plugins, and scripts are not executed. Unresolved cases request input instead of guessing.
5. **CLI field entry is intentionally simple; the Dart API supports one operation and a constrained type set.** Simple lists, dates, and nullable fields are supported. Nested DTOs, envelopes, pagination, multipart, and path parameters currently need application code.
6. **Validation still scans relevant inputs.** Hashing costs scale with their size, and large resets/moves retain changed contents in memory. Incremental indexing and benchmarks on very large repositories remain useful improvements.
7. **Pub workspaces and symlinked source paths are unsupported.** Ordinary path dependencies are temporarily rebased and restored to portable paths. External local dependencies remain trusted inputs managed by the user.
8. **Production security and observability belong to the application.** Session-token injection is available, but refresh-token flows, secure storage, authorization rules, and a complete monitoring service are not generated automatically.
9. **Cross-platform confidence requires actual CI results.** Jobs cover Linux/macOS/Windows and the minimum Dart SDK, but local macOS success does not prove other environments. Ctrl+C uses SIGINT with platform-specific command-tree termination; Windows keyboard behavior needs CI or hands-on verification.
10. **Template upgrades remain conservative.** Stored versions provide a migration foundation, but automatic merges of user edits across every template release are not implemented. Doctor repairs known parts without imposing silent upgrades.

## Prioritized recommendations

- Add semantic refactoring for complex symbol relationships and numbered template migrations with focused regression tests.
- Import OpenAPI contracts into the same fixed template, including nested DTOs, pagination, and multiple operations per feature.
- Benchmark large projects, measure memory/time, inject failures at multiple commit points, and verify Windows behavior on actual runners.
- Add saveable Doctor reports, diagnostic severity, and individual repair selection as repair plans grow.
- Extend generated application tests around each team's business rules instead of treating general scaffold coverage as product coverage.

## Validation and local setup

Validation covers tool formatting, analysis, and tests, followed by actual generated Flutter applications for both API providers. The application suites cover builders, analysis, states/widgets, localization, custom contracts, refactoring, repair, removal, reset, three-platform Flavorizr configuration, and a local path dependency. These checks validate source and native configuration; they do not replace APK/IPA builds, signing, or device testing.

The recorded local environment is Flutter 3.47.7 / Dart 3.13.5. CI follows stable toolchains; future compatibility requires rerunning the checks.

For a local installation, run `dart pub global activate --source path .` from the tool checkout, then run `cleany` inside a Flutter project. Options 9, 10, 11, and 12 provide maintenance, repair, refactoring, and native flavors. `cleany maintenance` opens maintenance directly.

No package or application was published automatically. README documents the menu, limitations, ownership, and recovery policy.

## Recorded verification results

- 88 tool tests passed, including cancellation during application, supported dependency-range narrowing, and official SDK dependency repair.
- Both actual generated-app suites passed: Dio and Retrofit, including runtime behavior, contracts, localization, refactoring, repair, removal, and reset.
- Android/iOS/macOS Flavorizr configuration passed through the staged transaction.
- `dart analyze --fatal-infos`, formatting checks, and `git diff --check` passed.
- The 2.0.0 publication dry run reported zero warnings; no upload was performed.
- GitHub Actions jobs on other operating systems were not executed in this local session. Signed application builds and deployment were not performed.

## Repository constructor compatibility fix

The `prefer_initializing_formals` diagnostic was reproduced: the previous constructor form passed with Dart language version 3.10 but emitted a lint with 3.13. The template now uses an initializing formal while preserving the `reportError` argument. Generated-app coverage includes both language settings, the `/get/home` GET contract, response field `home`, and nullable request field `idUser` mapped to `keyUser`. Command success markers now appear only for successful exit codes.

## Compact field input

Define fields and API contract asks for the response field count, then each `name:type:jsonKey` and y/n Nullable answer. After the final field, it proceeds directly to apply/cancel review without method, endpoint, or Request data questions. Type matching is case insensitive, and numeric choices accept Arabic/Persian digits. Format, type, and duplicate errors are retried at the current question without discarding earlier fields. Actual application tests create userName, favourite, and age through this workflow and verify JSON-to-Entity mapping.

## pub.dev preparation for 2.0.0

Dependencies and AST integration were updated to analyzer 14.7, and the tool minimum SDK is now Dart 3.13. README and the release summary were rewritten, and a safe runnable example and usage guide were added. The local pana audit achieved 160/160 with 146/146 public API elements documented. See the [release report](PUBDEV_REPORT.md). pub.dev computes its own score after publication; no publication was performed.
