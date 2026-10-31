// Builds a reusable widget and renders its optional presentation state.
import 'package:flutter/material.dart';

/// Builds a reusable widget and renders its optional presentation state.
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}
