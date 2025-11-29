import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:tb_notification_tracker/widgets/sidebar_menu.dart';
import 'package:tb_notification_tracker/providers/auth_provider.dart';
import 'package:tb_notification_tracker/repositories/auth_repository.dart';
import 'package:tb_notification_tracker/models/user_model.dart';
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
  group('SidebarMenu Role-Based Visibility Tests', () {
    late MockAuthRepository mockRepo;

    setUp(() {
      mockRepo = MockAuthRepository();
    });

    Widget createSidebarMenu(UserModel user) {
      mockRepo.setMockUser(user);

      final authProvider = AuthStateProvider(authRepository: mockRepo);
      // Manually set the user data for testing
      authProvider.signIn(user.userId, 'password');

      final router = GoRouter(
        initialLocation: '/dashboard',
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const Scaffold(
              body: SidebarMenu(),
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

    testWidgets('PHC user sees Dashboard, Case Entry, and Case List',
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

      await tester.pumpWidget(createSidebarMenu(phcUser));
      await tester.pumpAndSettle();

      // PHC user should see these menu items
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Case Entry'), findsOneWidget);
      expect(find.text('Case List'), findsOneWidget);

      // PHC user should NOT see Users menu
      expect(find.text('Users'), findsNothing);
    });

    testWidgets('Admin user sees Dashboard, Case List, and Users',
        (WidgetTester tester) async {
      final adminUser = UserModel(
        userId: 'admin_user',
        passwordHash: 'hashed',
        role: UserRole.adminUser,
        phcName: 'Admin Office',
        email: 'admin@example.com',
        phoneNumber: '9876543210',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(createSidebarMenu(adminUser));
      await tester.pumpAndSettle();

      // Admin user should see these menu items
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Case List'), findsOneWidget);
      expect(find.text('Users'), findsOneWidget);

      // Admin user should NOT see Case Entry
      expect(find.text('Case Entry'), findsNothing);
    });

    testWidgets('STS user sees Dashboard and Case List',
        (WidgetTester tester) async {
      final stsUser = UserModel(
        userId: 'sts_user',
        passwordHash: 'hashed',
        role: UserRole.stsUser,
        phcName: 'PHC Central',
        email: 'sts@example.com',
        phoneNumber: '9876543210',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(createSidebarMenu(stsUser));
      await tester.pumpAndSettle();

      // STS user should see these menu items
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Case List'), findsOneWidget);

      // STS user should NOT see Case Entry or Users
      expect(find.text('Case Entry'), findsNothing);
      expect(find.text('Users'), findsNothing);
    });

    testWidgets('Sidebar displays user information',
        (WidgetTester tester) async {
      final user = UserModel(
        userId: 'test_user',
        passwordHash: 'hashed',
        role: UserRole.phcUser,
        phcName: 'PHC Test',
        email: 'test@example.com',
        phoneNumber: '9876543210',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(createSidebarMenu(user));
      await tester.pumpAndSettle();

      // Should display user info
      expect(find.text('test_user'), findsOneWidget);
      expect(find.text('PHC User'), findsOneWidget);
      expect(find.text('PHC Test'), findsOneWidget);
    });

    testWidgets('Sidebar has sign out button', (WidgetTester tester) async {
      final user = UserModel(
        userId: 'test_user',
        passwordHash: 'hashed',
        role: UserRole.phcUser,
        phcName: 'PHC Test',
        email: 'test@example.com',
        phoneNumber: '9876543210',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(createSidebarMenu(user));
      await tester.pumpAndSettle();

      expect(find.text('Sign Out'), findsOneWidget);
    });
  });
}
