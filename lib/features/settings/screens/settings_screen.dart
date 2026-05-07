import 'package:flutter/material.dart';
import '../../core/services/sync_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Theme Toggle Placeholder
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: const Text('Dark Mode'),
              subtitle: const Text('Toggle app theme (Coming soon)'),
              trailing: Switch(
                value: false,
                onChanged: (val) {
                  // TODO: Implement Theme Provider
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Sync Data
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.cloud_sync_outlined),
              title: const Text('Force Sync Data'),
              subtitle: const Text('Push local data to Firebase'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Starting manual sync...')),
                );
                await SyncService.syncLocalDataToFirebase();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sync completed!'), backgroundColor: Colors.green),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 16),

          // About
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('About Smart Resume Tracker'),
              subtitle: Text('Version 1.0.0'),
            ),
          ),
        ],
      ),
    );
  }
}
