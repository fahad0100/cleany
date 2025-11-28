import 'package:args/args.dart';

void printHelp(ArgParser parser) {
  // تعريف الألوان لترتيب العرض
  const String reset = '\x1B[0m';
  const String bold = '\x1B[1m';
  const String cyan = '\x1B[36m';
  const String green = '\x1B[32m';
  const String yellow = '\x1B[33m';
  const String gray = '\x1B[90m';

  print('''
${bold}Usage:$reset
  ${green}cleany$reset $cyan<command>$reset [arguments]

${bold}Available Commands:$reset
  ${green}-s$reset $cyan<name>$reset                   Generates a feature as a full ${bold}Screen$reset (with routing & DI).
  ${green}-w$reset $cyan<name>$reset                   Generates a feature as a standalone ${bold}Widget (with DI)$reset.
  ${green}-w$reset $cyan<name>$reset ${green}-p$reset $cyan<path>$reset         Generates a Widget with a custom path.
  ${green}-a$reset                          Installs essential Core dependencies (Dio, GetIt, Bloc...).
  ${green}-c$reset                          Scaffolds the essential Core folder structure.

${bold}Options:$reset
${parser.usage}

${bold}Examples:$reset
  $gray#  Create a full login feature (Screen, Logic, DI) in path lib/features/screens/:$reset
  $green  cleany -s auth$reset

  $gray#  Create a reusable order widget (Logic, DI, No Routing, No scaffold only widget) default: in path lib/features/customs/:$reset
  $green  cleany -w order_widget$reset

  $gray#  Create a widget in a specific custom path:$reset
  $green  cleany -w user_card -p "lib/features/customs/"$reset

  $gray# Setup project foundation:$reset
  $green  cleany -c$reset      $gray(Create core folder in path lib/)$reset
  $green  cleany -a$reset      $gray(Add dependencies in pubspec.yaml)$reset
''');
}
