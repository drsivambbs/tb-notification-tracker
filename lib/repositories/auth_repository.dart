import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tb_notification_tracker/models/user_model.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:async';

/// Repository for handling authentication operations
abstract class AuthRepository {
  /// Sign in with user ID and password
  Future<UserModel?> signIn(String userId, String password);
  
  /// Sign out the current user
  Future<void> signOut();
  
  /// Stream of authentication state changes
  Stream<UserModel?> get authStateChanges;
  
  /// Get the current authenticated user
  UserModel? get currentUser;
  
  /// Get the current user's data from Firestore
  Future<UserModel?> getCurrentUserData();
}

/// Implementation of AuthRepository using Firestore only (no Firebase Auth)
class FirebaseAuthRepository implements AuthRepository {
  final FirebaseFirestore _firestore;
  final StreamController<UserModel?> _authStateController = StreamController<UserModel?>.broadcast();
  UserModel? _currentUser;

  FirebaseAuthRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  @override
  UserModel? get currentUser => _currentUser;

  @override
  Future<UserModel?> signIn(String userId, String password) async {
    try {
      // Get the user document from Firestore
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      final userData = UserModel.fromFirestore(userDoc);
      
      // Check if user is active
      if (!userData.isActive) {
        throw Exception('User account is inactive. Please contact administrator.');
      }

      // Verify password by comparing hashes
      final hashedPassword = _hashPassword(password);
      if (userData.passwordHash != hashedPassword) {
        throw Exception('Invalid credentials');
      }

      // Set current user and notify listeners
      _currentUser = userData;
      _authStateController.add(userData);

      return userData;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    return _currentUser;
  }

  /// Hash password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Create a new user in Firestore with hashed password
  Future<void> createUser(UserModel user, String plainPassword) async {
    final hashedPassword = _hashPassword(plainPassword);
    final userWithHash = user.copyWith(passwordHash: hashedPassword);
    
    await _firestore
        .collection('users')
        .doc(user.userId)
        .set(userWithHash.toFirestore());
  }
  
  void dispose() {
    _authStateController.close();
  }
}
