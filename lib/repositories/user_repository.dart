import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tb_notification_tracker/models/user_model.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Repository for user data operations
abstract class UserRepository {
  /// Get all users
  Future<List<UserModel>> getAllUsers();

  /// Get a user by ID
  Future<UserModel?> getUserById(String userId);

  /// Create a new user
  Future<void> createUser(UserModel user, String plainPassword);

  /// Update user information
  Future<void> updateUser(String userId, Map<String, dynamic> updates);

  /// Toggle user active status
  Future<void> toggleUserActive(String userId, bool isActive);

  /// Delete a user
  Future<void> deleteUser(String userId);

  /// Check if user ID already exists
  Future<bool> userIdExists(String userId);
}

/// Firestore implementation of UserRepository
class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;

  FirestoreUserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('created_at', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  @override
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        return null;
      }

      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  @override
  Future<void> createUser(UserModel user, String plainPassword) async {
    try {
      // Check if user ID already exists
      final exists = await userIdExists(user.userId);
      if (exists) {
        throw Exception('User ID already exists');
      }

      // Hash the password
      final hashedPassword = _hashPassword(plainPassword);
      final userWithHash = user.copyWith(passwordHash: hashedPassword);

      // Create user document
      await _firestore
          .collection('users')
          .doc(user.userId)
          .set(userWithHash.toFirestore());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  @override
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      // Check if user exists
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        throw Exception('User not found');
      }

      // If password is being updated, hash it
      if (updates.containsKey('password')) {
        final plainPassword = updates['password'] as String;
        updates['password_hash'] = _hashPassword(plainPassword);
        updates.remove('password');
      }

      await _firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  @override
  Future<void> toggleUserActive(String userId, bool isActive) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'is_active': isActive,
      });
    } catch (e) {
      throw Exception('Failed to toggle user active status: $e');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  @override
  Future<bool> userIdExists(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists;
    } catch (e) {
      throw Exception('Failed to check user ID: $e');
    }
  }

  /// Hash password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
