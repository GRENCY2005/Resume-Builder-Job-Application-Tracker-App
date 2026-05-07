import 'package:flutter/material.dart';
import '../models/resume_model.dart';

class ResumeCard extends StatelessWidget {
  final ResumeModel resume;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ResumeCard({
    super.key,
    required this.resume,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
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
                      resume.fullName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onEdit != null)
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          color: Theme.of(context).colorScheme.primary,
                          tooltip: 'Edit',
                          onPressed: onEdit,
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: Theme.of(context).colorScheme.error,
                          tooltip: 'Delete',
                          onPressed: onDelete,
                        ),
                    ],
                  ),
                ],
              ),
              Text(resume.email, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 12),
              if (resume.skills.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: resume.skills.take(3).map((s) => Chip(
                    label: Text(s, style: const TextStyle(fontSize: 12)),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  )).toList()
                    ..addAll(resume.skills.length > 3 ? [Chip(label: Text('+${resume.skills.length - 3}', style: const TextStyle(fontSize: 12)), visualDensity: VisualDensity.compact)] : []),
                )
              else
                const Text('No skills added', style: TextStyle(fontStyle: FontStyle.italic)),
            ],
          ),
        ),
      ),
    );
  }
}
