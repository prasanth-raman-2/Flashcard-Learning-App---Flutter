import 'package:flutter/material.dart';
import '../widgets/flashcard_widget.dart';
import '../widgets/progress_indicators/study_progress_indicator.dart';
import '../widgets/progress_indicators/quiz_performance_chart.dart';
import '../widgets/progress_indicators/study_streak_indicator.dart';
import '../models/flashcard.dart';

// PUBLIC_INTERFACE
/// The main home screen of the application that serves as a dashboard
/// displaying various study metrics and quick actions.
class HomeScreen extends StatelessWidget {
  /// Creates a home screen widget
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // TODO: Replace with actual data from state management
    final sampleFlashcards = [
      Flashcard(
        id: '1',
        content: 'What is Flutter?',
        answer: 'Flutter is Google\'s UI toolkit for building natively compiled applications.',
        category: 'Technology',
        lastReviewed: DateTime.now(),
        nextReview: DateTime.now().add(const Duration(days: 1)),
      ),
      // Add more sample flashcards as needed
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // TODO: Navigate to profile screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Study Progress',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Center(
                child: StudyProgressIndicator(
                  progress: 0.75, // TODO: Get actual progress
                  size: 150,
                  label: 'Overall Progress',
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Recent Flashcards',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: sampleFlashcards.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: FlashcardWidget(
                        flashcard: sampleFlashcards[index],
                        size: const Size(300, 200),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Quick Actions',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _QuickActionCard(
                    icon: Icons.book,
                    label: 'Study',
                    color: theme.colorScheme.primary,
                    onTap: () {
                      // TODO: Navigate to study screen
                    },
                  ),
                  _QuickActionCard(
                    icon: Icons.quiz,
                    label: 'Quiz',
                    color: theme.colorScheme.secondary,
                    onTap: () {
                      // TODO: Navigate to quiz screen
                    },
                  ),
                  _QuickActionCard(
                    icon: Icons.add,
                    label: 'Create',
                    color: theme.colorScheme.tertiary,
                    onTap: () {
                      // TODO: Navigate to create flashcard screen
                    },
                  ),
                  _QuickActionCard(
                    icon: Icons.refresh,
                    label: 'Review',
                    color: theme.colorScheme.error,
                    onTap: () {
                      // TODO: Navigate to review screen
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Performance',
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        const QuizPerformanceChart(
                          scores: [0.8, 0.9, 0.75, 0.95, 0.85], // TODO: Get actual scores
                          height: 150,
                          barWidth: 40,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Column(
                    children: [
                      Text(
                        'Study Streak',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      const StudyStreakIndicator(
                        streakCount: 7, // TODO: Get actual streak
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A card widget used for quick actions in the dashboard
class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                color.withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}