import 'package:flutter/material.dart';
import '../../features/applications/models/application_model.dart';

// --- Custom Text Field ---
class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const CustomTextField({
    super.key,
    this.controller,
    required this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

// --- Status Badge ---
class StatusBadge extends StatelessWidget {
  final ApplicationStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    String label;

    switch (status) {
      case ApplicationStatus.applied:
        badgeColor = Colors.blueGrey;
        label = 'Applied';
        break;
      case ApplicationStatus.shortlisted:
        badgeColor = Colors.orange;
        label = 'Shortlisted';
        break;
      case ApplicationStatus.interviewScheduled:
        badgeColor = Colors.purple;
        label = 'Interview';
        break;
      case ApplicationStatus.rejected:
        badgeColor = Colors.red;
        label = 'Rejected';
        break;
      case ApplicationStatus.selected:
        badgeColor = Colors.green;
        label = 'Selected';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.5)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: badgeColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// --- Dashboard Card ---
class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color.withOpacity(0.8),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Loading Indicator ---
class AppLoadingIndicator extends StatelessWidget {
  final String? message;

  const AppLoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: const TextStyle(color: Colors.grey)),
          ]
        ],
      ),
    );
  }
}

// --- Empty State Widget ---
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

// --- Search Bar Widget ---
class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback onClear;
  final ValueChanged<String> onChanged;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onClear,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: onClear,
              )
            : null,
      ),
    );
  }
}
