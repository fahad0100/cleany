import 'package:args/args.dart';

void printHelp(ArgParser parser) {
  const String reset = '\x1B[0m';
  const String bold = '\x1B[1m';
  const String cyan = '\x1B[36m';
  const String green = '\x1B[32m';
  const String gray = '\x1B[90m';

  print('''
${bold}Usage:$reset
  ${green}cleany$reset $cyan<command>$reset [arguments]

${bold}Available Commands:$reset
  ${green}-s$reset $cyan<feature name>$reset                       Generates a feature as a full ${bold}Screen$reset (with routing & DI).
  ${green}-w$reset $cyan<sub feature name>$reset                   Generates a sub feature as a standalone ${bold}Widget (with DI)$reset.
  ${green}-w$reset $cyan<sub feature name>$reset ${green}-p$reset $cyan<main feature>$reset         Generates a sub feature related with a main features.
  ${green}-c$reset                          Scaffolds the essential Core folder structure.

${bold}Options:$reset
${parser.usage}

${bold}Examples:$reset
  $gray#  Create a full login feature (Screen, Logic, DI) in path lib/features/:$reset
  $green  cleany -s auth$reset

  $gray#  Create a reusable order widget (Logic, DI, No Routing, No scaffold only widget) default: in path lib/features/sub/:$reset
  $green  cleany -w order_widget$reset

  $gray#  Create a sub features for a specific features:$reset
  $green  cleany -w user_card -f {name features}$reset

  $gray# Setup project foundation:$reset
  $green  cleany -c$reset      $gray(Create core folder in path lib/)$reset
''');
}
