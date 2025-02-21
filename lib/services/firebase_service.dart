import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/flashcard.dart';
import '../models/user.dart';

// PUBLIC_INTERFACE
/// Service class for handling Firebase Firestore operations.
/// 
/// This class provides CRUD operations for flashcards and user data,
/// including real-time data synchronization and error handling.
class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  // Collection references
  final CollectionReference _flashcardsCollection;
  final CollectionReference _usersCollection;

  FirebaseService()
      : _flashcardsCollection = FirebaseFirestore.instance.collection('flashcards'),
        _usersCollection = FirebaseFirestore.instance.collection('users');

  // Flashcard CRUD Operations

  /// Creates a new flashcard in Firestore.
  /// 
  /// Returns the created [Flashcard] object.
  /// Throws a [FirebaseException] if the operation fails after retries.
  Future<Flashcard> createFlashcard(Flashcard flashcard) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        final docRef = await _flashcardsCollection.add(flashcard.toJson());
        final newFlashcard = flashcard.copyWith(id: docRef.id);
        await docRef.update({'id': docRef.id});
        return newFlashcard;
      } on FirebaseException catch (e) {
        attempts++;
        if (attempts >= maxRetries) rethrow;
        await Future.delayed(retryDelay * attempts);
      }
    }
    throw FirebaseException(
      plugin: 'cloud_firestore',
      message: 'Failed to create flashcard after $maxRetries attempts',
    );
  }

  /// Retrieves a flashcard by its ID.
  /// 
  /// Returns null if the flashcard doesn't exist.
  /// Throws a [FirebaseException] if the operation fails after retries.
  Future<Flashcard?> getFlashcard(String id) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        final doc = await _flashcardsCollection.doc(id).get();
        if (!doc.exists) return null;
        return Flashcard.fromJson(doc.data() as Map<String, dynamic>);
      } on FirebaseException catch (e) {
        attempts++;
        if (attempts >= maxRetries) rethrow;
        await Future.delayed(retryDelay * attempts);
      }
    }
    throw FirebaseException(
      plugin: 'cloud_firestore',
      message: 'Failed to get flashcard after $maxRetries attempts',
    );
  }

  /// Updates an existing flashcard.
  /// 
  /// Returns the updated [Flashcard] object.
  /// Throws a [FirebaseException] if the operation fails after retries.
  Future<Flashcard> updateFlashcard(Flashcard flashcard) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        await _flashcardsCollection
            .doc(flashcard.id)
            .update(flashcard.toJson());
        return flashcard;
      } on FirebaseException catch (e) {
        attempts++;
        if (attempts >= maxRetries) rethrow;
        await Future.delayed(retryDelay * attempts);
      }
    }
    throw FirebaseException(
      plugin: 'cloud_firestore',
      message: 'Failed to update flashcard after $maxRetries attempts',
    );
  }

  /// Deletes a flashcard by its ID.
  /// 
  /// Throws a [FirebaseException] if the operation fails after retries.
  Future<void> deleteFlashcard(String id) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        await _flashcardsCollection.doc(id).delete();
        return;
      } on FirebaseException catch (e) {
        attempts++;
        if (attempts >= maxRetries) rethrow;
        await Future.delayed(retryDelay * attempts);
      }
    }
    throw FirebaseException(
      plugin: 'cloud_firestore',
      message: 'Failed to delete flashcard after $maxRetries attempts',
    );
  }

  /// Retrieves all flashcards for a specific user.
  /// 
  /// Returns a stream of [List<Flashcard>] for real-time updates.
  Stream<List<Flashcard>> getUserFlashcards(String userId) {
    return _flashcardsCollection
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Flashcard.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // User CRUD Operations

  /// Creates a new user in Firestore.
  /// 
  /// Returns the created [User] object.
  /// Throws a [FirebaseException] if the operation fails after retries.
  Future<User> createUser(User user) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        await _usersCollection.doc(user.id).set(user.toJson());
        return user;
      } on FirebaseException catch (e) {
        attempts++;
        if (attempts >= maxRetries) rethrow;
        await Future.delayed(retryDelay * attempts);
      }
    }
    throw FirebaseException(
      plugin: 'cloud_firestore',
      message: 'Failed to create user after $maxRetries attempts',
    );
  }

  /// Retrieves a user by their ID.
  /// 
  /// Returns null if the user doesn't exist.
  /// Throws a [FirebaseException] if the operation fails after retries.
  Future<User?> getUser(String id) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        final doc = await _usersCollection.doc(id).get();
        if (!doc.exists) return null;
        return User.fromJson(doc.data() as Map<String, dynamic>);
      } on FirebaseException catch (e) {
        attempts++;
        if (attempts >= maxRetries) rethrow;
        await Future.delayed(retryDelay * attempts);
      }
    }
    throw FirebaseException(
      plugin: 'cloud_firestore',
      message: 'Failed to get user after $maxRetries attempts',
    );
  }

  /// Updates an existing user.
  /// 
  /// Returns the updated [User] object.
  /// Throws a [FirebaseException] if the operation fails after retries.
  Future<User> updateUser(User user) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        await _usersCollection.doc(user.id).update(user.toJson());
        return user;
      } on FirebaseException catch (e) {
        attempts++;
        if (attempts >= maxRetries) rethrow;
        await Future.delayed(retryDelay * attempts);
      }
    }
    throw FirebaseException(
      plugin: 'cloud_firestore',
      message: 'Failed to update user after $maxRetries attempts',
    );
  }

  /// Deletes a user by their ID.
  /// 
  /// Throws a [FirebaseException] if the operation fails after retries.
  Future<void> deleteUser(String id) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        // Delete all user's flashcards first
        final flashcards = await _flashcardsCollection
            .where('user_id', isEqualTo: id)
            .get();
        
        final batch = _firestore.batch();
        for (var doc in flashcards.docs) {
          batch.delete(doc.reference);
        }
        batch.delete(_usersCollection.doc(id));
        
        await batch.commit();
        return;
      } on FirebaseException catch (e) {
        attempts++;
        if (attempts >= maxRetries) rethrow;
        await Future.delayed(retryDelay * attempts);
      }
    }
    throw FirebaseException(
      plugin: 'cloud_firestore',
      message: 'Failed to delete user after $maxRetries attempts',
    );
  }

  /// Retrieves user data as a stream for real-time updates.
  /// 
  /// Returns a stream of [User] that updates whenever the user data changes.
  Stream<User?> getUserStream(String id) {
    return _usersCollection
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists
            ? User.fromJson(doc.data() as Map<String, dynamic>)
            : null);
  }
}