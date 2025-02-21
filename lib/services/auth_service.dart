import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/user.dart';

// PUBLIC_INTERFACE
/// Service class for handling authentication operations using Firebase Auth.
/// 
/// This service provides methods for:
/// - Email/password authentication
/// - Google Sign-in
/// - Password reset
/// - User management
/// - Authentication state monitoring
class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StreamController<User?> _userController = StreamController<User?>.broadcast();

  /// Stream of the current authenticated user
  Stream<User?> get user => _userController.stream;

  AuthService() {
    // Listen to Firebase auth state changes and update the user stream
    _auth.authStateChanges().listen((firebase_auth.User? firebaseUser) async {
      if (firebaseUser != null) {
        final user = await _getUserFromFirestore(firebaseUser.uid);
        _userController.add(user);
      } else {
        _userController.add(null);
      }
    });
  }

  /// Sign in with email and password
  /// 
  /// Returns the signed-in user if successful.
  /// Throws a [FirebaseAuthException] if sign-in fails.
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Sign in failed: No user returned');
      }

      final user = await _getUserFromFirestore(userCredential.user!.uid);
      await _updateLastLoginTime(user);
      return user;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Create a new account with email and password
  /// 
  /// Returns the newly created user if successful.
  /// Throws a [FirebaseAuthException] if sign-up fails.
  Future<User> signUpWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Sign up failed: No user created');
      }

      final user = User(
        id: userCredential.user!.uid,
        email: email,
        displayName: displayName,
        photoUrl: null,
      );

      await _saveUserToFirestore(user);
      return user;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Sign in with Google
  /// 
  /// Returns the signed-in user if successful.
  /// Throws an exception if sign-in fails.
  Future<User> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in cancelled by user');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user == null) {
        throw Exception('Google sign in failed: No user returned');
      }

      User? user = await _getUserFromFirestore(userCredential.user!.uid);
      if (user == null) {
        // Create new user if first time signing in with Google
        user = User(
          id: userCredential.user!.uid,
          email: userCredential.user!.email!,
          displayName: userCredential.user!.displayName ?? 'User',
          photoUrl: userCredential.user!.photoURL,
        );
        await _saveUserToFirestore(user);
      } else {
        await _updateLastLoginTime(user);
      }

      return user;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Send password reset email
  /// 
  /// Throws a [FirebaseAuthException] if the operation fails.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Update user profile
  /// 
  /// Returns the updated user if successful.
  /// Throws an exception if the update fails.
  Future<User> updateProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final user = await _getUserFromFirestore(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      final updatedUser = user.copyWith(
        displayName: displayName,
        photoUrl: photoUrl,
        preferences: preferences,
      );

      await _saveUserToFirestore(updatedUser);
      return updatedUser;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Delete the current user account
  /// 
  /// This will delete both the Firebase Auth account and the user document
  /// in Firestore. This action cannot be undone.
  Future<void> deleteAccount(String userId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null || currentUser.uid != userId) {
        throw Exception('Unauthorized to delete this account');
      }

      await _firestore.collection('users').doc(userId).delete();
      await currentUser.delete();
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Get the current authenticated user
  Future<User?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return _getUserFromFirestore(firebaseUser.uid);
  }

  // Private helper methods

  Future<User?> _getUserFromFirestore(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return User.fromJson(doc.data()!..['id'] = userId);
  }

  Future<void> _saveUserToFirestore(User user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson());
  }

  Future<void> _updateLastLoginTime(User user) async {
    final updatedUser = user.copyWith(lastLoginAt: DateTime.now());
    await _saveUserToFirestore(updatedUser);
  }

  Exception _handleAuthError(dynamic error) {
    if (error is firebase_auth.FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return Exception('No user found with this email');
        case 'wrong-password':
          return Exception('Incorrect password');
        case 'email-already-in-use':
          return Exception('Email is already registered');
        case 'weak-password':
          return Exception('Password is too weak');
        case 'invalid-email':
          return Exception('Invalid email address');
        case 'operation-not-allowed':
          return Exception('Operation not allowed');
        case 'user-disabled':
          return Exception('This account has been disabled');
        default:
          return Exception('Authentication error: ${error.message}');
      }
    }
    return Exception('An unexpected error occurred: $error');
  }

  /// Dispose of the user stream controller
  void dispose() {
    _userController.close();
  }
}