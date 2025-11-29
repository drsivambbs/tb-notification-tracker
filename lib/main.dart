import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:tb_notification_tracker/firebase_options.dart';
import 'package:tb_notification_tracker/providers/auth_provider.dart';
import 'package:tb_notification_tracker/repositories/auth_repository.dart';
import 'package:tb_notification_tracker/models/user_model.dart';
import 'package:tb_notification_tracker/widgets/offline_banner.dart';
import 'package:tb_notification_tracker/screens/login_screen.dart';
import 'package:tb_notification_tracker/screens/dashboard_screen.dart';
import 'package:tb_notification_tracker/screens/case_entry_screen.dart';
import 'package:tb_notification_tracker/screens/case_list_screen.dart';
import 'package:tb_notification_tracker/screens/users_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const TBNotificationTrackerApp());
}

class TBNotificationTrackerApp extends StatefulWidget {
  const TBNotificationTrackerApp({super.key});

  @override
  State<TBNotificationTrackerApp> createState() => _TBNotificationTrackerAppState();
}

class _TBNotificationTrackerAppState extends State<TBNotificationTrackerApp> {
  late final AuthStateProvider _authProvider;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthStateProvider(
      authRepository: FirebaseAuthRepository(),
    );
    
    _router = GoRouter(
      initialLocation: '/login',
      refreshListenable: _authProvider,
      redirect: (context, state) {
        final isAuthenticated = _authProvider.isAuthenticated;
        final isLoginRoute = state.uri.path == '/login';

        // Redirect to login if not authenticated and not already on login
        if (!isAuthenticated && !isLoginRoute) {
          return '/login';
        }

        // Redirect to dashboard if authenticated and on login page
        if (isAuthenticated && isLoginRoute) {
          return '/dashboard';
        }

        // Check role-based access
        final currentUser = _authProvider.currentUserData;
        if (currentUser != null && isAuthenticated) {
          final path = state.uri.path;

          // Case Entry - only PHC users
          if (path == '/case-entry' &&
              currentUser.role != UserRole.phcUser) {
            return '/dashboard';
          }

          // Users - only admin users
          if (path == '/users' && currentUser.role != UserRole.adminUser) {
            return '/dashboard';
          }
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/case-entry',
          builder: (context, state) => const CaseEntryScreen(),
        ),
        GoRoute(
          path: '/case-list',
          builder: (context, state) => const CaseListScreen(),
        ),
        GoRoute(
          path: '/users',
          builder: (context, state) => const UsersScreen(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _authProvider.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
      ],
      child: MaterialApp.router(
        title: 'TB Notification Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Material Design 3
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          // Compact visual density for efficient UI
          visualDensity: VisualDensity.compact,
          // Compact data table theme
          dataTableTheme: const DataTableThemeData(
            horizontalMargin: 12,
            columnSpacing: 24,
            dataRowMinHeight: 48,
            dataRowMaxHeight: 48,
          ),
        ),
        routerConfig: _router,
        builder: (context, child) {
          return OfflineBanner(child: child ?? const SizedBox());
        },
      ),
    );
  }
}


