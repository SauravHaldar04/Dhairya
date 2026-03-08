import 'package:aparna_education/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

enum ProfileType { parent, teacher, languagelearner }

/// A sleek profile-type selection card with icon + text.
class ProfileTypeWidget extends StatelessWidget {
  final bool isSelected;
  final ProfileType profileType;
  final String imageUrl;

  const ProfileTypeWidget({
    super.key,
    required this.profileType,
    required this.imageUrl,
    required this.isSelected,
  });

  String get _title {
    switch (profileType) {
      case ProfileType.teacher:
        return "I'm a Teacher";
      case ProfileType.parent:
        return "I'm a Parent";
      case ProfileType.languagelearner:
        return "I'm a Learner";
    }
  }

  String get _subtitle {
    switch (profileType) {
      case ProfileType.teacher:
        return 'Manage students, schedule lectures, and track progress.';
      case ProfileType.parent:
        return 'Enroll wards, monitor lectures, and stay connected.';
      case ProfileType.languagelearner:
        return 'Learn new languages with structured courses.';
    }
  }

  IconData get _icon {
    switch (profileType) {
      case ProfileType.teacher:
        return PhosphorIcons.chalkboardTeacher();
      case ProfileType.parent:
        return PhosphorIcons.users();
      case ProfileType.languagelearner:
        return PhosphorIcons.translate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primary.withOpacity(isDark ? 0.15 : 0.06)
            : isDark
                ? colorScheme.surface
                : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.outline.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary.withOpacity(0.15)
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(
              _icon,
              size: 28,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(width: 16),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Check indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? colorScheme.primary
                  : Colors.transparent,
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outline,
                width: isSelected ? 0 : 1.5,
              ),
            ),
            child: isSelected
                ? Icon(
                    PhosphorIcons.check(PhosphorIconsStyle.bold),
                    size: 14,
                    color: colorScheme.onPrimary,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
