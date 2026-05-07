import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/resume_model.dart';
import '../providers/resume_provider.dart';
import '../../../core/widgets/shared_components.dart';
import '../widgets/resume_card.dart';

class ResumeListScreen extends ConsumerWidget {
  const ResumeListScreen({super.key});

  void _navigateToBuilder(BuildContext context, {ResumeModel? resume}) {
    context.push('/resumes/builder', extra: resume);
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, ResumeModel resume) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Resume?'),
        content: Text('Are you sure you want to delete ${resume.fullName}\'s resume? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              ref.read(resumeProvider.notifier).deleteResume(resume.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Resume deleted.'), backgroundColor: Colors.redAccent),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showResumePreview(BuildContext context, ResumeModel resume) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24.0),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                resume.fullName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.email_outlined, size: 16),
                  const SizedBox(width: 8),
                  Text(resume.email),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 16),
                  const SizedBox(width: 8),
                  Text(resume.phone),
                ],
              ),
              const SizedBox(height: 24),
              if (resume.objective != null && resume.objective!.isNotEmpty) ...[
                Text('Career Objective', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(resume.objective!),
                const SizedBox(height: 24),
              ],
              if (resume.skills.isNotEmpty) ...[
                Text('Skills', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: resume.skills.map((s) => Chip(label: Text(s), visualDensity: VisualDensity.compact)).toList(),
                ),
                const SizedBox(height: 24),
              ],
              if (resume.education.isNotEmpty) ...[
                Text('Education', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...resume.education.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 18)),
                      Expanded(child: Text(e)),
                    ],
                  ),
                )),
                const SizedBox(height: 24),
              ],
              if (resume.experience != null && resume.experience!.isNotEmpty) ...[
                Text('Experience', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...resume.experience!.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 18)),
                      Expanded(child: Text(e)),
                    ],
                  ),
                )),
              ],
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumeState = ref.watch(resumeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Resumes'),
        centerTitle: true,
      ),
      body: _buildBody(context, ref, resumeState),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToBuilder(context),
        icon: const Icon(Icons.add),
        label: const Text('Create Resume'),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, ResumeState state) {
    if (state.isLoading && state.resumes.isEmpty) {
      return const AppLoadingIndicator();
    }

    if (state.error != null && state.resumes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text('Error: ${state.error}'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref.read(resumeProvider.notifier).fetchResumes(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.resumes.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.description_outlined,
        title: 'No Resumes Found',
        message: 'Create your first resume to get started.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
      itemCount: state.resumes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final resume = state.resumes[index];
        return ResumeCard(
          resume: resume,
          onTap: () => _showResumePreview(context, resume),
          onEdit: () => _navigateToBuilder(context, resume: resume),
          onDelete: () => _confirmDelete(context, ref, resume),
        );
      },
    );
  }
}
