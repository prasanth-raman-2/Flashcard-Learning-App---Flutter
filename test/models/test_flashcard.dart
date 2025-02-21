import 'package:flutter_test/flutter_test.dart';
import 'package:flash_card/models/flashcard.dart';

void main() {
  group('Flashcard Model Tests', () {
    final testDate = DateTime(2023, 1, 1);
    final testFlashcard = Flashcard(
      id: 'test-id',
      title: 'Test Title',
      content: 'Test Content',
      answer: 'Test Answer',
      userId: 'test-user-id',
      tags: ['tag1', 'tag2'],
      difficultyLevel: 3,
      reviewCount: 5,
      createdAt: testDate,
      updatedAt: testDate,
    );

    test('constructor creates valid instance', () {
      expect(testFlashcard.id, equals('test-id'));
      expect(testFlashcard.title, equals('Test Title'));
      expect(testFlashcard.content, equals('Test Content'));
      expect(testFlashcard.answer, equals('Test Answer'));
      expect(testFlashcard.userId, equals('test-user-id'));
      expect(testFlashcard.tags, equals(['tag1', 'tag2']));
      expect(testFlashcard.difficultyLevel, equals(3));
      expect(testFlashcard.reviewCount, equals(5));
      expect(testFlashcard.createdAt, equals(testDate));
      expect(testFlashcard.updatedAt, equals(testDate));
    });

    test('constructor sets default values correctly', () {
      final defaultFlashcard = Flashcard(
        id: 'test-id',
        title: 'Test Title',
        content: 'Test Content',
        answer: 'Test Answer',
        userId: 'test-user-id',
      );

      expect(defaultFlashcard.tags, isEmpty);
      expect(defaultFlashcard.difficultyLevel, equals(1));
      expect(defaultFlashcard.reviewCount, equals(0));
      expect(defaultFlashcard.createdAt, isNotNull);
      expect(defaultFlashcard.updatedAt, isNotNull);
    });

    test('constructor validates difficulty level', () {
      expect(
        () => Flashcard(
          id: 'test-id',
          title: 'Test Title',
          content: 'Test Content',
          answer: 'Test Answer',
          userId: 'test-user-id',
          difficultyLevel: 0,
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => Flashcard(
          id: 'test-id',
          title: 'Test Title',
          content: 'Test Content',
          answer: 'Test Answer',
          userId: 'test-user-id',
          difficultyLevel: 6,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('fromJson creates correct instance', () {
      final json = {
        'id': 'test-id',
        'title': 'Test Title',
        'content': 'Test Content',
        'answer': 'Test Answer',
        'user_id': 'test-user-id',
        'tags': ['tag1', 'tag2'],
        'difficulty_level': 3,
        'review_count': 5,
        'created_at': Timestamp.fromDate(testDate),
        'updated_at': Timestamp.fromDate(testDate),
      };

      final flashcard = Flashcard.fromJson(json);
      expect(flashcard, equals(testFlashcard));
    });

    test('toJson creates correct map', () {
      final json = testFlashcard.toJson();
      expect(json['id'], equals('test-id'));
      expect(json['title'], equals('Test Title'));
      expect(json['content'], equals('Test Content'));
      expect(json['answer'], equals('Test Answer'));
      expect(json['user_id'], equals('test-user-id'));
      expect(json['tags'], equals(['tag1', 'tag2']));
      expect(json['difficulty_level'], equals(3));
      expect(json['review_count'], equals(5));
      expect(json['created_at'], equals(Timestamp.fromDate(testDate)));
      expect(json['updated_at'], equals(Timestamp.fromDate(testDate)));
    });

    test('copyWith creates new instance with updated values', () {
      final updatedFlashcard = testFlashcard.copyWith(
        title: 'New Title',
        content: 'New Content',
        tags: ['new-tag'],
      );

      expect(updatedFlashcard.id, equals(testFlashcard.id));
      expect(updatedFlashcard.title, equals('New Title'));
      expect(updatedFlashcard.content, equals('New Content'));
      expect(updatedFlashcard.tags, equals(['new-tag']));
      expect(updatedFlashcard.answer, equals(testFlashcard.answer));
      expect(updatedFlashcard.userId, equals(testFlashcard.userId));
      expect(updatedFlashcard.difficultyLevel, equals(testFlashcard.difficultyLevel));
      expect(updatedFlashcard.reviewCount, equals(testFlashcard.reviewCount));
    });

    test('equality comparison works correctly', () {
      final sameFlashcard = Flashcard(
        id: 'test-id',
        title: 'Test Title',
        content: 'Test Content',
        answer: 'Test Answer',
        userId: 'test-user-id',
        tags: ['tag1', 'tag2'],
        difficultyLevel: 3,
        reviewCount: 5,
        createdAt: testDate,
        updatedAt: testDate,
      );

      final differentFlashcard = Flashcard(
        id: 'different-id',
        title: 'Different Title',
        content: 'Different Content',
        answer: 'Different Answer',
        userId: 'different-user-id',
      );

      expect(testFlashcard, equals(sameFlashcard));
      expect(testFlashcard, isNot(equals(differentFlashcard)));
    });

    test('hashCode is consistent', () {
      final sameFlashcard = Flashcard(
        id: 'test-id',
        title: 'Test Title',
        content: 'Test Content',
        answer: 'Test Answer',
        userId: 'test-user-id',
        tags: ['tag1', 'tag2'],
        difficultyLevel: 3,
        reviewCount: 5,
        createdAt: testDate,
        updatedAt: testDate,
      );

      expect(testFlashcard.hashCode, equals(sameFlashcard.hashCode));
    });
  });
}