String loadingWidgetFile() {
  return '''
import 'package:flutter/material.dart';

class LoadingWidget {
  OverlayEntry? _overlayEntry;

  // Singleton instance
  static final LoadingWidget _instance = LoadingWidget._internal();

  factory LoadingWidget() {
    return _instance;
  }

  LoadingWidget._internal();

  void show(BuildContext context) {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          ModalBarrier(color: Colors.black.withAlpha(50), dismissible: false),
          Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void hide() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }
}

''';
}
