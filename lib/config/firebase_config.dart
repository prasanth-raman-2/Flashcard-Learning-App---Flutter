import 'package:firebase_core/firebase_core.dart';

// PUBLIC_INTERFACE
/// Firebase configuration options for the Flashcard Learning App.
/// 
/// This class provides centralized access to Firebase configuration settings
/// and initialization methods.
class FirebaseConfig {
  /// Initialize Firebase with default options.
  /// 
  /// This method should be called before any Firebase services are used.
  /// Returns a Future that completes when initialization is done.
  static Future<void> initializeApp() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      print('Error initializing Firebase: $e');
      rethrow;
    }
  }

  /// Check if Firebase is initialized
  /// 
  /// Returns true if Firebase is initialized, false otherwise.
  static bool isInitialized() {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}