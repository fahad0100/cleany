/// Plans, validates, and applies a fixed Flutter feature architecture.
///
/// Use [Generator] to prepare changes and [GenerationTransaction] to validate
/// and apply them. [ProjectDoctor], [FeatureLifecycle], and [ProjectMaintenance]
/// provide repair, refactoring, and reset workflows. For the interactive CLI,
/// install the executable and run `cleany` in a Flutter project.
library;

export 'src/command_runner.dart';
export 'src/generator.dart';
export 'src/project.dart';
export 'src/transaction.dart';

export 'src/specification.dart';
export 'src/operation.dart';
export 'src/doctor.dart';
export 'src/lifecycle.dart';
export 'src/maintenance.dart';
export 'src/project_lock.dart';
