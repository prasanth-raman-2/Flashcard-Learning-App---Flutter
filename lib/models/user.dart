// PUBLIC_INTERFACE
/// A model class representing a user in the application.
/// 
/// This class includes user authentication information, preferences, and provides
/// serialization support for Firebase Firestore.
class User {
  /// Creates a new User instance.
  User({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  })  : preferences = preferences ?? {},
        createdAt = createdAt ?? DateTime.now(),
        lastLoginAt = lastLoginAt ?? DateTime.now();

  /// Unique identifier for the user
  final String id;

  /// User's email address
  final String email;

  /// User's display name
  final String displayName;

  /// Optional profile photo URL
  final String? photoUrl;

  /// User preferences stored as key-value pairs
  final Map<String, dynamic> preferences;

  /// Account creation timestamp
  final DateTime createdAt;

  /// Last login timestamp
  final DateTime lastLoginAt;

  /// Creates a User instance from a Firestore document
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String,
      photoUrl: json['photo_url'] as String?,
      preferences: Map<String, dynamic>.from(json['preferences'] as Map),
      createdAt: (json['created_at'] as Timestamp).toDate(),
      lastLoginAt: (json['last_login_at'] as Timestamp).toDate(),
    );
  }

  /// Converts the User instance to a JSON map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'preferences': preferences,
      'created_at': Timestamp.fromDate(createdAt),
      'last_login_at': Timestamp.fromDate(lastLoginAt),
    };
  }

  /// Creates a copy of this User with the given fields replaced with new values
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  /// Validates the email format
  bool isEmailValid() {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          displayName == other.displayName &&
          photoUrl == other.photoUrl;

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      displayName.hashCode ^
      photoUrl.hashCode;
}