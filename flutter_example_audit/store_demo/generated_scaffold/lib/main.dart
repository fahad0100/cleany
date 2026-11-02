import 'main_dev.dart' as cleany_dev;
import 'package:flutter/material.dart';

/// Starts Cleany using the development entrypoint.
Future<void> main() => cleany_dev.main();

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('Hello World!'))),
    );
  }
}
