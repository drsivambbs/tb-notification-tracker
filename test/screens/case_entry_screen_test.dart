import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:tb_notification_tracker/screens/case_entry_screen.dart';
import 'package:tb_notification_tracker/providers/auth_provider.dart';
import 'package:tb_notification_tracker/repositories/auth_repository.dart';
import 'package:tb_notification_tracker/models/user_model.dart';
import 'package:tb_notification_tracker/models/case_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

// Mock implementation for testing
class MockAuthRepository implements AuthRepository {
  UserModel? _mockUser;

  void setMockUser(UserModel? user) {
    _mockUser = user;
  }

  @override
  Stream<firebase_auth.User?> get authStateChanges => Stream.value(null);

  @override
  firebase_auth.User? get currentUser => null;

  @override
  Future<UserModel?> signIn(String userId, String password) async {
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
  group('CaseEntryScreen Widget Tests', () {
    late MockAuthRepository mockRepo;

    setUp(() {
      mockRepo = MockAuthRepository();
    });

    Widget createCaseEntryScreen(UserModel user) {
      mockRepo.setMockUser(user);

      final authProvider = AuthStateProvider(authRepository: mockRepo);
      authProvider.signIn(user.userId, 'password');

      final router = GoRouter(
        initialLocation: '/case-entry',
        routes: [
          GoRoute(
            path: '/case-entry',
            builder: (context, state) => const CaseEntryScreen(),
          ),
          GoRoute(
            path: '/case-list',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Case List')),
            ),
          ),
        ],
      );

      return ChangeNotifierProvider.value(
        value: authProvider,
        child: MaterialApp.router(
          routerConfig: router,
        ),
      );
    }

    testWidgets('displays case entry form with all fields',
        (WidgetTester tester) async {
      final phcUser = UserModel(
        userId: 'phc_user',
        passwordHash: 'hashed',
        role: UserRole.phcUser,
        phcName: 'PHC Central',
        email: 'phc@example.com',
        phoneNumber: '9876543210',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(createCaseEntryScreen(phcUser));
      await tester.pumpAndSettle();

      expect(find.text('New TB Case Entry'), findsOneWidget);
      expect(find.text('PHC Name'), findsOneWidget);
      expect(find.text('Date and Time'), findsOneWidget);
      expect(find.text('Patient Name *'), findsOneWidget);
      expect(find.text('Patient Age *'), findsOneWidget);
      expect(find.text('Patient Gender *'), findsOneWidget);
      expect(find.text('Phone Number *'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Submit Case'), findsOneWidget);
    });

    testWidgets('PHC field is auto-filled with user PHC name',
        (WidgetTester tester) async {
      final phcUser = UserModel(
        userId: 'phc_user',
        passwordHash: 'hashed',
        role: UserRole.phcUser,
        phcName: 'PHC Central',
        email: 'phc@example.com',
        phoneNumber: '9876543210',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(createCaseEntryScreen(phcUser));
      await tester.pumpAndSettle();

      // PHC field should display the user's PHC name
      expect(find.text('PHC Central'), findsWidgets);
    });

    testWidgets('form has patient name field', (WidgetTester tester) async {
      final phcUser = UserModel(
        userId: 'phc_user',
        passwordHash: 'hashed',
        role: UserRole.phcUser,
        phcName: 'PHC Central',
        email: 'phc@example.com',
        phoneNumber: '9876543210',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(createCaseEntryScreen(phcUser));
      await tester.pumpAndSettle();

      // Patient name field should exist
      expect(find.widgetWithText(TextFormField, 'Patient Name *'),
          findsOneWidget);
    });

    testWidgets('form has patient age field with helper text',
        (WidgetTester tester) async {
      final phcUser = UserModel(
        userId: 'phc_user',
        passwordHash: 'hashed',
        role: UserRole.phcUser,
        phcName: 'PHC Central',
        email: 'phc@example.com',
        phoneNumber: '9876543210',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(createCaseEntryScreen(phcUser));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextFormField, 'Patient Age *'),
          findsOneWidget);
      expect(find.text('Age must be between 0 and 120'), findsOneWidget);
    });

    testWidgets('form has phone number field with helper text',
        (WidgetTester tester) async {
      final phcUser = UserModel(
        userId: 'phc_user',
        passwordHash: 'hashed',
        role: UserRole.phcUser,
        phcName: 'PHC Central',
        email: 'phc@example.com',
        phoneNumber: '9876543210',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(createCaseEntryScreen(phcUser));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextFormField, 'Phone Number *'),
          findsOneWidget);
      expect(find.text('10-digit mobile number'), findsOneWidget);
    });

    testWidgets('form has gender dropdown', (WidgetTester tester) async {
      final phcUser = UserModel(
        userId: 'phc_user',
        passwordHash: 'hashed',
        role: UserRole.phcUser,
        phcName: 'PHC Central',
        email: 'phc@example.com',
        phoneNumber: '9876543210',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(createCaseEntryScreen(phcUser));
      await tester.pumpAndSettle();

      // Gender dropdown should exist
      expect(find.byType(DropdownButtonFormField<Gender>), findsOneWidget);
    });
  });
}
