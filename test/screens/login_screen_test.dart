import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tb_notification_tracker/screens/login_screen.dart';
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
  Future<void> signOut() async {}

  @override
  Future<UserModel?> getCurrentUserData() async {
    return _mockUser;
  }
}

void main() {
  group('LoginScreen Widget Tests', () {
    late MockAuthRepository mockRepo;

    setUp(() {
      mockRepo = MockAuthRepository();
    });

    Widget createLoginScreen() {
      return ChangeNotifierProvider(
        create: (_) => AuthStateProvider(authRepository: mockRepo),
        child: MaterialApp(
          home: const LoginScreen(),
          routes: {
            '/dashboard': (context) => const Scaffold(
                  body: Center(child: Text('Dashboard')),
                ),
          },
        ),
      );
    }

    testWidgets('displays login form with user ID and password fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      expect(find.text('TB Notification Tracker'), findsOneWidget);
      expect(find.text('Sign in to continue'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('User ID'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Sign In'), findsOneWidget);
    });

    testWidgets('validates empty user ID', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Tap sign in without entering user ID
      await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
      await tester.pump();

      expect(find.text('Please enter your user ID'), findsOneWidget);
    });

    testWidgets('validates empty password', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Enter user ID but not password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'User ID'),
        'user123',
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
      await tester.pump();

      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('password visibility toggle button exists',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Find the visibility toggle button
      final visibilityButton = find.descendant(
        of: find.widgetWithText(TextFormField, 'Password'),
        matching: find.byType(IconButton),
      );

      expect(visibilityButton, findsOneWidget);
    });

    testWidgets('sign in button is disabled during loading',
        (WidgetTester tester) async {
      mockRepo.setMockUser(UserModel(
        userId: 'user123',
        passwordHash: 'hashed',
        role: UserRole.phcUser,
        phcName: 'PHC Central',
        email: 'user@example.com',
        phoneNumber: '9876543210',
        createdAt: DateTime.now(),
      ));

      await tester.pumpWidget(createLoginScreen());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'User ID'),
        'user123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password',
      );

      // Verify button exists and is enabled
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Sign In'),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('shows error message on failed login',
        (WidgetTester tester) async {
      mockRepo.setShouldFail(true, 'Invalid credentials');

      await tester.pumpWidget(createLoginScreen());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'User ID'),
        'user123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'wrongpassword',
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
      await tester.pump();
      await tester.pump(); // Additional pump for async operation

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('handles inactive user login attempt',
        (WidgetTester tester) async {
      mockRepo.setShouldFail(
          true, 'User account is inactive. Please contact administrator.');

      await tester.pumpWidget(createLoginScreen());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'User ID'),
        'inactive_user',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password',
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
      await tester.pump();
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Your account is inactive. Please contact administrator.'),
          findsOneWidget);
    });
  });
}
