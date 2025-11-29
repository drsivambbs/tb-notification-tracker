import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:tb_notification_tracker/providers/auth_provider.dart';
import 'package:tb_notification_tracker/models/user_model.dart';

/// Menu item data
class MenuItem {
  final String title;
  final IconData icon;
  final String route;
  final Set<UserRole> allowedRoles;

  const MenuItem({
    required this.title,
    required this.icon,
    required this.route,
    required this.allowedRoles,
  });
}

/// Sidebar navigation menu with role-based visibility
class SidebarMenu extends StatelessWidget {
  const SidebarMenu({super.key});

  // Define menu items with role-based access
  static const List<MenuItem> _menuItems = [
    MenuItem(
      title: 'Dashboard',
      icon: Icons.dashboard,
      route: '/dashboard',
      allowedRoles: {UserRole.adminUser, UserRole.stsUser, UserRole.phcUser},
    ),
    MenuItem(
      title: 'Case Entry',
      icon: Icons.add_box,
      route: '/case-entry',
      allowedRoles: {UserRole.phcUser}, // Only PHC users
    ),
    MenuItem(
      title: 'Case List',
      icon: Icons.list_alt,
      route: '/case-list',
      allowedRoles: {UserRole.adminUser, UserRole.stsUser, UserRole.phcUser},
    ),
    MenuItem(
      title: 'Users',
      icon: Icons.people,
      route: '/users',
      allowedRoles: {UserRole.adminUser}, // Only admin users
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthStateProvider>();
    final currentUser = authProvider.currentUserData;
    final currentRoute = GoRouterState.of(context).uri.path;

    // Filter menu items based on user role
    final visibleItems = _menuItems.where((item) {
      if (currentUser == null) return false;
      return item.allowedRoles.contains(currentUser.role);
    }).toList();

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // User info section
          if (currentUser != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          currentUser.userId[0].toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentUser.userId,
                              style: Theme.of(context).textTheme.titleSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _getRoleDisplayName(currentUser.role),
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentUser.phcName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

          // Menu items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: visibleItems.length,
              itemBuilder: (context, index) {
                final item = visibleItems[index];
                final isActive = currentRoute == item.route;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  child: ListTile(
                    leading: Icon(
                      item.icon,
                      size: 24,
                    ),
                    title: Text(item.title),
                    selected: isActive,
                    selectedTileColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    onTap: () {
                      context.go(item.route);
                      // Close drawer on mobile
                      if (Scaffold.of(context).hasDrawer) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                );
              },
            ),
          ),

          // Sign out button
          Padding(
            padding: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(Icons.logout, size: 24),
              title: const Text('Sign Out'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              onTap: () async {
                await authProvider.signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.adminUser:
        return 'Administrator';
      case UserRole.stsUser:
        return 'STS User';
      case UserRole.phcUser:
        return 'PHC User';
    }
  }
}
