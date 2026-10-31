import 'dart:convert';

import 'package:cleany/cleany.dart';

void main(List<String> arguments) =>
    print(jsonEncode(Project(arguments.single).applicationIds()));
