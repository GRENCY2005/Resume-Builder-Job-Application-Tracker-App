// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JobApplicationModelAdapter extends TypeAdapter<JobApplicationModel> {
  @override
  final int typeId = 2;

  @override
  JobApplicationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JobApplicationModel(
      id: fields[0] as String?,
      companyName: fields[1] as String,
      jobRole: fields[2] as String,
      dateApplied: fields[3] as DateTime,
      resumeId: fields[4] as String,
      status: fields[5] as ApplicationStatus,
      notes: fields[6] as String?,
      synced: fields[7] as bool,
      createdAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, JobApplicationModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.companyName)
      ..writeByte(2)
      ..write(obj.jobRole)
      ..writeByte(3)
      ..write(obj.dateApplied)
      ..writeByte(4)
      ..write(obj.resumeId)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.synced)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobApplicationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ApplicationStatusAdapter extends TypeAdapter<ApplicationStatus> {
  @override
  final int typeId = 1;

  @override
  ApplicationStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ApplicationStatus.applied;
      case 1:
        return ApplicationStatus.shortlisted;
      case 2:
        return ApplicationStatus.interviewScheduled;
      case 3:
        return ApplicationStatus.rejected;
      case 4:
        return ApplicationStatus.selected;
      default:
        return ApplicationStatus.applied;
    }
  }

  @override
  void write(BinaryWriter writer, ApplicationStatus obj) {
    switch (obj) {
      case ApplicationStatus.applied:
        writer.writeByte(0);
        break;
      case ApplicationStatus.shortlisted:
        writer.writeByte(1);
        break;
      case ApplicationStatus.interviewScheduled:
        writer.writeByte(2);
        break;
      case ApplicationStatus.rejected:
        writer.writeByte(3);
        break;
      case ApplicationStatus.selected:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApplicationStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
