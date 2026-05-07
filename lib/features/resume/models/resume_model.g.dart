// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resume_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ResumeModelAdapter extends TypeAdapter<ResumeModel> {
  @override
  final int typeId = 0;

  @override
  ResumeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ResumeModel(
      id: fields[0] as String,
      fullName: fields[1] as String,
      email: fields[2] as String,
      phone: fields[3] as String,
      address: fields[4] as String,
      education: (fields[5] as List).cast<String>(),
      skills: (fields[6] as List).cast<String>(),
      experience: (fields[7] as List?)?.cast<String>(),
      objective: fields[8] as String?,
      createdAt: fields[9] as DateTime,
      synced: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ResumeModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fullName)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.address)
      ..writeByte(5)
      ..write(obj.education)
      ..writeByte(6)
      ..write(obj.skills)
      ..writeByte(7)
      ..write(obj.experience)
      ..writeByte(8)
      ..write(obj.objective)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResumeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
