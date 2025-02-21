import 'package:flutter/material.dart';

// PUBLIC_INTERFACE
/// A widget that displays the user's study streak (consecutive days of study)
class StudyStreakIndicator extends StatelessWidget {
  /// Creates a study streak indicator widget
  /// 
  /// [streakCount] is the number of consecutive days studied
  /// [size] determines the size of the indicator
  const StudyStreakIndicator({
    Key? key,
    required this.streakCount,
    this.size = 120.0,
    this.color,
    this.backgroundColor,
  }) : super(key: key);

  /// The number of consecutive days studied
  final int streakCount;

  /// The size of the indicator
  final double size;

  /// Optional color override for the flame icon and text
  final Color? color;

  /// Optional background color for the indicator
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final streakColor = color ?? theme.primaryColor;
    final bgColor = backgroundColor ?? theme.colorScheme.surfaceVariant;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: streakColor.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1500),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_fire_department,
              color: streakColor,
              size: size * 0.4,
            ),
            const SizedBox(height: 4),
            Text(
              '$streakCount',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: streakColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Day${streakCount == 1 ? '' : 's'}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: streakColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}