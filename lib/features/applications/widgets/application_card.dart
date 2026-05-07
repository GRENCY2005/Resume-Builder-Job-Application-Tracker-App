import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/application_model.dart';
import '../../../core/widgets/shared_components.dart'; // For StatusBadge

class ApplicationCard extends StatelessWidget {
  final JobApplicationModel application;
  final String? linkedResumeName;
  final VoidCallback? onTap;

  const ApplicationCard({
    super.key,
    required this.application,
    this.linkedResumeName,
    this.onTap,
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
                      application.companyName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusBadge(status: application.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                application.jobRole,
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
                    'Applied: ${DateFormat('MMM dd, yyyy').format(application.dateApplied)}',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              if (linkedResumeName != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.description_outlined, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Resume: $linkedResumeName',
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
    );
  }
}
