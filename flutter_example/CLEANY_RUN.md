# Running this Cleany application

The Dart entrypoints select configuration, localization, DI, and routing:

| Environment | Entrypoint | Native flavor |
| --- | --- | --- |
| dev | lib/main_dev.dart | dev |
| uat | lib/main_uat.dart | uat |
| prod | lib/main_prod.dart | prod |

New/default Flutter entrypoints delegate to dev through lib/main.dart. Existing
custom entrypoints are preserved; launch a named entrypoint to use Cleany.
Recognizable Flutter scaffold main functions are archived under
.cleany/backups/entrypoints/ before being connected to dev. Their widget classes
remain available to existing tests. Review custom startup logic before migrating.

## VS Code

Choose Cleany DEV, Cleany UAT, or Cleany PROD in Run and Debug, then launch.
A prompt requests the public API base URL for that environment. Leave it empty
only when config/flavors/<environment>.yaml already supplies api_base_url.
UAT and prod require HTTPS. Never put privileged credentials in YAML assets or
launch arguments. Existing launch profiles, inputs, and JSONC comments survive.

The profiles marked (native flavor) additionally select the native app identity.
Run Cleany menu 10 for the target platform before using those profiles.
Environment selection and Flutter debug/profile/release modes are independent.
These profiles use debug mode; select release mode when preparing distribution.

## Terminal or another IDE

Before native flavor setup, select the Dart environment explicitly:

```sh
flutter run --target lib/main_dev.dart --dart-define=API_BASE_URL=https://api.example.com
flutter run --target lib/main_uat.dart --dart-define=API_BASE_URL=https://api.example.com
flutter run --target lib/main_prod.dart --dart-define=API_BASE_URL=https://api.example.com
```

Replace the example URL with your real public API URL. After menu 10 configures
native flavors, add --flavor dev, --flavor uat, or --flavor prod respectively:

```sh
flutter run --flavor dev --target lib/main_dev.dart --dart-define=API_BASE_URL=https://api.example.com
flutter build appbundle --flavor prod --target lib/main_prod.dart --dart-define=API_BASE_URL=https://api.example.com
```

Configure signing and validate the native build for each distribution platform.
Project Doctor restores missing run profiles and guide files without replacing
customized existing configurations.
