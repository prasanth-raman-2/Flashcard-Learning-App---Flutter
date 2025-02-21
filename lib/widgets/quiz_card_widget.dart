import 'package:flutter/material.dart';
import '../models/flashcard.dart';

// PUBLIC_INTERFACE
/// A widget that displays a quiz card with multiple choice options and provides
/// feedback on user answers.
///
/// This widget supports:
/// - Multiple choice answer display
/// - Answer selection handling
/// - Immediate feedback visualization
/// - Score tracking
/// - Theme-aware styling
/// - Accessibility support
class QuizCardWidget extends StatefulWidget {
  /// Creates a quiz card widget.
  ///
  /// [flashcard] contains the question and correct answer
  /// [options] is a list of possible answers including the correct one
  /// [onAnswerSelected] callback is triggered when user selects an answer
  /// [onScoreUpdated] callback is triggered when the score changes
  const QuizCardWidget({
    Key? key,
    required this.flashcard,
    required this.options,
    required this.onAnswerSelected,
    required this.onScoreUpdated,
  }) : super(key: key);

  /// The flashcard containing the question and correct answer
  final Flashcard flashcard;

  /// List of possible answers including the correct one
  final List<String> options;

  /// Callback function when an answer is selected
  final void Function(bool isCorrect) onAnswerSelected;

  /// Callback function when the score is updated
  final void Function(int newScore) onScoreUpdated;

  @override
  State<QuizCardWidget> createState() => _QuizCardWidgetState();
}

class _QuizCardWidgetState extends State<QuizCardWidget> {
  String? _selectedAnswer;
  bool? _isCorrect;
  int _score = 0;

  void _handleAnswerSelection(String answer) {
    if (_selectedAnswer != null) return; // Prevent multiple selections

    setState(() {
      _selectedAnswer = answer;
      _isCorrect = answer == widget.flashcard.answer;
      if (_isCorrect!) {
        _score++;
        widget.onScoreUpdated(_score);
      }
    });

    widget.onAnswerSelected(_isCorrect!);
  }

  Color _getOptionColor(String option) {
    if (_selectedAnswer == null) return Colors.white;
    if (_selectedAnswer == option) {
      return _isCorrect! ? Colors.green.shade100 : Colors.red.shade100;
    }
    if (option == widget.flashcard.answer && _selectedAnswer != null) {
      return Colors.green.shade100;
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.flashcard.title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
              semanticsLabel: 'Question title: ${widget.flashcard.title}',
            ),
            const SizedBox(height: 16),
            Text(
              widget.flashcard.content,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
              semanticsLabel: 'Question: ${widget.flashcard.content}',
            ),
            const SizedBox(height: 24),
            ...widget.options.map((option) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ElevatedButton(
                    onPressed: _selectedAnswer == null
                        ? () => _handleAnswerSelection(option)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getOptionColor(option),
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      option,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )),
            if (_selectedAnswer != null) ...[
              const SizedBox(height: 16),
              Text(
                _isCorrect! ? 'Correct!' : 'Incorrect. Try again!',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: _isCorrect! ? Colors.green : Colors.red,
                ),
                textAlign: TextAlign.center,
                semanticsLabel: _isCorrect!
                    ? 'Answer is correct'
                    : 'Answer is incorrect. The correct answer is: ${widget.flashcard.answer}',
              ),
              const SizedBox(height: 8),
              Text(
                'Score: $_score',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
                semanticsLabel: 'Current score: $_score',
              ),
            ],
          ],
        ),
      ),
    );
  }
}