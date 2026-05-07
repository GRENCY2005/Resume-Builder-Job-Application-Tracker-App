import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/application_model.dart';
import '../providers/application_provider.dart';
import '../../resume/providers/resume_provider.dart';
import '../../../core/widgets/shared_components.dart';
import '../widgets/application_card.dart';

class ApplicationTrackingScreen extends ConsumerWidget {
  const ApplicationTrackingScreen({super.key});

  void _navigateToAddApplication(BuildContext context) {
    context.push('/applications/entry');
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
      return const AppLoadingIndicator();
    }

    if (state.filteredApplications.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.work_off_outlined,
        title: 'No Applications Found',
        message: 'Start tracking your job applications today.',
      ).animate().fadeIn(duration: 500.ms).scale(duration: 500.ms);
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

    return ApplicationCard(
      application: app,
      linkedResumeName: linkedResume?.fullName,
      onTap: () => _updateStatus(context, ref, app),
    ).animate().fadeIn(delay: (index * 50).ms, duration: 400.ms).slideY(begin: 0.2, end: 0, duration: 400.ms);
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
