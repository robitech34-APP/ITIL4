// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExamResultAdapter extends TypeAdapter<ExamResult> {
  @override
  final int typeId = 0;

  @override
  ExamResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExamResult(
      score: fields[0] as int,
      totalQuestions: fields[1] as int,
      timeTakenSeconds: fields[2] as int,
      date: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ExamResult obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.score)
      ..writeByte(1)
      ..write(obj.totalQuestions)
      ..writeByte(2)
      ..write(obj.timeTakenSeconds)
      ..writeByte(3)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
