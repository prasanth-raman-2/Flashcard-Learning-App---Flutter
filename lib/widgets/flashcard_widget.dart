import 'dart:math';
import 'package:flutter/material.dart';
import '../models/flashcard.dart';

// PUBLIC_INTERFACE
/// A widget that displays a flashcard with flip animation.
/// 
/// This widget takes a [Flashcard] model and displays its content with a flip animation
/// that reveals the answer when tapped. It supports both light and dark themes and
/// can be sized according to the parent widget's constraints.
class FlashcardWidget extends StatefulWidget {
  /// Creates a new FlashcardWidget.
  /// 
  /// Parameters:
  /// - [flashcard]: The flashcard model containing the content to display
  /// - [onFlip]: Optional callback that is called when the card is flipped
  /// - [size]: Optional size constraint for the card. If not provided, the card will
  ///   size itself according to its parent's constraints
  const FlashcardWidget({
    Key? key,
    required this.flashcard,
    this.onFlip,
    this.size,
  }) : super(key: key);

  /// The flashcard model containing the content to display
  final Flashcard flashcard;

  /// Callback that is called when the card is flipped
  final VoidCallback? onFlip;

  /// Optional size constraint for the card
  final Size? size;

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showingAnswer = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -pi / 2)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: pi / 2, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50.0,
      ),
    ]).animate(_controller);

    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_controller.isAnimating) return;
    
    widget.onFlip?.call();
    setState(() => _showingAnswer = !_showingAnswer);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardSize = widget.size ?? const Size(300, 200);

    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Perspective
            ..rotateY(_animation.value);

          return Container(
            constraints: BoxConstraints.tight(cardSize),
            child: Transform(
              transform: transform,
              alignment: Alignment.center,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.surface,
                        theme.colorScheme.surface.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _showingAnswer ? 'Answer' : 'Question',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Center(
                          child: Text(
                            _showingAnswer
                                ? widget.flashcard.answer
                                : widget.flashcard.content,
                            style: theme.textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      if (!_showingAnswer) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Tap to reveal answer',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}