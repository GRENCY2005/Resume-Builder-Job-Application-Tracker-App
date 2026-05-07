import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../features/resume/models/resume_model.dart';
import '../../features/applications/models/application_model.dart';

/// A service to handle raw Firestore interactions.
class FirebaseService {
  static final _firestore = FirebaseFirestore.instance;
  
  // Collections
  static const String resumesCol = 'resumes';
  static const String applicationsCol = 'applications';

  /// Uploads or updates a Resume in Firestore
  static Future<bool> syncResume(ResumeModel resume) async {
    try {
      // In a real app, we would nest this under a userId.
      // For this implementation, we'll store it in a generic collection.
      await _firestore.collection(resumesCol).doc(resume.id).set(resume.toJson());
      return true;
    } catch (e) {
      debugPrint("Firebase Sync Error (Resume): $e");
      return false;
    }
  }

  /// Uploads or updates a Job Application in Firestore
  static Future<bool> syncApplication(JobApplicationModel app) async {
    try {
      await _firestore.collection(applicationsCol).doc(app.id).set(app.toJson());
      return true;
    } catch (e) {
      debugPrint("Firebase Sync Error (Application): $e");
      return false;
    }
  }
}
