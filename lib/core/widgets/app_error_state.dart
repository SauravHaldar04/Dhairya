import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:aparna_education/core/theme/app_theme.dart';

/// A standardised error state widget with an optional retry action.
///
/// ```dart
/// AppErrorState(
///   message: 'Could not load lectures.',
///   onRetry: () => bloc.add(LoadLectures()),
/// )
/// ```
class AppErrorState extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final IconData icon;

  AppErrorState({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    IconData? icon,
  }) : icon = icon ?? PhosphorIcons.warning();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingXl,
          vertical: AppTheme.spacingXxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon circle
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.error.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 36,
                color: colorScheme.error.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: AppTheme.spacingXl),

            // Title
            if (title != null)
              Text(
                title!,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

            if (title != null) const SizedBox(height: AppTheme.spacingS),

            // Message
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),

            // Retry button
            if (onRetry != null) ...[
              const SizedBox(height: AppTheme.spacingXl),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: Icon(PhosphorIcons.arrowClockwise(), size: 18),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
