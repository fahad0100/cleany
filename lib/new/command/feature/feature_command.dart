import 'dart:io';

import 'package:cleany/new/Extension/string_extension.dart';
import 'package:cleany/new/command/feature/enum_feature.dart';
import 'package:cleany/new/command/feature/model/select_feature_command.dart';
import 'package:interact/interact.dart';

SelectFeatureCommand featureCommand() {
  print("\n\nHi bro? 👋\n\n");

  FeatureType typeFeature = FeatureType.onlyScreen;
  StateType typeState = StateType.cubit;

  final options = [
    "01 Screen:     Only One Main Screen create with routing & DI",
    "02 Multiple:   Multiple Screen(Main screen with Edit screen) with routing & DI",
    "03 Reusable:   Only create reusable feature with DI",
  ];

  final featureType = Select(
    initialIndex: 0,
    prompt: 'What do you want to do?\n----------------------------\n',
    options: options,
  ).interact();

  final optionsFeature = [
    "01 Bloc:  Bloc pattern with flutter_bloc package (Recommended for most projects)",
    "02 Cubit: Cubit pattern with flutter_bloc package (Simpler than Bloc, good for less complex features)",
  ];

  final selectionState = Select(
    initialIndex: 0,
    prompt: 'What do you want to do?\n----------------------------\n',
    options: optionsFeature,
  ).interact();

  print("Enter name feautre: ");
  String? nameFeature = stdin.readLineSync();
  List<String> subScreens = [];
  print("Enter path: ");
  String? path =
      stdin.readLineSync() ?? "lib/features/${nameFeature!.toSnakeCase()}";

  switch (featureType) {
    case 0:
      typeFeature = FeatureType.onlyScreen;
      if (path.isEmpty) {
        path = "lib/features/${nameFeature!.toSnakeCase()}";
      }
      break;
    case 1:
      typeFeature = FeatureType.multipleScreens;

      while (true) {
        print("Enter name sub screen (or 'Q' to finish): ");
        String? subScreen = stdin.readLineSync();

        if (subScreen?.toLowerCase() == 'q') {
          break;
        }

        if (subScreen != null && subScreen.isNotEmpty) {
          subScreens.add(subScreen);
        }
      }
      if (path.isEmpty) {
        path = "lib/features/${nameFeature!.toSnakeCase()}";
      }
      break;
    case 2:
      typeFeature = FeatureType.reusableWidget;
      if (path.isEmpty) {
        path = "lib/reusable_features/${nameFeature!.toSnakeCase()}";
      }
      break;
    default:
      print('Invalid selection');
  }
  switch (selectionState) {
    case 0:
      typeState = StateType.bloc;
      break;
    case 1:
      typeState = StateType.cubit;
      break;
    default:
      print('Invalid selection');
  }

  final feature = SelectFeatureCommand(
    type: typeFeature,
    state: typeState,
    name: nameFeature!,
    nameVariable: nameFeature.toCamelCase(),
    nameFile: "${nameFeature.toSnakeCase()}_feature_screen.dart",
    subScreensName: subScreens,
    subScreensVariable: subScreens.map((e) => e.toCamelCase()).toList(),
    subScreensFile: subScreens
        .map((e) => "${e.toSnakeCase()}_screen.dart")
        .toList(),
    path: path,
  );
  print(feature);
  return feature;
}
