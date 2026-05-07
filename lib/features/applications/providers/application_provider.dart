import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_resume_tracker/core/services/hive_service.dart';
import 'package:smart_resume_tracker/features/applications/models/application_model.dart';

/// Represents the state of the Job Application module.
/// Contains all applications, the currently filtered applications, loading status,
/// active search queries, active status filters, and errors.
class ApplicationState {
  final bool isLoading;
  final String? error;
  final List<JobApplicationModel> allApplications;
  final List<JobApplicationModel> filteredApplications;
  final String searchQuery;
  final ApplicationStatus? filterStatus;

  const ApplicationState({
    this.isLoading = false,
    this.error,
    this.allApplications = const [],
    this.filteredApplications = const [],
    this.searchQuery = '',
    this.filterStatus,
  });

  ApplicationState copyWith({
    bool? isLoading,
    String? error,
    List<JobApplicationModel>? allApplications,
    List<JobApplicationModel>? filteredApplications,
    String? searchQuery,
    ApplicationStatus? filterStatus,
    bool clearFilterStatus = false, // Helper to properly clear the filter status
  }) {
    return ApplicationState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // Treat null as clearing the error
      allApplications: allApplications ?? this.allApplications,
      filteredApplications: filteredApplications ?? this.filteredApplications,
      searchQuery: searchQuery ?? this.searchQuery,
      filterStatus: clearFilterStatus ? null : (filterStatus ?? this.filterStatus),
    );
  }
}

/// StateNotifier that manages Job Application CRUD, Search, and Filter operations.
class ApplicationNotifier extends StateNotifier<ApplicationState> {
  ApplicationNotifier() : super(const ApplicationState()) {
    // Automatically fetch applications upon initialization
    fetchApplications();
  }

  /// Fetches all applications from the local Hive database and applies filters.
  Future<void> fetchApplications() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final fetchedApplications = HiveService.getAllItems<JobApplicationModel>(HiveService.applicationsBoxName);
      
      // Sort by date applied descending (newest first)
      fetchedApplications.sort((a, b) => b.dateApplied.compareTo(a.dateApplied));

      state = state.copyWith(
        isLoading: false,
        allApplications: fetchedApplications,
        error: null,
      );
      
      _applyFilters();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to fetch applications: ${e.toString()}",
      );
    }
  }

  /// Adds a new application to the local database and updates the state.
  Future<void> addApplication(JobApplicationModel application) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await HiveService.saveItem<JobApplicationModel>(HiveService.applicationsBoxName, application.id, application);
      
      final updatedApplications = List<JobApplicationModel>.from(state.allApplications)..add(application);
      updatedApplications.sort((a, b) => b.dateApplied.compareTo(a.dateApplied));

      state = state.copyWith(
        isLoading: false,
        allApplications: updatedApplications,
        error: null,
      );
      _applyFilters();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to add application: ${e.toString()}",
      );
    }
  }

  /// Updates the status of an existing application.
  Future<void> updateStatus(String applicationId, ApplicationStatus newStatus) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final existingApp = state.allApplications.firstWhere((app) => app.id == applicationId);
      final updatedApp = existingApp.copyWith(status: newStatus);

      await HiveService.saveItem<JobApplicationModel>(HiveService.applicationsBoxName, updatedApp.id, updatedApp);

      final updatedApplications = state.allApplications.map((app) {
        return app.id == updatedApp.id ? updatedApp : app;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        allApplications: updatedApplications,
        error: null,
      );
      _applyFilters();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to update status: ${e.toString()}",
      );
    }
  }

  /// Deletes an application from the database.
  Future<void> deleteApplication(String applicationId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await HiveService.deleteItem<JobApplicationModel>(HiveService.applicationsBoxName, applicationId);
      
      final updatedApplications = state.allApplications.where((app) => app.id != applicationId).toList();

      state = state.copyWith(
        isLoading: false,
        allApplications: updatedApplications,
        error: null,
      );
      _applyFilters();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to delete application: ${e.toString()}",
      );
    }
  }

  // ==========================================
  // Search & Filter Logic
  // ==========================================

  /// Sets the search query and re-applies filters.
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  /// Sets the status filter and re-applies filters.
  void setFilterStatus(ApplicationStatus? status) {
    state = state.copyWith(
      filterStatus: status, 
      clearFilterStatus: status == null
    );
    _applyFilters();
  }

  /// Internal method to apply active search and filters to allApplications.
  void _applyFilters() {
    final query = state.searchQuery.toLowerCase();
    final status = state.filterStatus;

    final filtered = state.allApplications.where((app) {
      // 1. Check Search Query (matches company name or job role)
      final matchesSearch = app.companyName.toLowerCase().contains(query) || 
                            app.jobRole.toLowerCase().contains(query);
      
      // 2. Check Status Filter
      final matchesStatus = status == null || app.status == status;

      return matchesSearch && matchesStatus;
    }).toList();

    state = state.copyWith(filteredApplications: filtered);
  }
}

/// Global provider for the ApplicationNotifier.
final applicationProvider = StateNotifierProvider<ApplicationNotifier, ApplicationState>((ref) {
  return ApplicationNotifier();
});
