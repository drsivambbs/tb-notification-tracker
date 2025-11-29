import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tb_notification_tracker/widgets/app_scaffold.dart';
import 'package:tb_notification_tracker/widgets/case_detail_dialog.dart';
import 'package:tb_notification_tracker/providers/auth_provider.dart';
import 'package:tb_notification_tracker/repositories/case_repository.dart';
import 'package:tb_notification_tracker/models/case_model.dart';
import 'package:tb_notification_tracker/models/user_model.dart';

/// Case list screen with filtering and search
class CaseListScreen extends StatefulWidget {
  const CaseListScreen({super.key});

  @override
  State<CaseListScreen> createState() => _CaseListScreenState();
}

class _CaseListScreenState extends State<CaseListScreen> {
  final _searchController = TextEditingController();
  final _caseRepository = FirestoreCaseRepository();
  
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedPhc;
  CaseStatus? _selectedStatus;
  List<CaseModel> _cases = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCases() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthStateProvider>();
      final currentUser = authProvider.currentUserData;

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final filter = CaseFilter(
        phcName: _selectedPhc,
        startDate: _startDate,
        endDate: _endDate,
        status: _selectedStatus,
        searchQuery: _searchController.text.trim(),
      );

      final cases = await _caseRepository.getCases(
        currentUser: currentUser,
        filter: filter,
      );

      setState(() {
        _cases = cases;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load cases: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadCases();
    }
  }

  void _clearDateRange() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    _loadCases();
  }

  void _showCaseDetail(CaseModel caseModel) {
    final authProvider = context.read<AuthStateProvider>();
    final currentUser = authProvider.currentUserData;

    if (currentUser == null) return;

    showDialog(
      context: context,
      builder: (context) => CaseDetailDialog(
        caseModel: caseModel,
        currentUser: currentUser,
        onUpdated: _loadCases,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthStateProvider>();
    final currentUser = authProvider.currentUserData;

    if (currentUser == null) {
      return const AppScaffold(
        title: 'Case List',
        child: Center(
          child: Text('User not authenticated'),
        ),
      );
    }

    final dateFormat = DateFormat('dd/MM/yyyy');
    final isAdmin = currentUser.role == UserRole.adminUser;

    return AppScaffold(
      title: 'Case List',
      child: Column(
        children: [
          // Filters section
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
            child: Column(
              children: [
                // Search bar
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by patient name, phone, or Nikshay ID',
                          prefixIcon: const Icon(Icons.search),
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _loadCases();
                                  },
                                )
                              : null,
                        ),
                        onSubmitted: (_) => _loadCases(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _loadCases,
                      icon: const Icon(Icons.search),
                      label: const Text('Search'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Filter chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Date range filter
                    FilterChip(
                      label: Text(
                        _startDate != null && _endDate != null
                            ? '${dateFormat.format(_startDate!)} - ${dateFormat.format(_endDate!)}'
                            : 'Date Range',
                      ),
                      selected: _startDate != null,
                      onSelected: (_) => _selectDateRange(),
                      avatar: const Icon(Icons.calendar_today, size: 18),
                      deleteIcon: _startDate != null
                          ? const Icon(Icons.close, size: 18)
                          : null,
                      onDeleted: _startDate != null ? _clearDateRange : null,
                    ),

                    // Status filter
                    DropdownMenu<CaseStatus?>(
                      initialSelection: _selectedStatus,
                      label: const Text('Status'),
                      dropdownMenuEntries: [
                        const DropdownMenuEntry<CaseStatus?>(
                          value: null,
                          label: 'All Statuses',
                        ),
                        ...CaseStatus.values.map((status) {
                          return DropdownMenuEntry<CaseStatus?>(
                            value: status,
                            label: status.value,
                          );
                        }),
                      ],
                      onSelected: (value) {
                        setState(() {
                          _selectedStatus = value;
                        });
                        _loadCases();
                      },
                    ),

                    // PHC filter (only for admin)
                    if (isAdmin)
                      SizedBox(
                        width: 200,
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Filter by PHC',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _selectedPhc = value.isEmpty ? null : value;
                            });
                          },
                          onSubmitted: (_) => _loadCases(),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Cases table
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _cases.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox,
                              size: 64,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No cases found',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your filters',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                              DataColumn(label: Text('Date')),
                              DataColumn(label: Text('PHC')),
                              DataColumn(label: Text('Patient Name')),
                              DataColumn(label: Text('Age')),
                              DataColumn(label: Text('Gender')),
                              DataColumn(label: Text('Phone')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Nikshay ID')),
                            ],
                            rows: _cases.map((caseModel) {
                              return DataRow(
                                onSelectChanged: (_) => _showCaseDetail(caseModel),
                                cells: [
                                  DataCell(Text(
                                    dateFormat.format(caseModel.createdAt),
                                  )),
                                  DataCell(Text(caseModel.phcName)),
                                  DataCell(Text(caseModel.patientName)),
                                  DataCell(Text(caseModel.patientAge.toString())),
                                  DataCell(Text(caseModel.patientGender.value)),
                                  DataCell(Text(caseModel.phoneNumber)),
                                  DataCell(
                                    Chip(
                                      label: Text(
                                        caseModel.caseStatus.value,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      backgroundColor: _getStatusColor(
                                        context,
                                        caseModel.caseStatus,
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                  DataCell(Text(
                                    caseModel.nikshayId ?? '-',
                                  )),
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
                  'Total: ${_cases.length} case${_cases.length != 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BuildContext context, CaseStatus status) {
    switch (status) {
      case CaseStatus.processing:
        return Theme.of(context).colorScheme.secondaryContainer;
      case CaseStatus.nikshayIdGiven:
        return Theme.of(context).colorScheme.primaryContainer;
      case CaseStatus.unableToContact:
        return Theme.of(context).colorScheme.errorContainer;
    }
  }
}

