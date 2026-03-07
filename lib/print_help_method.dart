import 'package:args/args.dart';

void printHelp(ArgParser parser) {
  const String reset = '\x1B[0m';
  const String bold = '\x1B[1m';
  const String cyan = '\x1B[36m';
  const String green = '\x1B[32m';
  const String yellow = '\x1B[33m';
  const String gray = '\x1B[90m';

  print('''
${bold}🚀 Cleany - Flutter Clean Architecture Generator$reset

${bold}Usage:$reset
  ${green}cleany$reset $cyan<command>$reset [arguments]

${bold}Commands:$reset
  ${green}-c$reset, ${green}--core_folders$reset      Initialize the project ${bold}Core$reset structure & Dependencies.
  ${green}-s$reset, ${green}--feature_screen$reset   Create a full ${bold}Screen Feature$reset (with Routing & DI).
  ${green}-w$reset, ${green}--feature_widgets$reset  Create a standalone ${bold}Widget Feature$reset (with DI).

${bold}Sub-Feature Mapping:$reset
  ${green}-f$reset, ${green}--feature$reset           Use with ${green}-w$reset to nest a widget inside a parent feature.

${bold}Options:$reset
${parser.usage}

${bold}Examples:$reset
  ${gray}# Initialize project foundation (Run this first)$reset
  ${green}cleany -c$reset

  ${gray}# Create a main feature screen (e.g., Auth, Profile)$reset
  ${green}cleany -s auth$reset

  ${gray}# Create a standalone reusable widget feature$reset
  ${green}cleany -w custom_button$reset

  ${gray}# Create a sub-feature nested inside a parent feature$reset
  ${green}cleany -w user_card -f auth$reset

${yellow}Note:$reset For best results, run ${green}-c$reset in a fresh Flutter project.
''');
}
