import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import 'hive_service.dart';
import 'firebase_service.dart';
import '../../features/resume/models/resume_model.dart';
import '../../features/applications/models/application_model.dart';

/// A background service to monitor internet connectivity and sync Hive data to Firebase.
class SyncService {
  static StreamSubscription? _connectivitySubscription;
  
  /// Initialize the connectivity listener globally.
  static void initialize() {
    // Listen for connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.mobile) || 
          results.contains(ConnectivityResult.wifi) || 
          results.contains(ConnectivityResult.ethernet)) {
        debugPrint("Internet connected. Starting background sync...");
        syncLocalDataToFirebase();
      }
    });

    // Also try an immediate sync on startup if we already have internet
    Connectivity().checkConnectivity().then((results) {
      if (results.contains(ConnectivityResult.mobile) || 
          results.contains(ConnectivityResult.wifi) || 
          results.contains(ConnectivityResult.ethernet)) {
        syncLocalDataToFirebase();
      }
    });
  }

  /// Disposes the connectivity listener
  static void dispose() {
    _connectivitySubscription?.cancel();
  }

  /// Scans Hive for unsynced data and pushes it to Firebase.
  static Future<void> syncLocalDataToFirebase() async {
    try {
      // 1. Sync Resumes
      final resumes = HiveService.getAllItems<ResumeModel>(HiveService.resumesBoxName);
      final unsyncedResumes = resumes.where((r) => !r.synced).toList();
      
      for (var resume in unsyncedResumes) {
        final success = await FirebaseService.syncResume(resume);
        if (success) {
          // Mark as synced locally
          final syncedResume = resume.copyWith(synced: true);
          await HiveService.saveItem(HiveService.resumesBoxName, syncedResume.id, syncedResume);
          debugPrint("Synced Resume: ${resume.fullName}");
        }
      }

      // 2. Sync Applications
      final apps = HiveService.getAllItems<JobApplicationModel>(HiveService.applicationsBoxName);
      final unsyncedApps = apps.where((a) => !a.synced).toList();
      
      for (var app in unsyncedApps) {
        final success = await FirebaseService.syncApplication(app);
        if (success) {
          // Mark as synced locally
          final syncedApp = app.copyWith(synced: true);
          await HiveService.saveItem(HiveService.applicationsBoxName, syncedApp.id, syncedApp);
          debugPrint("Synced App: ${app.companyName}");
        }
      }
    } catch (e) {
      debugPrint("Error during background sync: $e");
    }
  }
}
