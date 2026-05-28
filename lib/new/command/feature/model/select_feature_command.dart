import 'package:cleany/new/command/feature/enum_feature.dart';

class SelectFeatureCommand {
  final FeatureType type;
  final StateType state;
  final String name;
  final List<String> subScreensName;
  final List<String> subScreensVariable;
  final List<String> subScreensFile;
  final String nameVariable;
  final String nameFile;
  final String path;

  SelectFeatureCommand({
    required this.type,
    required this.state,
    required this.name,
    required this.subScreensName,
    required this.subScreensVariable,
    required this.subScreensFile,
    required this.nameVariable,
    required this.nameFile,
    required this.path,
  });

  // ميثود toString عشان لما تسوي print(command) يطلع لك شكل مرتب
  @override
  String toString() {
    return 'SelectFeatureCommand(type: $type, state: $state, name: $name, subScreensName: $subScreensName, subScreensVariable: $subScreensVariable, subScreensFile: $subScreensFile, nameVariable: $nameVariable, nameFile: $nameFile, path: $path)';
  }

  // عشان تقدر تقارن بين نسختين من الكلاس إذا عندهم نفس البيانات
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SelectFeatureCommand &&
        other.type == type &&
        other.state == state &&
        other.name == name &&
        other.subScreensName == subScreensName &&
        other.subScreensVariable == subScreensVariable &&
        other.subScreensFile == subScreensFile &&
        other.nameVariable == nameVariable &&
        other.nameFile == nameFile &&
        other.path == path;
  }

  // إنشاء الـ hash بناءً على المتغيرات
  @override
  int get hashCode {
    return Object.hash(
      type,
      state,
      name,
      subScreensName,
      subScreensVariable,
      subScreensFile,
      nameVariable,
      nameFile,
      path,
    );
  }
}

//-----
