import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'application_model.g.dart';

/// Enum representing the current status of a job application.
/// Uses HiveType for database serialization.
@HiveType(typeId: 1)
enum ApplicationStatus {
  @HiveField(0)
  applied,

  @HiveField(1)
  shortlisted,

  @HiveField(2)
  interviewScheduled,

  @HiveField(3)
  rejected,

  @HiveField(4)
  selected,
}

/// A Hive data model representing a Job Application.
/// Uses HiveType annotation for Hive database generation.
@HiveType(typeId: 2)
class JobApplicationModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String companyName;

  @HiveField(2)
  final String jobRole;

  @HiveField(3)
  final DateTime dateApplied;

  @HiveField(4)
  final String resumeId; // Links to a ResumeModel ID

  @HiveField(5)
  final ApplicationStatus status;

  @HiveField(6)
  final String? notes;

  @HiveField(7)
  final bool synced; // Indicates if the record is synced with Firebase

  @HiveField(8)
  final DateTime createdAt;

  JobApplicationModel({
    String? id, // Optional, generates a new UUID if not provided
    required this.companyName,
    required this.jobRole,
    required this.dateApplied,
    required this.resumeId,
    required this.status,
    this.notes,
    this.synced = false,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  factory JobApplicationModel.fromJson(Map<String, dynamic> json) {
    return JobApplicationModel(
      id: json['id'] as String?,
      companyName: json['companyName'] as String,
      jobRole: json['jobRole'] as String,
      dateApplied: DateTime.parse(json['dateApplied'] as String),
      resumeId: json['resumeId'] as String,
      status: ApplicationStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => ApplicationStatus.applied,
      ),
      notes: json['notes'] as String?,
      synced: json['synced'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'jobRole': jobRole,
      'dateApplied': dateApplied.toIso8601String(),
      'resumeId': resumeId,
      'status': status.toString(),
      'notes': notes,
      'synced': synced,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy of this JobApplicationModel with the given fields replaced with the new values.
  JobApplicationModel copyWith({
    String? id,
    String? companyName,
    String? jobRole,
    DateTime? dateApplied,
    String? resumeId,
    ApplicationStatus? status,
    String? notes,
    bool? synced,
    DateTime? createdAt,
  }) {
    return JobApplicationModel(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      jobRole: jobRole ?? this.jobRole,
      dateApplied: dateApplied ?? this.dateApplied,
      resumeId: resumeId ?? this.resumeId,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      synced: synced ?? this.synced,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
