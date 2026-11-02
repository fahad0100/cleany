import 'package:flutter/material.dart';

/// Reusable empty/error surface generated as a stateless Cleany component.
class StatusPanelWidget extends StatelessWidget {
  const StatusPanelWidget({
    super.key,
    required this.title,
    this.description,
    this.icon = Icons.inbox_outlined,
    this.onRetry,
    this.retryLabel,
  });
  final String title;
  final String? description;
  final IconData icon;
  final VoidCallback? onRetry;
  final String? retryLabel;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: Theme.of(context).colorScheme.primary
              .withValues(alpha: .08),
          child: Icon(
            icon,
            size: 30,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        if (description != null) ...[
          const SizedBox(height: 8),
          Text(description!, textAlign: TextAlign.center),
        ],
        if (onRetry != null) ...[
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(retryLabel ?? 'Retry'),
          ),
        ],
      ],
    ),
  );
}
