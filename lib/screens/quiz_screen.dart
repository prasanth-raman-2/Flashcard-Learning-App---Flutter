import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/quiz_card_widget.dart';
import '../widgets/progress_indicators/quiz_performance_chart.dart';
import '../models/flashcard.dart';

// PUBLIC_INTERFACE
class QuizScreen extends StatefulWidget {
  final List<Flashcard> flashcards;
  final String deckName;

  /// A screen that manages quiz flow and tracks user performance
  /// 
  /// Parameters:
  /// - [flashcards]: List of flashcards for the quiz
  /// - [deckName]: Name of the flashcard deck being quizzed
  const QuizScreen({
    Key? key,
    required this.flashcards,
    required this.deckName,
  }) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _correctAnswers = 0;
  List<bool> _answers = [];
  final Stopwatch _quizTimer = Stopwatch();
  bool _isQuizComplete = false;

  @override
  void initState() {
    super.initState();
    _quizTimer.start();
    _answers = List.filled(widget.flashcards.length, false);
  }

  @override
  void dispose() {
    _quizTimer.stop();
    super.dispose();
  }

  void _handleAnswer(bool isCorrect) {
    setState(() {
      _answers[_currentIndex] = isCorrect;
      if (isCorrect) _correctAnswers++;

      if (_currentIndex < widget.flashcards.length - 1) {
        _currentIndex++;
      } else {
        _isQuizComplete = true;
        _quizTimer.stop();
      }
    });
  }

  void _retryQuiz() {
    setState(() {
      _currentIndex = 0;
      _correctAnswers = 0;
      _answers = List.filled(widget.flashcards.length, false);
      _isQuizComplete = false;
      _quizTimer
        ..reset()
        ..start();
    });
  }

  void _shareResults() {
    final duration = _quizTimer.elapsed;
    final score = (_correctAnswers / widget.flashcards.length * 100).toStringAsFixed(1);
    final message = 'I scored $score% on ${widget.deckName} quiz in ${duration.inMinutes}m ${duration.inSeconds % 60}s!';
    Share.share(message);
  }

  Widget _buildQuizContent() {
    if (_isQuizComplete) {
      return _buildResultsView();
    }

    return Column(
      children: [
        LinearProgressIndicator(
          value: (_currentIndex + 1) / widget.flashcards.length,
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
        const SizedBox(height: 16),
        Text(
          'Question ${_currentIndex + 1}/${widget.flashcards.length}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        QuizCardWidget(
          flashcard: widget.flashcards[_currentIndex],
          onAnswer: _handleAnswer,
        ),
      ],
    );
  }

  Widget _buildResultsView() {
    final score = (_correctAnswers / widget.flashcards.length * 100).toStringAsFixed(1);
    final duration = _quizTimer.elapsed;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Quiz Complete!',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),
        Text(
          'Score: $score%',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          'Time: ${duration.inMinutes}m ${duration.inSeconds % 60}s',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 32),
        QuizPerformanceChart(
          correctAnswers: _correctAnswers,
          totalQuestions: widget.flashcards.length,
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: _retryQuiz,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry Quiz'),
            ),
            ElevatedButton.icon(
              onPressed: _shareResults,
              icon: const Icon(Icons.share),
              label: const Text('Share Results'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deckName),
        actions: [
          if (_isQuizComplete)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareResults,
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildQuizContent(),
        ),
      ),
    );
  }
}