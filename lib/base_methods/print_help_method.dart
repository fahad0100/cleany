import 'package:args/args.dart';

void printHelp(ArgParser parser) {
  print('''
🚀  Cleany is not just a feature generation tool; it is a complete automation solution specifically designed to jumpstart a new Flutter project with an organized Clean Architecture structure and the Cubit state management pattern.


Cleany makes the project setup process easier and faster, allowing you to focus on the Business Logic instead of spending time on repetitive configurations.


🚀 How Cleany Works:
To get the most out of Cleany, you should start your project from scratch. The tool provides everything you need to launch your entire project:

Core Structure Building (Core Automation):

When using the Core generation command, Cleany creates all the essential files and folders required by any professional Flutter project (such as constants, error handling, navigation, and network configurations).

Dependency Management:

Cleany automatically adds all necessary libraries that serve the Clean Architecture structure (like Dio, GetIt, Bloc/Cubit) to your pubspec.yaml file.

Feature Generation:

When generating any new feature (Example: cleany auth), the tool creates the complete feature structure following the Clean Architecture principles:

Presentation Layer: (Cubit, States, Pages, Widgets).

Domain Layer: (Entities, Repositories, Usecases).

Data Layer: (DataSources, Models, Repositories).

Moreover, Cleany also adds the necessary Routing for the new feature and performs the required Dependency Injection, making it ready for immediate use.




Usage:
  cleany <feature_name> 

Usage:
  cleany [options]

Options:
${parser.usage}

Example:
  cleany auth                    # To generate a new feature named (auth), creating all Clean Architecture layers, adding routing, and performing dependency injection.
  cleany -c                      # To generate the essential Core folders and packages in your pub space (for initial structure building).
  cleany -d                      # To insert the necessary Core dependency packages (like Cubit, Dio, GetIt) into the pubspec.yaml file.



In Summary: Cleany is your gateway to starting new Flutter projects with a robust Clean Architecture foundation and professional standards, ensuring maintainability and scalability from day one.



📦 Feature Will be generated:
  ✅ Data Layer (datasources, models, repositories)
  ✅ Domain Layer (entities, repositories, usecases)
  ✅ Presentation Layer (cubit, states, pages, widgets)

  with base class

📦 core Will be generated:
     ✅ constants/ 
            app_colors.dart 
            app_images.dart 
            app_enums.dart
     ✅ errors/
            failure.dart
     ✅ navigation/
            app_router.dart
            routers.dart
     ✅ theme/
            app_theme.dart
            app_text_theme.dart
          ✅ cubit/
              theme_state.dart
              theme_cubit.dart
     ✅ network/
            dio_client.dart
            network_exceptions.dart
            api_endpoints.dart
     ✅ extensions/
            context_extensions.dart
            string_extensions.dart
            color_extensions.dart
     ✅ widgets/
            loading_widget.dart
     ✅ utils/   
            validators.dart
            formatters.dart 
     ✅  services/   
            local_keys_service.dart
            logger_service.dart 
     ✅  di/   
            configure_dependencies.dart
            third_party_config.dart 
     ✅  common/  
''');
}
