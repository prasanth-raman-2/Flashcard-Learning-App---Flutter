import 'package:flutter/material.dart';

// PUBLIC_INTERFACE
/// A circular progress indicator that shows overall study progress
class StudyProgressIndicator extends StatelessWidget {
  /// Creates a study progress indicator widget
  /// 
  /// [progress] should be a value between 0.0 and 1.0
  /// [size] determines the diameter of the circular indicator
  /// [color] overrides the theme's primary color for the progress indicator
  const StudyProgressIndicator({
    Key? key,
    required this.progress,
    this.size = 100.0,
    this.color,
    this.backgroundColor,
    this.label,
  }) : assert(progress >= 0.0 && progress <= 1.0),
       super(key: key);

  /// The progress value between 0.0 and 1.0
  final double progress;

  /// The size (diameter) of the circular indicator
  final double size;

  /// Optional color override for the progress indicator
  final Color? color;

  /// Optional background color for the unfilled portion
  final Color? backgroundColor;

  /// Optional label to display below the progress indicator
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = color ?? theme.primaryColor;
    final bgColor = backgroundColor ?? theme.colorScheme.surfaceVariant;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: progress),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: value,
                    backgroundColor: bgColor,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    strokeWidth: size * 0.1,
                  ),
                  Center(
                    child: Text(
                      '${(value * 100).toInt()}%',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 8),
          Text(
            label!,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}import 'package:flutter/material.dart';

// PUBLIC_INTERFACE
/// A circular progress indicator that shows overall study progress
class StudyProgressIndicator extends StatelessWidget {
  /// Creates a study progress indicator widget
  /// 
  /// [progress] should be a value between 0.0 and 1.0
  /// [size] determines the diameter of the circular indicator
  /// [color] overrides the theme's primary color for the progress indicator
  const StudyProgressIndicator({
    Key? key,
    required this.progress,
    this.size = 100.0,
    this.color,
    this.backgroundColor,
    this.label,
  }) : assert(progress >= 0.0 && progress <= 1.0),
       super(key: key);

  /// The progress value between 0.0 and 1.0
  final double progress;

  /// The size (diameter) of the circular indicator
  final double size;

  /// Optional color override for the progress indicator
  final Color? color;

  /// Optional background color for the unfilled portion
  final Color? backgroundColor;

  /// Optional label to display below the progress indicator
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = color ?? theme.primaryColor;
    final bgColor = backgroundColor ?? theme.colorScheme.surfaceVariant;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: progress),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: value,
                    backgroundColor: bgColor,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    strokeWidth: size * 0.1,
                  ),
                  Center(
                    child: Text(
                      '${(value * 100).toInt()}%',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 8),
          Text(
            label!,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
