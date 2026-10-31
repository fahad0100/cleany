// Starts the application using the selected flavor entry point.
import 'app/bootstrap.dart';
import 'app/config/app_environment.dart';

/// Starts the application using the selected flavor entry point.
Future<void> main() => bootstrap(AppEnvironment.prod);
