import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../models/application_model.dart';
import '../providers/application_provider.dart';
import '../../resume/providers/resume_provider.dart';

class ApplicationEntryScreen extends ConsumerStatefulWidget {
  /// If provided, the screen edits an existing application.
  final JobApplicationModel? existingApplication;

  const ApplicationEntryScreen({super.key, this.existingApplication});

  @override
  ConsumerState<ApplicationEntryScreen> createState() => _ApplicationEntryScreenState();
}

class _ApplicationEntryScreenState extends ConsumerState<ApplicationEntryScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  void _saveApplication() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;

      final newApplication = JobApplicationModel(
        id: widget.existingApplication?.id ?? const Uuid().v4(),
        companyName: formData['companyName'],
        jobRole: formData['jobRole'],
        dateApplied: formData['dateApplied'],
        resumeId: formData['resumeId'],
        status: formData['status'],
        notes: formData['notes'],
        createdAt: widget.existingApplication?.createdAt ?? DateTime.now(),
      );

      // We only support Add and UpdateStatus in the current requirement, 
      // but if we had an edit method, we'd call it. Here we just overwrite using saveItem.
      // We will use addApplication because addApplication uses saveItem which overwrites if ID exists.
      ref.read(applicationProvider.notifier).addApplication(newApplication);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.existingApplication == null ? 'Application tracked!' : 'Application updated!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the errors in the form.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingApplication != null;
    final resumes = ref.watch(resumeProvider).resumes;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Application' : 'Add Application'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Application',
            onPressed: _saveApplication,
          ),
        ],
      ),
      body: resumes.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 64, color: Theme.of(context).colorScheme.error),
                    const SizedBox(height: 16),
                    Text(
                      'No Resumes Available',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You need to create at least one Resume Profile before tracking an application.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            )
          : FormBuilder(
              key: _formKey,
              initialValue: {
                'companyName': widget.existingApplication?.companyName ?? '',
                'jobRole': widget.existingApplication?.jobRole ?? '',
                'dateApplied': widget.existingApplication?.dateApplied ?? DateTime.now(),
                'resumeId': widget.existingApplication?.resumeId ?? (resumes.isNotEmpty ? resumes.first.id : null),
                'status': widget.existingApplication?.status ?? ApplicationStatus.applied,
                'notes': widget.existingApplication?.notes ?? '',
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Job Details ---
                    Card(
                      elevation: 0,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildSectionHeader('Job Details', Icons.work_outline),
                            FormBuilderTextField(
                              name: 'companyName',
                              decoration: InputDecoration(
                                labelText: 'Company Name',
                                prefixIcon: const Icon(Icons.business),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surface,
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                              ]),
                            ),
                            const SizedBox(height: 16),
                            FormBuilderTextField(
                              name: 'jobRole',
                              decoration: InputDecoration(
                                labelText: 'Job Role / Title',
                                prefixIcon: const Icon(Icons.badge_outlined),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surface,
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                              ]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- Application Status & Date ---
                    Card(
                      elevation: 0,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildSectionHeader('Tracking Info', Icons.analytics_outlined),
                            FormBuilderDropdown<ApplicationStatus>(
                              name: 'status',
                              decoration: InputDecoration(
                                labelText: 'Current Status',
                                prefixIcon: const Icon(Icons.pending_actions),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surface,
                              ),
                              validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                              items: ApplicationStatus.values.map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(_statusToString(status)),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                            FormBuilderDateTimePicker(
                              name: 'dateApplied',
                              inputType: InputType.date,
                              format: DateFormat('yyyy-MM-dd'),
                              decoration: InputDecoration(
                                labelText: 'Date Applied',
                                prefixIcon: const Icon(Icons.calendar_today),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surface,
                              ),
                              validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                            ),
                            const SizedBox(height: 16),
                            FormBuilderDropdown<String>(
                              name: 'resumeId',
                              decoration: InputDecoration(
                                labelText: 'Resume Used',
                                prefixIcon: const Icon(Icons.description_outlined),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surface,
                              ),
                              validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                              items: resumes.map((resume) {
                                return DropdownMenuItem(
                                  value: resume.id,
                                  child: Text(resume.fullName),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- Notes ---
                    Card(
                      elevation: 0,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildSectionHeader('Additional Notes', Icons.notes),
                            FormBuilderTextField(
                              name: 'notes',
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: 'Enter any interview feedback, salary expectations, etc.',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- Save Button ---
                    SizedBox(
                      height: 56,
                      child: FilledButton.icon(
                        onPressed: _saveApplication,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text(
                          'Save Application',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }

  String _statusToString(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.applied:
        return 'Applied';
      case ApplicationStatus.shortlisted:
        return 'Shortlisted';
      case ApplicationStatus.interviewScheduled:
        return 'Interview Scheduled';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.selected:
        return 'Selected';
    }
  }
}
