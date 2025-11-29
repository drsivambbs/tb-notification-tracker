import 'package:flutter_test/flutter_test.dart';
import 'package:tb_notification_tracker/providers/auth_provider.dart';
import 'package:tb_notification_tracker/repositories/auth_repository.dart';
import 'package:tb_notification_tracker/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

// Mock implementation for testing
class MockAuthRepository implements AuthRepository {
  UserModel? _mockUser;
  bool _shouldFail = false;
  String? _failureMessage;

  void setMockUser(UserModel? user) {
    _mockUser = user;
  }

  void setShouldFail(bool shouldFail, [String? message]) {
    _shouldFail = shouldFail;
    _failureMessage = message;
  }

  @override
  Stream<firebase_auth.User?> get authStateChanges => Stream.value(null);

  @override
  firebase_auth.User? get currentUser => null;

  @override
  Future<UserModel?> signIn(String userId, String password) async {
    if (_shouldFail) {
      throw Exception(_failureMessage ?? 'Login failed');
    }
    return _mockUser;
  }

  @override
  Future<void> signOut() async {
    if (_shouldFail) {
      throw Exception(_failureMessage ?? 'Sign out failed');
    }
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    return _mockUser;
  }
}

void main() {
  group('AuthStateProvider', () {
    late MockAuthRepository mockRepo;
    late AuthStateProvider authProvider;

    setUp(() {
      mockRepo = MockAuthRepository();
      authProvider = AuthStateProvider(authRepository: mockRepo);
    });

    test('initial state is not authenticated', () {
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.currentUserData, isNull);
      expect(authProvider.isLoading, false);
      expect(authProvider.errorMessage, isNull);
    });

    test('successful sign in updates state', () async {
      final mockUser = UserModel(
        userId: 'user123',
        passwordHash: 'hashed',
        role: UserRole.phcUser,
        phcName: 'PHC Central',
        email: 'user@example.com',
        phoneNumber: '9876543210',
        createdAt: DateTime.now(),
      );

      mockRepo.setMockUser(mockUser);

      final result = await authProvider.signIn('user123', 'password');

      expect(result, true);
      expect(authProvider.currentUserData, equals(mockUser));
      expect(authProvider.errorMessage, isNull);
      expect(authProvider.isLoading, false);
    });

    test('failed sign in sets error message', () async {
      mockRepo.setShouldFail(true, 'Invalid credentials');

      final result = await authProvider.signIn('user123', 'wrongpassword');

      expect(result, false);
      expect(authProvider.currentUserData, isNull);
      expect(authProvider.errorMessage, isNotNull);
      expect(authProvider.isLoading, false);
    });

    test('inactive user error message is user-friendly', () async {
      mockRepo.setShouldFail(true, 'User account is inactive');

      await authProvider.signIn('user123', 'password');

      expect(authProvider.errorMessage, contains('inactive'));
    });

    test('clearError removes error message', () async {
      mockRepo.setShouldFail(true, 'Some error');
      await authProvider.signIn('user123', 'password');

      expect(authProvider.errorMessage, isNotNull);

      authProvider.clearError();

      expect(authProvider.errorMessage, isNull);
    });

    test('sign out clears user data', () async {
      final mockUser = UserModel(
        userId: 'user123',
        passwordHash: 'hashed',
        role: UserRole.phcUser,
        phcName: 'PHC Central',
        email: 'user@example.com',
        phoneNumber: '9876543210',
        createdAt: DateTime.now(),
      );

      mockRepo.setMockUser(mockUser);
      await authProvider.signIn('user123', 'password');

      expect(authProvider.currentUserData, isNotNull);

      await authProvider.signOut();

      expect(authProvider.currentUserData, isNull);
      expect(authProvider.errorMessage, isNull);
    });
  });
}
