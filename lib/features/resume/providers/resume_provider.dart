import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_resume_tracker/core/services/hive_service.dart';
import 'package:smart_resume_tracker/features/resume/models/resume_model.dart';

/// Represents the state of the Resume module.
/// Contains the list of resumes, loading status, and any potential errors.
class ResumeState {
  final bool isLoading;
  final String? error;
  final List<ResumeModel> resumes;

  const ResumeState({
    this.isLoading = false,
    this.error,
    this.resumes = const [],
  });

  ResumeState copyWith({
    bool? isLoading,
    String? error,
    List<ResumeModel>? resumes,
  }) {
    return ResumeState(
      isLoading: isLoading ?? this.isLoading,
      // If error is null in copyWith, we clear the error, so we don't default to this.error
      // Actually, passing null should clear it, so we handle it by explicitly passing null if needed, 
      // but Dart doesn't support undefined, so we use a trick or just let it be.
      // A common pattern is: error: error ?? this.error (but it can't clear).
      // We will allow clearing by passing an empty string or explicitly handling it.
      error: error,
      resumes: resumes ?? this.resumes,
    );
  }
}

/// StateNotifier that manages Resume CRUD operations and state.
class ResumeNotifier extends StateNotifier<ResumeState> {
  ResumeNotifier() : super(const ResumeState()) {
    // Automatically fetch resumes upon initialization
    fetchResumes();
  }

  /// Fetches all resumes from the local Hive database.
  Future<void> fetchResumes() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final fetchedResumes = HiveService.getAllItems<ResumeModel>(HiveService.resumesBoxName);
      state = state.copyWith(
        isLoading: false,
        resumes: fetchedResumes,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to fetch resumes: ${e.toString()}",
      );
    }
  }

  /// Adds a new resume to the local database and updates the state.
  Future<void> addResume(ResumeModel resume) async {
    state = state.copyWith(isLoading: true, error: null, resumes: state.resumes);
    try {
      await HiveService.saveItem<ResumeModel>(HiveService.resumesBoxName, resume.id, resume);
      
      // Update local state without re-fetching from DB to save resources
      final updatedResumes = List<ResumeModel>.from(state.resumes)..add(resume);
      state = state.copyWith(
        isLoading: false,
        resumes: updatedResumes,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to add resume: ${e.toString()}",
        resumes: state.resumes, // preserve existing data
      );
    }
  }

  /// Edits an existing resume in the local database and updates the state.
  Future<void> editResume(ResumeModel updatedResume) async {
    state = state.copyWith(isLoading: true, error: null, resumes: state.resumes);
    try {
      await HiveService.saveItem<ResumeModel>(HiveService.resumesBoxName, updatedResume.id, updatedResume);
      
      final updatedResumes = state.resumes.map((resume) {
        return resume.id == updatedResume.id ? updatedResume : resume;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        resumes: updatedResumes,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to update resume: ${e.toString()}",
        resumes: state.resumes,
      );
    }
  }

  /// Deletes a resume from the local database by its ID and updates the state.
  Future<void> deleteResume(String resumeId) async {
    state = state.copyWith(isLoading: true, error: null, resumes: state.resumes);
    try {
      await HiveService.deleteItem<ResumeModel>(HiveService.resumesBoxName, resumeId);
      
      final updatedResumes = state.resumes.where((resume) => resume.id != resumeId).toList();

      state = state.copyWith(
        isLoading: false,
        resumes: updatedResumes,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to delete resume: ${e.toString()}",
        resumes: state.resumes,
      );
    }
  }
}

/// Global provider for the ResumeNotifier.
final resumeProvider = StateNotifierProvider<ResumeNotifier, ResumeState>((ref) {
  return ResumeNotifier();
});
