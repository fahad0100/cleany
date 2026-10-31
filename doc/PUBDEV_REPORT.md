# Cleany 2.0.0 — local pub.dev readiness report

Date: 2026-10-31. This is a local prerelease audit, not a published pub.dev score.

| Check | Points | Result |
| --- | --- | --- |
| Follow Dart file conventions | 30/30 | passed |
| Provide documentation | 20/20 | passed |
| Platform support | 20/20 | passed |
| Pass static analysis | 50/50 | passed |
| Support up-to-date dependencies | 40/40 | passed |
| **Total** | **160/160** | **Passed** |

## Evidence

- Tool: pana 0.23.19. Runtime: Dart 3.13.5 / Flutter 3.47.7 on macOS.
- API documentation: **146/146 public elements (100%)**, plus a runnable example.
- API documentation generation: zero warnings and zero errors.
- Static analysis and Dart formatting: no issues.
- Dependencies: no outdated packages listed after upgrade; supported latest versions and lower-bound analysis passed.
- Generator tests: 88 passed.
- Generated Flutter applications: both Dio and Retrofit suites passed, including field input, analysis, runtime contracts, refactoring, repair, removal, reset, and native flavor configuration.
- Publish dry run: zero warnings; no version was uploaded.
- Desktop CLI platforms are declared as Linux, macOS, and Windows. Local test execution was on macOS; CI jobs for other systems are configured, not claimed as locally executed.
- The CLI minimum SDK is Dart 3.13.0. Generated fixture language settings include 3.10 and 3.13; these are separate from the SDK needed to run Cleany.

## Reproduce

Run analysis, tests, the example, and `dart pub publish --dry-run` as described in [README](../README.md#development-and-release-checks). For pub scoring, run pana on a disposable copy because it can modify dependency resolution files:

```sh
dart pub global activate pana
dart pub global run pana --json /path/to/cleany-copy > pana-report.json
```

Use the default standalone dartdoc selected by pana. The SDK documentation wrapper in the tested environment does not expose all options expected by pana, while the normal `dart doc` command independently builds the package documentation successfully.

pub.dev runs its own analysis after publication and may use a different toolchain or scoring model. See the [official scoring criteria](https://pub.dev/help/scoring) and [publishing guide](https://dart.dev/tools/pub/publishing).
