import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../models/application_model.dart';
import '../providers/application_provider.dart';
import '../../resume/providers/resume_provider.dart';
import 'application_entry_screen.dart';

class ApplicationTrackingScreen extends ConsumerWidget {
  const ApplicationTrackingScreen({super.key});

  void _navigateToAddApplication(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ApplicationEntryScreen()),
    );
  }

  void _updateStatus(BuildContext context, WidgetRef ref, JobApplicationModel application) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Update Status',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...ApplicationStatus.values.map((status) {
                return ListTile(
                  title: Text(_statusToString(status)),
                  trailing: application.status == status
                      ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () {
                    ref.read(applicationProvider.notifier).updateStatus(application.id, status);
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Status updated to ${_statusToString(status)}')),
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    ref.read(applicationProvider.notifier).deleteApplication(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Application deleted.'), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(applicationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Applications'),
        centerTitle: true,
      ),
      body: _buildBody(context, ref, state),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddApplication(context),
        icon: const Icon(Icons.add),
        label: const Text('Track Application'),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, ApplicationState state) {
    if (state.isLoading && state.filteredApplications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.filteredApplications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_off_outlined, size: 80, color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
            const SizedBox(height: 24),
            Text(
              'No Applications Found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your job applications today.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ).animate().fadeIn(duration: 500.ms).scale(duration: 500.ms),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
      itemCount: state.filteredApplications.length,
      itemBuilder: (context, index) {
        final app = state.filteredApplications[index];
        return Dismissible(
          key: Key(app.id),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            child: const Icon(Icons.delete_outline, color: Colors.white, size: 32),
          ),
          onDismissed: (_) => _confirmDelete(context, ref, app.id),
          child: _buildTimelineCard(context, ref, app, index),
        );
      },
    );
  }

  Widget _buildTimelineCard(BuildContext context, WidgetRef ref, JobApplicationModel app, int index) {
    final resumes = ref.read(resumeProvider).resumes;
    final linkedResume = resumes.where((r) => r.id == app.resumeId).firstOrNull;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _updateStatus(context, ref, app),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      app.companyName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusBadge(context, app.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                app.jobRole,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    'Applied: ${DateFormat('MMM dd, yyyy').format(app.dateApplied)}',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              if (linkedResume != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.description_outlined, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Resume: ${linkedResume.fullName}',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms, duration: 400.ms).slideY(begin: 0.2, end: 0, duration: 400.ms);
  }

  Widget _buildStatusBadge(BuildContext context, ApplicationStatus status) {
    Color badgeColor;
    Color textColor = Colors.white;

    switch (status) {
      case ApplicationStatus.applied:
        badgeColor = Colors.blueGrey;
        break;
      case ApplicationStatus.shortlisted:
        badgeColor = Colors.orange;
        break;
      case ApplicationStatus.interviewScheduled:
        badgeColor = Colors.purple;
        break;
      case ApplicationStatus.rejected:
        badgeColor = Colors.red;
        break;
      case ApplicationStatus.selected:
        badgeColor = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.5)),
      ),
      child: Text(
        _statusToString(status).toUpperCase(),
        style: TextStyle(
          color: badgeColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static String _statusToString(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.applied:
        return 'Applied';
      case ApplicationStatus.shortlisted:
        return 'Shortlisted';
      case ApplicationStatus.interviewScheduled:
        return 'Interview';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.selected:
        return 'Selected';
    }
  }
}
