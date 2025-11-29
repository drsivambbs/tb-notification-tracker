import 'package:flutter/material.dart';
import 'package:tb_notification_tracker/widgets/sidebar_menu.dart';

/// Main app scaffold with sidebar navigation and content area
class AppScaffold extends StatelessWidget {
  final Widget child;
  final String title;

  const AppScaffold({
    super.key,
    required this.child,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      drawer: isWideScreen ? null : const SidebarMenu(),
      body: Row(
        children: [
          // Sidebar for wide screens
          if (isWideScreen) const SidebarMenu(),
          
          // Main content area
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}
