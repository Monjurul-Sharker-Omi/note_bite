import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:note_bite/utils/hive_constants.dart';

/// Represents a course/subject in the study hierarchy.
/// A course contains multiple chapters.
class CourseModel extends Equatable {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<String> chapterIds;

  const CourseModel({
    required this.id,
    required this.name,
    required this.createdAt,
    this.chapterIds = const [],
  });

  CourseModel copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    List<String>? chapterIds,
  }) {
    return CourseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      chapterIds: chapterIds ?? this.chapterIds,
    );
  }

  @override
  List<Object?> get props => [id, name, createdAt, chapterIds];
}

/// Manual Hive TypeAdapter for [CourseModel].
class CourseModelAdapter extends TypeAdapter<CourseModel> {
  @override
  final int typeId = HiveConstants.courseAdapterId;

  @override
  CourseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return CourseModel(
      id: fields[0] as String,
      name: fields[1] as String,
      createdAt: fields[2] as DateTime,
      chapterIds: (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, CourseModel obj) {
    writer
      ..writeByte(4) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.chapterIds);
  }
}
