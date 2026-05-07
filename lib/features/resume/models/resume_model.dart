import 'package:hive/hive.dart';

part 'resume_model.g.dart';

/// A Hive data model representing a Resume Profile.
/// Uses HiveType annotation for Hive database generation.
@HiveType(typeId: 0)
class ResumeModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String phone;

  @HiveField(4)
  final String address;

  @HiveField(5)
  final List<String> education;

  @HiveField(6)
  final List<String> skills;

  @HiveField(7)
  final List<String>? experience;

  @HiveField(8)
  final String? objective;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final bool synced;

  ResumeModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.education,
    required this.skills,
    this.experience,
    this.objective,
    required this.createdAt,
    this.synced = false,
  });

  /// Factory constructor to create a ResumeModel from a JSON map.
  factory ResumeModel.fromJson(Map<String, dynamic> json) {
    return ResumeModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      education: List<String>.from(json['education'] ?? []),
      skills: List<String>.from(json['skills'] ?? []),
      experience: json['experience'] != null ? List<String>.from(json['experience']) : null,
      objective: json['objective'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      synced: json['synced'] as bool? ?? false,
    );
  }

  /// Converts the ResumeModel to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'education': education,
      'skills': skills,
      'experience': experience,
      'objective': objective,
      'createdAt': createdAt.toIso8601String(),
      'synced': synced,
    };
  }

  /// Creates a copy of this ResumeModel with the given fields replaced with the new values.
  ResumeModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? address,
    List<String>? education,
    List<String>? skills,
    List<String>? experience,
    String? objective,
    DateTime? createdAt,
    bool? synced,
  }) {
    return ResumeModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      education: education ?? this.education,
      skills: skills ?? this.skills,
      experience: experience ?? this.experience,
      objective: objective ?? this.objective,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
    );
  }
}
