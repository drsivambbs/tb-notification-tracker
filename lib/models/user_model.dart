import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum representing user roles in the system
enum UserRole {
  adminUser('admin_user'),
  stsUser('sts_user'),
  phcUser('phc_user');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => throw ArgumentError('Invalid user role: $value'),
    );
  }
}

/// User model representing a user in the TB Notification Tracker system
class UserModel {
  final String userId;
  final String passwordHash;
  final UserRole role;
  final String phcName;
  final String email;
  final String phoneNumber;
  final DateTime createdAt;
  final bool isActive;

  UserModel({
    required this.userId,
    required this.passwordHash,
    required this.role,
    required this.phcName,
    required this.email,
    required this.phoneNumber,
    required this.createdAt,
    this.isActive = true,
  });

  /// Convert UserModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'password_hash': passwordHash,
      'role': role.value,
      'phc_name': phcName,
      'email': email,
      'phone_number': phoneNumber,
      'created_at': Timestamp.fromDate(createdAt),
      'is_active': isActive,
    };
  }

  /// Create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      userId: data['user_id'] as String,
      passwordHash: data['password_hash'] as String,
      role: UserRole.fromString(data['role'] as String),
      phcName: data['phc_name'] as String,
      email: data['email'] as String,
      phoneNumber: data['phone_number'] as String,
      createdAt: (data['created_at'] as Timestamp).toDate(),
      isActive: data['is_active'] as bool? ?? true,
    );
  }

  /// Validate that all required fields are present (except password)
  String? validateRequiredFields() {
    if (userId.trim().isEmpty) {
      return 'User ID is required';
    }
    if (phcName.trim().isEmpty) {
      return 'PHC name is required';
    }
    if (email.trim().isEmpty) {
      return 'Email is required';
    }
    if (phoneNumber.trim().isEmpty) {
      return 'Phone number is required';
    }
    return null;
  }

  /// Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? userId,
    String? passwordHash,
    UserRole? role,
    String? phcName,
    String? email,
    String? phoneNumber,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role ?? this.role,
      phcName: phcName ?? this.phcName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
