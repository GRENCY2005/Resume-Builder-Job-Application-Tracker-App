import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../applications/models/application_model.dart';
import '../../applications/providers/application_provider.dart';
import '../../resume/providers/resume_provider.dart';

class SearchFilterScreen extends ConsumerStatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  ConsumerState<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends ConsumerState<SearchFilterScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  ApplicationStatus? _selectedStatus;
  String? _selectedResumeId;
  DateTimeRange? _selectedDateRange;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatus = null;
      _selectedResumeId = null;
      _selectedDateRange = null;
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    );
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange ?? initialDateRange,
    );

    if (pickedRange != null) {
      setState(() {
        _selectedDateRange = pickedRange;
      });
    }
  }

  List<JobApplicationModel> _getFilteredApplications() {
    final allApps = ref.watch(applicationProvider).allApplications;
    final query = _searchController.text.toLowerCase().trim();

    return allApps.where((app) {
      // 1. Search Query (Company or Role)
      final matchesSearch = query.isEmpty ||
          app.companyName.toLowerCase().contains(query) ||
          app.jobRole.toLowerCase().contains(query);

      // 2. Status Filter
      final matchesStatus = _selectedStatus == null || app.status == _selectedStatus;

      // 3. Resume Filter
      final matchesResume = _selectedResumeId == null || app.resumeId == _selectedResumeId;

      // 4. Date Range Filter
      bool matchesDate = true;
      if (_selectedDateRange != null) {
        // Normalize dates to start of day for accurate comparison
        final appDate = DateTime(app.dateApplied.year, app.dateApplied.month, app.dateApplied.day);
        final startDate = DateTime(_selectedDateRange!.start.year, _selectedDateRange!.start.month, _selectedDateRange!.start.day);
        final endDate = DateTime(_selectedDateRange!.end.year, _selectedDateRange!.end.month, _selectedDateRange!.end.day);
        
        matchesDate = (appDate.isAtSameMomentAs(startDate) || appDate.isAfter(startDate)) &&
                      (appDate.isAtSameMomentAs(endDate) || appDate.isBefore(endDate));
      }

      return matchesSearch && matchesStatus && matchesResume && matchesDate;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredApps = _getFilteredApplications();
    final resumes = ref.watch(resumeProvider).resumes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search & Filter'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear Filters',
            onPressed: _clearFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Filters Section ---
          Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() {}), // Trigger rebuild for live search
                  decoration: InputDecoration(
                    hintText: 'Search company or job role...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Horizontal scrollable filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Status Filter Chips
                      PopupMenuButton<ApplicationStatus?>(
                        onSelected: (status) => setState(() => _selectedStatus = status),
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: null, child: Text('All Statuses')),
                          ...ApplicationStatus.values.map((s) => PopupMenuItem(
                                value: s,
                                child: Text(_statusToString(s)),
                              )),
                        ],
                        child: Chip(
                          label: Text(_selectedStatus != null ? _statusToString(_selectedStatus!) : 'Any Status'),
                          deleteIcon: _selectedStatus != null ? const Icon(Icons.close, size: 16) : const Icon(Icons.arrow_drop_down),
                          onDeleted: _selectedStatus != null ? () => setState(() => _selectedStatus = null) : null,
                          backgroundColor: _selectedStatus != null ? Theme.of(context).colorScheme.primaryContainer : null,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Resume Filter Dropdown-like Chip
                      PopupMenuButton<String?>(
                        onSelected: (id) => setState(() => _selectedResumeId = id),
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: null, child: Text('All Resumes')),
                          ...resumes.map((r) => PopupMenuItem(
                                value: r.id,
                                child: Text(r.fullName),
                              )),
                        ],
                        child: Chip(
                          label: Text(_selectedResumeId != null 
                              ? resumes.firstWhere((r) => r.id == _selectedResumeId, orElse: () => resumes.first).fullName 
                              : 'Any Resume'),
                          deleteIcon: _selectedResumeId != null ? const Icon(Icons.close, size: 16) : const Icon(Icons.arrow_drop_down),
                          onDeleted: _selectedResumeId != null ? () => setState(() => _selectedResumeId = null) : null,
                          backgroundColor: _selectedResumeId != null ? Theme.of(context).colorScheme.primaryContainer : null,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Date Range Filter Chip
                      ActionChip(
                        label: Text(_selectedDateRange != null
                            ? '${DateFormat('MMM d').format(_selectedDateRange!.start)} - ${DateFormat('MMM d').format(_selectedDateRange!.end)}'
                            : 'Date Range'),
                        avatar: const Icon(Icons.date_range, size: 16),
                        onPressed: () => _selectDateRange(context),
                        backgroundColor: _selectedDateRange != null ? Theme.of(context).colorScheme.primaryContainer : null,
                      ),
                      if (_selectedDateRange != null) ...[
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () => setState(() => _selectedDateRange = null),
                        )
                      ]
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- Results Section ---
          Expanded(
            child: filteredApps.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 80, color: Theme.of(context).colorScheme.outline),
                        const SizedBox(height: 16),
                        Text('No results found.', style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredApps.length,
                    itemBuilder: (context, index) {
                      final app = filteredApps[index];
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                        ),
                        child: ListTile(
                          title: Text(app.companyName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${app.jobRole}\nApplied: ${DateFormat('MMM dd, yyyy').format(app.dateApplied)}'),
                          isThreeLine: true,
                          trailing: _buildStatusBadge(context, app.status),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, ApplicationStatus status) {
    Color badgeColor;
    switch (status) {
      case ApplicationStatus.applied: badgeColor = Colors.blueGrey; break;
      case ApplicationStatus.shortlisted: badgeColor = Colors.orange; break;
      case ApplicationStatus.interviewScheduled: badgeColor = Colors.purple; break;
      case ApplicationStatus.rejected: badgeColor = Colors.red; break;
      case ApplicationStatus.selected: badgeColor = Colors.green; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.5)),
      ),
      child: Text(
        _statusToString(status),
        style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _statusToString(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.applied: return 'Applied';
      case ApplicationStatus.shortlisted: return 'Shortlisted';
      case ApplicationStatus.interviewScheduled: return 'Interview';
      case ApplicationStatus.rejected: return 'Rejected';
      case ApplicationStatus.selected: return 'Selected';
    }
  }
}
