import 'package:flutter_test/flutter_test.dart';
import 'package:flash_card/models/user.dart';

void main() {
  group('User Model Tests', () {
    final testDate = DateTime(2023, 1, 1);
    final testPreferences = {'theme': 'dark', 'notifications': true};
    final testUser = User(
      id: 'test-id',
      email: 'test@example.com',
      displayName: 'Test User',
      photoUrl: 'https://example.com/photo.jpg',
      preferences: testPreferences,
      createdAt: testDate,
      lastLoginAt: testDate,
    );

    test('constructor creates valid instance', () {
      expect(testUser.id, equals('test-id'));
      expect(testUser.email, equals('test@example.com'));
      expect(testUser.displayName, equals('Test User'));
      expect(testUser.photoUrl, equals('https://example.com/photo.jpg'));
      expect(testUser.preferences, equals(testPreferences));
      expect(testUser.createdAt, equals(testDate));
      expect(testUser.lastLoginAt, equals(testDate));
    });

    test('constructor sets default values correctly', () {
      final defaultUser = User(
        id: 'test-id',
        email: 'test@example.com',
        displayName: 'Test User',
      );

      expect(defaultUser.photoUrl, isNull);
      expect(defaultUser.preferences, isEmpty);
      expect(defaultUser.createdAt, isNotNull);
      expect(defaultUser.lastLoginAt, isNotNull);
    });

    test('fromJson creates correct instance', () {
      final json = {
        'id': 'test-id',
        'email': 'test@example.com',
        'display_name': 'Test User',
        'photo_url': 'https://example.com/photo.jpg',
        'preferences': testPreferences,
        'created_at': Timestamp.fromDate(testDate),
        'last_login_at': Timestamp.fromDate(testDate),
      };

      final user = User.fromJson(json);
      expect(user, equals(testUser));
    });

    test('toJson creates correct map', () {
      final json = testUser.toJson();
      expect(json['id'], equals('test-id'));
      expect(json['email'], equals('test@example.com'));
      expect(json['display_name'], equals('Test User'));
      expect(json['photo_url'], equals('https://example.com/photo.jpg'));
      expect(json['preferences'], equals(testPreferences));
      expect(json['created_at'], equals(Timestamp.fromDate(testDate)));
      expect(json['last_login_at'], equals(Timestamp.fromDate(testDate)));
    });

    test('copyWith creates new instance with updated values', () {
      final updatedUser = testUser.copyWith(
        displayName: 'New Name',
        photoUrl: 'https://example.com/new-photo.jpg',
        preferences: {'theme': 'light'},
      );

      expect(updatedUser.id, equals(testUser.id));
      expect(updatedUser.email, equals(testUser.email));
      expect(updatedUser.displayName, equals('New Name'));
      expect(updatedUser.photoUrl, equals('https://example.com/new-photo.jpg'));
      expect(updatedUser.preferences, equals({'theme': 'light'}));
      expect(updatedUser.createdAt, equals(testUser.createdAt));
      expect(updatedUser.lastLoginAt, equals(testUser.lastLoginAt));
    });

    group('email validation', () {
      test('validates correct email formats', () {
        final validEmails = [
          'test@example.com',
          'user.name@domain.com',
          'user+tag@example.co.uk',
          'user123@subdomain.domain.org',
        ];

        for (final email in validEmails) {
          final user = User(
            id: 'test-id',
            email: email,
            displayName: 'Test User',
          );
          expect(user.isEmailValid(), isTrue, reason: 'Email $email should be valid');
        }
      });

      test('invalidates incorrect email formats', () {
        final invalidEmails = [
          'invalid.email',
          '@domain.com',
          'user@',
          'user@domain',
          'user.domain.com',
          '',
          ' ',
        ];

        for (final email in invalidEmails) {
          final user = User(
            id: 'test-id',
            email: email,
            displayName: 'Test User',
          );
          expect(user.isEmailValid(), isFalse, reason: 'Email $email should be invalid');
        }
      });
    });

    test('equality comparison works correctly', () {
      final sameUser = User(
        id: 'test-id',
        email: 'test@example.com',
        displayName: 'Test User',
        photoUrl: 'https://example.com/photo.jpg',
        preferences: testPreferences,
        createdAt: testDate,
        lastLoginAt: testDate,
      );

      final differentUser = User(
        id: 'different-id',
        email: 'different@example.com',
        displayName: 'Different User',
      );

      expect(testUser, equals(sameUser));
      expect(testUser, isNot(equals(differentUser)));
    });

    test('hashCode is consistent', () {
      final sameUser = User(
        id: 'test-id',
        email: 'test@example.com',
        displayName: 'Test User',
        photoUrl: 'https://example.com/photo.jpg',
        preferences: testPreferences,
        createdAt: testDate,
        lastLoginAt: testDate,
      );

      expect(testUser.hashCode, equals(sameUser.hashCode));
    });
  });
}