import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_resume_tracker/features/applications/models/application_model.dart';
import 'package:smart_resume_tracker/features/resume/models/resume_model.dart';

/// A central service to manage Hive database initialization and CRUD operations.
class HiveService {
  // Box Names
  static const String resumesBoxName = 'resumes';
  static const String applicationsBoxName = 'applications';

  /// Initializes Hive, registers adapters, and opens the required boxes.
  static Future<void> init() async {
    try {
      await Hive.initFlutter();

      // Register Adapters only if they haven't been registered yet
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ResumeModelAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(ApplicationStatusAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(JobApplicationModelAdapter());
      }

      // Open Boxes
      await Hive.openBox<ResumeModel>(resumesBoxName);
      await Hive.openBox<JobApplicationModel>(applicationsBoxName);
      
      debugPrint("Hive initialized and boxes opened successfully.");
    } catch (e) {
      debugPrint("Error initializing Hive: $e");
      // Re-throw or handle based on app's critical failure policy
      throw Exception("Failed to initialize local database.");
    }
  }

  // ==========================================
  // Generic CRUD Helper Methods
  // ==========================================

  /// Saves an item into the specified box with a given key.
  /// If the key already exists, it updates the existing item.
  static Future<void> saveItem<T>(String boxName, String key, T item) async {
    try {
      final box = Hive.box<T>(boxName);
      await box.put(key, item);
    } catch (e) {
      debugPrint("Error saving item to $boxName: $e");
      throw Exception("Could not save data.");
    }
  }

  /// Retrieves a single item from the specified box by its key.
  static T? getItem<T>(String boxName, String key) {
    try {
      final box = Hive.box<T>(boxName);
      return box.get(key);
    } catch (e) {
      debugPrint("Error retrieving item from $boxName: $e");
      return null;
    }
  }

  /// Retrieves all items currently stored in the specified box.
  static List<T> getAllItems<T>(String boxName) {
    try {
      final box = Hive.box<T>(boxName);
      return box.values.toList();
    } catch (e) {
      debugPrint("Error retrieving all items from $boxName: $e");
      return [];
    }
  }

  /// Deletes an item from the specified box by its key.
  static Future<void> deleteItem<T>(String boxName, String key) async {
    try {
      final box = Hive.box<T>(boxName);
      await box.delete(key);
    } catch (e) {
      debugPrint("Error deleting item from $boxName: $e");
      throw Exception("Could not delete data.");
    }
  }

  /// Clears all data within the specified box.
  static Future<void> clearBox<T>(String boxName) async {
    try {
      final box = Hive.box<T>(boxName);
      await box.clear();
    } catch (e) {
      debugPrint("Error clearing $boxName: $e");
      throw Exception("Could not clear data.");
    }
  }
}
