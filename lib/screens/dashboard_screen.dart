import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tb_notification_tracker/providers/auth_provider.dart';
import 'package:tb_notification_tracker/widgets/app_scaffold.dart';
import 'package:tb_notification_tracker/repositories/case_repository.dart';
import 'package:tb_notification_tracker/models/case_model.dart';

/// PHC-wise summary data
class PhcSummary {
  final String phcName;
  final int totalCases;
  final int casesWithNikshayId;
  final int casesUnableToContact;
  final int casesProcessing;
  final Duration? averageDelay;

  PhcSummary({
    required this.phcName,
    required this.totalCases,
    required this.casesWithNikshayId,
    required this.casesUnableToContact,
    required this.casesProcessing,
    this.averageDelay,
  });
}

/// Dashboard screen with metrics and PHC-wise summary
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _caseRepository = FirestoreCaseRepository();
  List<CaseModel> _cases = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthStateProvider>();
      final currentUser = authProvider.currentUserData;

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final cases = await _caseRepository.getCases(
        currentUser: currentUser,
        filter: null,
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
            content: Text('Failed to load data: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  List<PhcSummary> _calculatePhcSummaries() {
    final phcMap = <String, List<CaseModel>>{};

    // Group cases by PHC
    for (final caseModel in _cases) {
      phcMap.putIfAbsent(caseModel.phcName, () => []).add(caseModel);
    }

    // Calculate summaries for each PHC
    return phcMap.entries.map((entry) {
      final phcName = entry.key;
      final phcCases = entry.value;

      final totalCases = phcCases.length;
      final casesWithNikshayId = phcCases
          .where((c) => c.caseStatus == CaseStatus.nikshayIdGiven)
          .length;
      final casesUnableToContact = phcCases
          .where((c) => c.caseStatus == CaseStatus.unableToContact)
          .length;
      final casesProcessing = phcCases
          .where((c) => c.caseStatus == CaseStatus.processing)
          .length;

      // Calculate average delay for cases with Nikshay ID
      final casesWithDelay = phcCases.where((c) =>
          c.caseStatus == CaseStatus.nikshayIdGiven &&
          c.statusUpdatedAt != null);

      Duration? averageDelay;
      if (casesWithDelay.isNotEmpty) {
        final totalDelay = casesWithDelay.fold<Duration>(
          Duration.zero,
          (sum, c) => sum + c.statusUpdatedAt!.difference(c.createdAt),
        );
        averageDelay = totalDelay ~/ casesWithDelay.length;
      }

      return PhcSummary(
        phcName: phcName,
        totalCases: totalCases,
        casesWithNikshayId: casesWithNikshayId,
        casesUnableToContact: casesUnableToContact,
        casesProcessing: casesProcessing,
        averageDelay: averageDelay,
      );
    }).toList()
      ..sort((a, b) => b.totalCases.compareTo(a.totalCases));
  }

  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    if (days > 0) {
      return '$days day${days != 1 ? 's' : ''} ${hours}h';
    }
    return '${hours}h';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthStateProvider>();
    final userData = authProvider.currentUserData;

    if (userData == null) {
      return const AppScaffold(
        title: 'Dashboard',
        child: Center(
          child: Text('User not authenticated'),
        ),
      );
    }

    if (_isLoading) {
      return const AppScaffold(
        title: 'Dashboard',
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final totalCases = _cases.length;
    final casesWithNikshayId =
        _cases.where((c) => c.caseStatus == CaseStatus.nikshayIdGiven).length;
    final casesUnableToContact =
        _cases.where((c) => c.caseStatus == CaseStatus.unableToContact).length;
    final casesProcessing =
        _cases.where((c) => c.caseStatus == CaseStatus.processing).length;

    final phcSummaries = _calculatePhcSummaries();

    return AppScaffold(
      title: 'Dashboard',
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome message
              Text(
                'Welcome, ${userData.userId}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                userData.phcName,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),

              // Quick stats cards
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildStatCard(
                    context,
                    'Total Cases',
                    totalCases.toString(),
                    Icons.medical_information,
                    Theme.of(context).colorScheme.primaryContainer,
                  ),
                  _buildStatCard(
                    context,
                    'Nikshay ID Given',
                    casesWithNikshayId.toString(),
                    Icons.check_circle,
                    Theme.of(context).colorScheme.tertiaryContainer,
                  ),
                  _buildStatCard(
                    context,
                    'Processing',
                    casesProcessing.toString(),
                    Icons.pending,
                    Theme.of(context).colorScheme.secondaryContainer,
                  ),
                  _buildStatCard(
                    context,
                    'Unable to Contact',
                    casesUnableToContact.toString(),
                    Icons.phone_disabled,
                    Theme.of(context).colorScheme.errorContainer,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // PHC-wise summary table
              Text(
                'PHC-wise Summary',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),

              if (phcSummaries.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.inbox,
                            size: 48,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No data available',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Card(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('PHC Name')),
                        DataColumn(label: Text('Total Cases'), numeric: true),
                        DataColumn(
                            label: Text('Nikshay ID Given'), numeric: true),
                        DataColumn(
                            label: Text('Unable to Contact'), numeric: true),
                        DataColumn(label: Text('Processing'), numeric: true),
                        DataColumn(label: Text('Avg. Delay')),
                      ],
                      rows: phcSummaries.map((summary) {
                        return DataRow(
                          cells: [
                            DataCell(Text(summary.phcName)),
                            DataCell(Text(summary.totalCases.toString())),
                            DataCell(
                                Text(summary.casesWithNikshayId.toString())),
                            DataCell(Text(
                                summary.casesUnableToContact.toString())),
                            DataCell(Text(summary.casesProcessing.toString())),
                            DataCell(Text(
                              summary.averageDelay != null
                                  ? _formatDuration(summary.averageDelay!)
                                  : '-',
                            )),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color backgroundColor,
  ) {
    return SizedBox(
      width: 160,
      child: Card(
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 12),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

