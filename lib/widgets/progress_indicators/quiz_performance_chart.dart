import 'package:flutter/material.dart';

// PUBLIC_INTERFACE
/// A bar chart widget that displays quiz performance data
class QuizPerformanceChart extends StatelessWidget {
  /// Creates a quiz performance chart widget
  /// 
  /// [scores] is a list of quiz scores between 0.0 and 1.0
  /// [labels] is an optional list of labels for each score
  /// [height] is the height of the chart
  /// [barWidth] is the width of each bar in the chart
  const QuizPerformanceChart({
    Key? key,
    required this.scores,
    this.labels,
    this.height = 200.0,
    this.barWidth = 30.0,
    this.barColor,
    this.labelStyle,
  }) : assert(labels == null || labels.length == scores.length),
       super(key: key);

  /// List of quiz scores (values between 0.0 and 1.0)
  final List<double> scores;

  /// Optional labels for each score
  final List<String>? labels;

  /// Height of the chart
  final double height;

  /// Width of each bar in the chart
  final double barWidth;

  /// Optional color override for the bars
  final Color? barColor;

  /// Optional text style for labels
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = barColor ?? theme.primaryColor;
    final style = labelStyle ?? theme.textTheme.bodyMedium;

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: scores.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final score = scores[index];
          final label = labels?[index] ?? 'Quiz ${index + 1}';
          
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: barWidth,
                height: height * 0.8,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: score),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          width: barWidth,
                          height: height * 0.8,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        Container(
                          width: barWidth,
                          height: height * 0.8 * value,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: style,
                textAlign: TextAlign.center,
              ),
              Text(
                '${(scores[index] * 100).toInt()}%',
                style: style?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }
}