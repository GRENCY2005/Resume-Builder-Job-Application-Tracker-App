import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_resume_tracker/core/services/hive_service.dart';
import 'package:smart_resume_tracker/core/services/sync_service.dart';
import 'package:smart_resume_tracker/core/theme/app_theme.dart';
import 'package:smart_resume_tracker/routes/app_router.dart';
import 'package:smart_resume_tracker/core/providers/theme_provider.dart';

void main() async {
  // 1. Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase
  // Uncomment and configure with flutterfire cli later.
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // For now, we wrap in try-catch to allow app to run before flutterfire configure
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase initialization failed or not configured: $e");
  }

  // 3. Initialize Hive and open boxes via HiveService
  await HiveService.init();

  // 4. Initialize Background Sync Service
  SyncService.initialize();

  // 5. Run the app, wrapped in ProviderScope for Riverpod
  runApp(
    const ProviderScope(
      child: SmartResumeTrackerApp(),
    ),
  );
}

class SmartResumeTrackerApp extends ConsumerWidget {
  const SmartResumeTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Smart Resume Tracker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
