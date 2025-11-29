import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tb_notification_tracker/models/case_model.dart';
import 'package:tb_notification_tracker/models/user_model.dart';
import 'package:tb_notification_tracker/repositories/case_repository.dart';

/// Dialog for viewing and editing case details
class CaseDetailDialog extends StatefulWidget {
  final CaseModel caseModel;
  final UserModel currentUser;
  final VoidCallback onUpdated;

  const CaseDetailDialog({
    super.key,
    required this.caseModel,
    required this.currentUser,
    required this.onUpdated,
  });

  @override
  State<CaseDetailDialog> createState() => _CaseDetailDialogState();
}

class _CaseDetailDialogState extends State<CaseDetailDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nikshayIdController = TextEditingController();
  final _caseRepository = FirestoreCaseRepository();

  late CaseStatus _selectedStatus;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.caseModel.caseStatus;
    _nikshayIdController.text = widget.caseModel.nikshayId ?? '';
  }

  @override
  void dispose() {
    _nikshayIdController.dispose();
    super.dispose();
  }

  bool get _canEdit => widget.currentUser.role == UserRole.stsUser;

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final updates = <String, dynamic>{
        'case_status': _selectedStatus.value,
        'nikshay_id': _nikshayIdController.text.trim().isEmpty
            ? null
            : _nikshayIdController.text.trim(),
        'status_updated_by': widget.currentUser.userId,
        'status_updated_at': DateTime.now(),
      };

      await _caseRepository.updateCase(widget.caseModel.caseId, updates);

      if (!mounted) return;

      Navigator.of(context).pop();
      widget.onUpdated();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Case updated successfully'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update case: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Case Details',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Read-only patient information
                  Text(
                    'Patient Information',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    initialValue: widget.caseModel.patientName,
                    decoration: const InputDecoration(
                      labelText: 'Patient Name',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    readOnly: true,
                    enabled: false,
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: widget.caseModel.patientAge.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Age',
                            border: OutlineInputBorder(),
                            filled: true,
                          ),
                          readOnly: true,
                          enabled: false,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: widget.caseModel.patientGender.value,
                          decoration: const InputDecoration(
                            labelText: 'Gender',
                            border: OutlineInputBorder(),
                            filled: true,
                          ),
                          readOnly: true,
                          enabled: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    initialValue: widget.caseModel.phoneNumber,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    readOnly: true,
                    enabled: false,
                  ),
                  const SizedBox(height: 24),

                  // Read-only PHC information
                  Text(
                    'PHC Information',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    initialValue: widget.caseModel.phcName,
                    decoration: const InputDecoration(
                      labelText: 'PHC Name',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    readOnly: true,
                    enabled: false,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    initialValue: dateFormat.format(widget.caseModel.createdAt),
                    decoration: const InputDecoration(
                      labelText: 'Date Created',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    readOnly: true,
                    enabled: false,
                  ),
                  const SizedBox(height: 24),

                  // Editable case status (for STS users)
                  Text(
                    'Case Status',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<CaseStatus>(
                    initialValue: _selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      border: const OutlineInputBorder(),
                      filled: !_canEdit,
                    ),
                    items: CaseStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.value),
                      );
                    }).toList(),
                    onChanged: _canEdit
                        ? (value) {
                            if (value != null) {
                              setState(() {
                                _selectedStatus = value;
                              });
                            }
                          }
                        : null,
                  ),
                  const SizedBox(height: 12),

                  // Editable Nikshay ID (for STS users)
                  TextFormField(
                    controller: _nikshayIdController,
                    decoration: InputDecoration(
                      labelText: 'Nikshay ID',
                      border: const OutlineInputBorder(),
                      filled: !_canEdit,
                      helperText: _selectedStatus == CaseStatus.nikshayIdGiven
                          ? 'Required when status is "NIKSHAY ID given"'
                          : null,
                    ),
                    readOnly: !_canEdit,
                    enabled: _canEdit,
                    validator: (value) {
                      if (_selectedStatus == CaseStatus.nikshayIdGiven) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nikshay ID is required when status is "NIKSHAY ID given"';
                        }
                      }
                      return null;
                    },
                  ),

                  // Audit trail information
                  if (widget.caseModel.statusUpdatedBy != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Last Updated',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Updated by: ${widget.caseModel.statusUpdatedBy}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (widget.caseModel.statusUpdatedAt != null)
                            Text(
                              'Updated at: ${dateFormat.format(widget.caseModel.statusUpdatedAt!)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Action buttons
                  if (_canEdit)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: _isSubmitting ? null : _saveChanges,
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Save Changes'),
                        ),
                      ],
                    )
                  else
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
