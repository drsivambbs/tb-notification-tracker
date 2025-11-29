import 'package:flutter/foundation.dart';
import 'package:tb_notification_tracker/models/user_model.dart';
import 'package:tb_notification_tracker/repositories/auth_repository.dart';

/// Provider for managing authentication state
class AuthStateProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  
  UserModel? _currentUserData;
  bool _isLoading = false;
  String? _errorMessage;

  AuthStateProvider({required AuthRepository authRepository})
      : _authRepository = authRepository {
    // Listen to auth state changes
    _authRepository.authStateChanges.listen(_onAuthStateChanged);
  }

  /// Current user data
  UserModel? get currentUserData => _currentUserData;

  /// Current user
  UserModel? get currentUser => _authRepository.currentUser;

  /// Loading state
  bool get isLoading => _isLoading;

  /// Error message
  String? get errorMessage => _errorMessage;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentUserData != null;

  /// Handle auth state changes
  void _onAuthStateChanged(UserModel? user) {
    _currentUserData = user;
    notifyListeners();
  }

  /// Sign in with user ID and password
  Future<bool> signIn(String userId, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userData = await _authRepository.signIn(userId, password);
      _currentUserData = userData;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.signOut();
      _currentUserData = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to sign out: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    final errorString = error.toString();
    
    if (errorString.contains('User not found')) {
      return 'Invalid user ID or password';
    } else if (errorString.contains('Invalid credentials')) {
      return 'Invalid user ID or password';
    } else if (errorString.contains('inactive')) {
      return 'Your account is inactive. Please contact administrator.';
    } else if (errorString.contains('network')) {
      return 'Network error. Please check your connection.';
    } else {
      return 'Login failed. Please try again.';
    }
  }

  @override
  void dispose() {
    if (_authRepository is FirebaseAuthRepository) {
      (_authRepository as FirebaseAuthRepository).dispose();
    }
    super.dispose();
  }
}
