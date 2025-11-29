import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tb_notification_tracker/widgets/app_scaffold.dart';
import 'package:tb_notification_tracker/widgets/user_form_dialog.dart';
import 'package:tb_notification_tracker/repositories/user_repository.dart';
import 'package:tb_notification_tracker/models/user_model.dart';

/// Users management screen for admin
class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _userRepository = FirestoreUserRepository();
  List<UserModel> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await _userRepository.getAllUsers();

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load users: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _toggleUserActive(UserModel user) async {
    try {
      await _userRepository.toggleUserActive(user.userId, !user.isActive);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User ${user.userId} ${!user.isActive ? 'activated' : 'deactivated'}',
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }

      _loadUsers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update user: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showCreateUserDialog() {
    showDialog(
      context: context,
      builder: (context) => UserFormDialog(
        onUserCreated: _loadUsers,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return AppScaffold(
      title: 'User Management',
      child: Column(
        children: [
          // Header with create button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Users',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _showCreateUserDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Create User'),
                ),
              ],
            ),
          ),

          // Users table
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No users found',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create your first user',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('User ID')),
                              DataColumn(label: Text('Role')),
                              DataColumn(label: Text('PHC Name')),
                              DataColumn(label: Text('Email')),
                              DataColumn(label: Text('Phone')),
                              DataColumn(label: Text('Created')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: _users.map((user) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(user.userId)),
                                  DataCell(
                                    Chip(
                                      label: Text(
                                        _getRoleDisplayName(user.role),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      backgroundColor:
                                          _getRoleColor(context, user.role),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                  DataCell(Text(user.phcName)),
                                  DataCell(Text(user.email)),
                                  DataCell(Text(user.phoneNumber)),
                                  DataCell(
                                      Text(dateFormat.format(user.createdAt))),
                                  DataCell(
                                    Switch(
                                      value: user.isActive,
                                      onChanged: (_) => _toggleUserActive(user),
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            user.isActive
                                                ? Icons.block
                                                : Icons.check_circle,
                                            size: 20,
                                          ),
                                          tooltip: user.isActive
                                              ? 'Deactivate'
                                              : 'Activate',
                                          onPressed: () =>
                                              _toggleUserActive(user),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
          ),

          // Results count
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Total: ${_users.length} user${_users.length != 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 16),
                Text(
                  'Active: ${_users.where((u) => u.isActive).length}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.adminUser:
        return 'Admin';
      case UserRole.stsUser:
        return 'STS';
      case UserRole.phcUser:
        return 'PHC';
    }
  }

  Color _getRoleColor(BuildContext context, UserRole role) {
    switch (role) {
      case UserRole.adminUser:
        return Theme.of(context).colorScheme.errorContainer;
      case UserRole.stsUser:
        return Theme.of(context).colorScheme.tertiaryContainer;
      case UserRole.phcUser:
        return Theme.of(context).colorScheme.primaryContainer;
    }
  }
}

