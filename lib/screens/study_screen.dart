import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/flashcard.dart';
import '../widgets/flashcard_widget.dart';
import '../widgets/progress_indicators/study_progress_indicator.dart';
import '../widgets/progress_indicators/study_streak_indicator.dart';

// PUBLIC_INTERFACE
/// A screen that manages the study session with spaced repetition functionality.
/// 
/// This screen provides:
/// - Flashcard display and interaction
/// - Study progress tracking
/// - Spaced repetition algorithm implementation
/// - Session timer and streak tracking
/// - Performance metrics
/// - Session persistence
class StudyScreen extends StatefulWidget {
  /// Creates a new StudyScreen.
  /// 
  /// Parameters:
  /// - [flashcards]: List of flashcards to study
  /// - [onSessionComplete]: Callback when the study session is completed
  const StudyScreen({
    Key? key,
    required this.flashcards,
    this.onSessionComplete,
  }) : super(key: key);

  /// The list of flashcards to study
  final List<Flashcard> flashcards;

  /// Callback when the study session is completed
  final VoidCallback? onSessionComplete;

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  late List<Flashcard> _studyQueue;
  late Timer _sessionTimer;
  int _currentIndex = 0;
  int _correctAnswers = 0;
  int _totalAnswered = 0;
  Duration _sessionDuration = Duration.zero;
  bool _isSessionActive = false;

  // Spaced repetition parameters
  final Map<String, int> _cardIntervals = {};
  final Map<String, DateTime> _nextReviewDates = {};

  @override
  void initState() {
    super.initState();
    _initializeStudySession();
    _startSessionTimer();
  }

  @override
  void dispose() {
    _sessionTimer.cancel();
    _saveSessionProgress();
    super.dispose();
  }

  void _initializeStudySession() {
    // Initialize study queue with spaced repetition ordering
    _studyQueue = List.from(widget.flashcards);
    _studyQueue.sort((a, b) {
      final aNextReview = _nextReviewDates[a.id] ?? DateTime.now();
      final bNextReview = _nextReviewDates[b.id] ?? DateTime.now();
      return aNextReview.compareTo(bNextReview);
    });
    _isSessionActive = true;
  }

  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (_isSessionActive) {
          setState(() {
            _sessionDuration += const Duration(seconds: 1);
          });
        }
      },
    );
  }

  Future<void> _saveSessionProgress() async {
    // Save progress to Firebase
    try {
      final batch = FirebaseFirestore.instance.batch();
      
      for (final card in widget.flashcards) {
        final cardRef = FirebaseFirestore.instance.collection('flashcards').doc(card.id);
        batch.update(cardRef, {
          'review_count': card.reviewCount + 1,
          'next_review': _nextReviewDates[card.id],
          'last_studied': DateTime.now(),
        });
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error saving session progress: $e');
    }
  }

  void _updateSpacedRepetition(String cardId, bool wasCorrect) {
    final currentInterval = _cardIntervals[cardId] ?? 1;
    
    // Calculate new interval using SuperMemo-2 algorithm
    int newInterval;
    if (wasCorrect) {
      newInterval = (currentInterval * 2.5).round();
    } else {
      newInterval = (currentInterval * 0.4).round();
    }
    
    // Ensure minimum interval of 1 day
    newInterval = newInterval.clamp(1, 365);
    
    _cardIntervals[cardId] = newInterval;
    _nextReviewDates[cardId] = DateTime.now().add(Duration(days: newInterval));
  }

  void _handleAnswer(bool wasCorrect) {
    if (!_isSessionActive) return;

    setState(() {
      if (wasCorrect) _correctAnswers++;
      _totalAnswered++;
      
      final currentCard = _studyQueue[_currentIndex];
      _updateSpacedRepetition(currentCard.id, wasCorrect);

      if (_currentIndex < _studyQueue.length - 1) {
        _currentIndex++;
      } else {
        _completeSession();
      }
    });
  }

  void _completeSession() {
    setState(() {
      _isSessionActive = false;
    });
    _saveSessionProgress();
    widget.onSessionComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (!_isSessionActive) {
      return _buildSummaryView(theme);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Session'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                _formatDuration(_sessionDuration),
                style: theme.textTheme.titleMedium,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StudyProgressIndicator(
                    progress: _totalAnswered / widget.flashcards.length,
                    size: 60,
                    label: 'Progress',
                  ),
                  Text(
                    '$_correctAnswers / $_totalAnswered',
                    style: theme.textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FlashcardWidget(
                  flashcard: _studyQueue[_currentIndex],
                  onFlip: () {
                    // Card was flipped, wait for rating
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAnswerButton(
                    context,
                    icon: Icons.close,
                    color: Colors.red,
                    onPressed: () => _handleAnswer(false),
                  ),
                  _buildAnswerButton(
                    context,
                    icon: Icons.check,
                    color: Colors.green,
                    onPressed: () => _handleAnswer(true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.all(16),
        shape: const CircleBorder(),
      ),
      child: Icon(icon, size: 32, color: Colors.white),
    );
  }

  Widget _buildSummaryView(ThemeData theme) {
    final accuracy = _totalAnswered > 0 
        ? (_correctAnswers / _totalAnswered * 100).round()
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Complete'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.celebration,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Great job!',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 32),
              _buildSummaryCard(
                theme,
                title: 'Session Duration',
                value: _formatDuration(_sessionDuration),
              ),
              const SizedBox(height: 16),
              _buildSummaryCard(
                theme,
                title: 'Cards Reviewed',
                value: '$_totalAnswered',
              ),
              const SizedBox(height: 16),
              _buildSummaryCard(
                theme,
                title: 'Accuracy',
                value: '$accuracy%',
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Return to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    ThemeData theme, {
    required String title,
    required String value,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}