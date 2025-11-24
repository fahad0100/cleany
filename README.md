

# 🚀 Cleany — Flutter Clean Architecture Generator

**Cleany** is not just a feature generator — it is a **complete automation solution** designed to bootstrap a new Flutter project with a fully organized **Clean Architecture** structure using the **Cubit** state management pattern.

It simplifies the entire project setup process, allowing you to focus on business logic instead of repetitive configurations.

---

## 🚀 How Cleany Works

To get the most out of Cleany, you should start your project from scratch. The tool prepares everything you need to launch a complete, well-structured Flutter application.

---

### 🧱 1. Core Structure Building (Core Automation)

When running the Core generation command, Cleany automatically creates all essential files and folders required for any professional Flutter project, including:

* constants
* error handling
* navigation
* network configurations
* theme
* di

---

### 🔧 2. Dependency Management

Cleany adds all necessary packages required for a Clean Architecture–based project directly into your `pubspec.yaml`, such as:

* Dio
* get_it
* logger
* bloc
* retrofit
* flutter_dotenv
* injectable
* supabase_flutter
* cached_network_image
* flutter_bloc
* equatable
* dartz
* dio
* go_router
* get_storage
* intl
* dart_mappable
* hydrated_bloc
* uuid
* image_picker
* flutter_svg
* connectivity_plus
* permission_handler
* url_launcher
* flutter_secure_storage
* path_provider
* package_info_plus
* share_plus
* lottie
* gap
* shimmer
* sizer
* build_runner
* dart_mappable_builder
* retrofit_generator
* injectable_generator

---

### 🧩 3. Feature Generation

When generating a new feature (Example: `cleany auth`), Cleany produces the full feature structure following Clean Architecture principles:

#### 🟦 Presentation Layer

* Cubit
* States
* Pages
* Widgets

#### 🟩 Domain Layer

* Entities
* Repositories
* Usecases

#### 🟧 Data Layer

* DataSources
* Models
* Repositories

It also automatically adds:

* Routing entries for the new feature
* Dependency Injection configuration

So your new module becomes instantly usable.

---

## 📘 Usage

### Generate a Feature

```bash
cleany <feature_name>
```

### General Command

```bash
cleany [options]
```

### Options

```
${parser.usage}
```

### Examples

```bash
cleany auth
# Generates a new feature (auth) with all Clean Architecture layers + routing + DI.

cleany -c
# Generates the essential Core folders and files for the initial project structure.

cleany -d
# Inserts the required Clean Architecture dependencies (Cubit, Dio, GetIt) into pubspec.yaml.
```

---

## 🧩 Summary

**Cleany is your gateway to starting new Flutter projects with a strong and scalable Clean Architecture foundation from day one.**

---

## 📦 Feature Structure Generated

* ✅ **Data Layer**

  * datasources
  * models
  * repositories

* ✅ **Domain Layer**

  * entities
  * repositories
  * usecases

* ✅ **Presentation Layer**

  * cubit
  * states
  * pages
  * widgets

Includes **base classes** for instant development.

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


