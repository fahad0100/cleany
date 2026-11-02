import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Saves UI evidence without serializing application/session state.
Future<void> main() async {
  final directory = Directory('build/store_screenshots')
    ..createSync(recursive: true);
  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      await File('${directory.path}/$name.png').writeAsBytes(bytes);
      return true;
    },
    responseDataCallback: (data) async {
      await File('${directory.path}/result.txt').writeAsString(
        'Live store flow completed. Screenshots saved locally.\n',
      );
    },
  );
}
