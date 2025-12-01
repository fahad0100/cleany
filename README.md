
---

# 🚀 Cleany — Flutter Clean Architecture Generator

**Cleany** is more than a feature generator—it’s a **complete automation toolkit** designed to bootstrap full Flutter projects following **Clean Architecture** and **Cubit** state management.

With Cleany, you eliminate repetitive setup steps and focus entirely on writing real business logic.

---

## 🚀 How Cleany Works

For the best experience, start with a fresh Flutter project.
Cleany prepares a full, production-ready architecture instantly—no manual setup required.

---

## 🧱 1. Core Structure Automation

Running the Core command generates all foundational components of a scalable Flutter application:

* constants
* error handling
* navigation
* network configuration
* theming
* dependency injection (DI)

Each file comes pre-filled with ready-to-use boilerplate code.

---

## 🔧 2. Automatic Dependency Management

Cleany injects all essential Clean Architecture packages directly into your `pubspec.yaml`, including:

* flutter_dotenv
* multiple_result
* flutter_bloc / bloc
* dart_mappable
* dio / retrofit
* easy_localization
* flutter_secure_storage
* sizer
* supabase_flutter
* get_storage
* get_it
* go_router
* injectable
* equatable
* package_info_plus / device_info_plus
* build_runner
* dart_mappable_builder
* retrofit_generator
* injectable_generator
  … and more.

No manual editing required—everything is wired automatically.

---

## 🧩 3. Feature Generation (as Screen)

When running:

```bash
cleany -s profile
```

Cleany generates a complete Clean Architecture feature module:

### 🟦 Presentation

* Cubit
* States
* Pages
* Widgets

### 🟩 Domain

* Entities
* Repositories
* Usecases

### 🟧 Data

* DataSources
* Models
* Repository Implementations

Cleany also updates:

* Routing configuration
* Dependency Injection setup

Your feature becomes functional immediately.

---

## 🧩 4. Feature Generation (as Widget)

For standalone widgets:

```bash
cleany -w card_profile
```

Cleany generates:

### 🟦 Presentation

* Cubit
* States
* Pages (if needed)

### 🟩 Domain

* Entities
* Repositories
* Usecases

### 🟧 Data

* DataSources
* Models
* Repositories

Perfect for reusable UI modules.

---

## 📘 Usage

### Create a full Screen Feature

```bash
cleany -s <feature_name>
```

### Create a Widget Feature

```bash
cleany -w <feature_name>
```

### General Command

```bash
cleany [options]
```

---

### Examples

```bash
cleany auth
# Generates a full CLEAN feature with routing & DI.

cleany -c
# Builds the entire core folder structure.

cleany -a
# Injects all essential Clean Architecture dependencies.
```

---

## 🧩 Summary

**Cleany jump-starts your Flutter projects with a complete, scalable Clean Architecture setup—instantly.**
From Core generation to Feature creation, DI wiring, and routing automation, Cleany gives you everything you need to start building real functionality from day one.

---

## 📦 Feature Structure Generated

### ✅ Data Layer

* datasources
* models
* repositories

### ✅ Domain Layer

* entities
* repositories
* usecases

### ✅ Presentation Layer

* cubit
* states
* pages
* widgets

Includes pre-built base classes for immediate development.

---

## 📦 Core Structure Generated

```
constants/
    app_colors.dart
    app_images.dart
    app_enums.dart

errors/
    failure.dart

navigation/
    app_router.dart
    routers.dart

theme/
    app_theme.dart
    app_text_theme.dart
    cubit/
        theme_state.dart
        theme_cubit.dart

network/
    dio_client.dart
    network_exceptions.dart
    api_endpoints.dart

extensions/
    context_extensions.dart
    string_extensions.dart
    color_extensions.dart

widgets/
    loading_widget.dart

utils/
    validators.dart
    formatters.dart

services/
    local_keys_service.dart
    logger_service.dart

di/
    configure_dependencies.dart
    third_party_config.dart

common/
```

---

