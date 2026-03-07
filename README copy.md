
```markdown
# 🚀 Cleany — Flutter Clean Architecture Generator

[![Pub Version](https://img.shields.io/pub/v/cleany.svg)](https://pub.dev/packages/cleany)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-blue.svg)]()

**Stop writing boilerplate. Start building features.**

**Cleany** is more than just a feature generator—it’s a **complete automation toolkit** designed to bootstrap full Flutter projects using **Clean Architecture** and **Cubit** state management. 

Setting up a scalable architecture from scratch takes hours. Wiring Dependency Injection, configuring routers, and creating layers of Data, Domain, and Presentation for every single feature is exhausting. **Cleany does all of this in seconds.**



---

## ✨ Why Choose Cleany?

* **⚡ Zero Config:** Run a command and start coding your business logic immediately.
* **🛡️ Safe & Smart:** Built-in collision detection ensures you never accidentally overwrite existing code or create import loops.
* **🌍 Cross-Platform:** Works flawlessly on Windows, macOS, and Linux.
* **📦 Modern Stack:** Automatically installs and configures the industry's best tools: `go_router`, `get_it`, `flutter_bloc`, `dio`, `supabase_flutter`, and more.

---

## 🛠️ Installation

Activate the package globally via Dart:

```bash
dart pub global activate cleany

```

---

## 🚀 How Cleany Works

For the best experience, start with a fresh Flutter project.

### 🧱 1. Core Structure Automation (`cleany -c`)

Run this once at the beginning of your project. It generates all foundational components of a scalable Flutter application, including:

* Error handling & Network configuration (`dio`)
* Navigation (`go_router`)
* Theming & Constants
* Dependency Injection (`get_it` & `injectable`)

**Automatic Dependency Management:** Cleany doesn't just create folders; it automatically finds the **latest compatible versions** of essential packages and injects them into your `pubspec.yaml`. *No manual editing required—everything is wired automatically.*

### 📱 2. Screen Feature Generation (`cleany -s <name>`)

Need a new page? Cleany generates a complete module containing **Data, Domain, and Presentation** layers.
But it doesn't stop there—it automatically updates your `app_router.dart` and `configure_dependencies.dart` so **your feature is functional immediately**.

### 🧩 3. Widget & Sub-Feature Generation (`cleany -w <name>`)

Perfect for standalone, reusable UI modules that still need clean architecture (like a complex custom card or a bottom sheet).
**Need to nest it?** Use the `-f` flag to create a sub-feature inside an existing parent feature!
`cleany -w header -f profile` ➔ Generates the `header` feature safely inside `lib/features/profile/sub/header`.

---

## 📘 Usage & Commands

| Command | Description | Example |
| --- | --- | --- |
| `cleany -h` | Show help and usage information. | `cleany -h` |
| `cleany -c` | **Initialize Core:** Builds the entire core folder structure and installs all dependencies. *(Run this first in a fresh project)* | `cleany -c` |
| `cleany -s <name>` | **Create Screen Feature:** Generates a full feature with routing & DI. | `cleany -s auth` |
| `cleany -w <name>` | **Create Widget Feature:** Generates a standalone feature intended as a reusable widget. | `cleany -w custom_button` |
| `cleany -w <name> -f <parent>` | **Create Sub-Feature:** Generates a widget feature nested inside an existing parent feature. | `cleany -w user_card -f auth` |

---

## 📦 What gets generated?

### 🌟 Feature Structure (`cleany -s` & `cleany -w`)

Whether it's a screen or a widget, Cleany enforces a strict, scalable structure:

```text
lib/features/feature_name/
├── data/
│   ├── datasources/   (remote_data_source.dart)
│   ├── models/        (model.dart)
│   └── repositories/  (repository_data.dart)
├── domain/
│   ├── entities/      (entity.dart)
│   ├── repositories/  (repository_domain.dart)
│   └── use_cases/     (use_case.dart)
├── presentation/
│   ├── cubit/         (cubit.dart, state.dart)
│   ├── pages/         (feature_screen.dart / feature_widget.dart)
│   └── widgets/       (widget.dart) // Only for -s (Screen)
└── di/                (feature_di.dart)

```

### 🏗️ Core Structure (`cleany -c`)

A rock-solid foundation for any enterprise-level app:

```text
lib/core/
├── common/
├── constants/
│   ├── app_colors.dart
│   ├── app_images.dart
│   ├── app_enums.dart
│   └── app_icons.dart
├── di/
│   ├── configure_dependencies.dart
│   └── third_part.dart
├── errors/
│   ├── failure.dart
│   └── network_exceptions.dart
├── extensions/
│   ├── context_extensions.dart
│   ├── string_extensions.dart
│   ├── color_extensions.dart
│   └── font_extensions.dart
├── navigation/
│   ├── app_router.dart
│   └── routers.dart
├── network/
│   ├── dio_client.dart
│   └── api_endpoints.dart
├── services/
│   ├── local_keys_service.dart
│   └── app_device_utils.dart
├── theme/
│   ├── app_theme.dart
│   └── app_text_theme.dart
├── utils/
│   ├── validators.dart
│   └── formatters.dart
├── widgets/
│   └── loading_widget.dart
└── setup.dart

```

---

## ❤️ Contributions & Issues

Found a bug or have a feature request? Feel free to open an issue or contribute to the repository! Let's build the ultimate Flutter architecture tool together.

