import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../widgets/loading_widget.dart';

extension ContextExtensions on BuildContext {
  // Snackbar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void showLoading() {
    LoadingWidget().show(this);
  }

  void hideLoading() {
    LoadingWidget().hide();
  }

  void showBottomSheet({required Widget widget, double? height, Color? color}) {
    showModalBottomSheet(
      context: this,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      clipBehavior: .hardEdge,
      builder: (context) => Container(
        padding: EdgeInsetsGeometry.symmetric(vertical: 8, horizontal: 16),
        height: height ?? 75.h,
        width: 100.w,
        color: color,
        child: widget,
      ),
    );
  }
}
