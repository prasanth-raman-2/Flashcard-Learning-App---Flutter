// PUBLIC_INTERFACE
/// A model class representing a flashcard in the application.
/// 
/// This class includes all the necessary fields for a flashcard and provides
/// serialization support for Firebase Firestore.
class Flashcard {
  /// Creates a new Flashcard instance.
  Flashcard({
    required this.id,
    required this.title,
    required this.content,
    required this.answer,
    required this.userId,
    this.tags = const [],
    this.difficultyLevel = 1,
    this.reviewCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : assert(difficultyLevel >= 1 && difficultyLevel <= 5),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Unique identifier for the flashcard
  final String id;

  /// Title of the flashcard
  final String title;

  /// Main content or question of the flashcard
  final String content;

  /// Answer or explanation for the flashcard
  final String answer;

  /// Creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime updatedAt;

  /// ID of the user who created this flashcard
  final String userId;

  /// List of tags associated with this flashcard
  final List<String> tags;

  /// Difficulty level (1-5)
  final int difficultyLevel;

  /// Number of times this card has been reviewed
  final int reviewCount;

  /// Creates a Flashcard instance from a Firestore document
  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      answer: json['answer'] as String,
      userId: json['user_id'] as String,
      tags: List<String>.from(json['tags'] as List),
      difficultyLevel: json['difficulty_level'] as int,
      reviewCount: json['review_count'] as int,
      createdAt: (json['created_at'] as Timestamp).toDate(),
      updatedAt: (json['updated_at'] as Timestamp).toDate(),
    );
  }

  /// Converts the Flashcard instance to a JSON map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'answer': answer,
      'user_id': userId,
      'tags': tags,
      'difficulty_level': difficultyLevel,
      'review_count': reviewCount,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  /// Creates a copy of this Flashcard with the given fields replaced with new values
  Flashcard copyWith({
    String? id,
    String? title,
    String? content,
    String? answer,
    String? userId,
    List<String>? tags,
    int? difficultyLevel,
    int? reviewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Flashcard(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      answer: answer ?? this.answer,
      userId: userId ?? this.userId,
      tags: tags ?? this.tags,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Flashcard &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          content == other.content &&
          answer == other.answer &&
          userId == other.userId &&
          difficultyLevel == other.difficultyLevel &&
          reviewCount == other.reviewCount;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      content.hashCode ^
      answer.hashCode ^
      userId.hashCode ^
      difficultyLevel.hashCode ^
      reviewCount.hashCode;
}