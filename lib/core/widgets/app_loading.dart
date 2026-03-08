import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:aparna_education/core/theme/app_theme.dart';

/// Standardised loading indicators.
///
/// ```dart
/// // Spinner only
/// AppLoading()
///
/// // Spinner + message
/// AppLoading(message: 'Fetching lectures…')
///
/// // Full-screen overlay
/// AppLoading.fullScreen()
///
/// // Shimmer placeholder list
/// AppLoading.shimmerList(itemCount: 5)
/// ```
class AppLoading extends StatelessWidget {
  final String? message;
  final double size;

  const AppLoading({
    super.key,
    this.message,
    this.size = 36,
  });

  /// Full-screen centered loader with an optional overlay tint.
  static Widget fullScreen({String? message}) {
    return Scaffold(
      body: Center(
        child: AppLoading(message: message),
      ),
    );
  }

  /// Simple centered loader (no Scaffold).
  static Widget centered({String? message}) {
    return Center(child: AppLoading(message: message));
  }

  /// A shimmering list that mimics real content while loading.
  static Widget shimmerList({
    int itemCount = 4,
    double itemHeight = 80,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  }) {
    return _ShimmerList(
      itemCount: itemCount,
      itemHeight: itemHeight,
      padding: padding,
    );
  }

  /// A shimmering card placeholder.
  static Widget shimmerCard({
    double height = 120,
    double? width,
    EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  }) {
    return _ShimmerCard(height: height, width: width, margin: margin);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            strokeCap: StrokeCap.round,
            color: colorScheme.primary,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//  Shimmer List
// ──────────────────────────────────────────────────────────────────
class _ShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsets padding;

  const _ShimmerList({
    required this.itemCount,
    required this.itemHeight,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2A2D4A) : Colors.grey.shade200,
      highlightColor: isDark ? const Color(0xFF363A5C) : Colors.grey.shade50,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: padding,
        itemCount: itemCount,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: itemHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//  Shimmer Card
// ──────────────────────────────────────────────────────────────────
class _ShimmerCard extends StatelessWidget {
  final double height;
  final double? width;
  final EdgeInsets margin;

  const _ShimmerCard({
    required this.height,
    this.width,
    required this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2A2D4A) : Colors.grey.shade200,
      highlightColor: isDark ? const Color(0xFF363A5C) : Colors.grey.shade50,
      child: Container(
        height: height,
        width: width,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
      ),
    );
  }
}
