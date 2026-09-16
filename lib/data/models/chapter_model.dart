import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:note_bite/utils/hive_constants.dart';

/// Represents a chapter within a course.
/// A chapter contains file paths (PDFs/docs) and flashcard references.
class ChapterModel extends Equatable {
  final String id;
  final String courseId;
  final String name;
  final List<String> filePaths;
  final List<String> flashcardIds;
  final DateTime createdAt;

  const ChapterModel({
    required this.id,
    required this.courseId,
    required this.name,
    this.filePaths = const [],
    this.flashcardIds = const [],
    required this.createdAt,
  });

  ChapterModel copyWith({
    String? id,
    String? courseId,
    String? name,
    List<String>? filePaths,
    List<String>? flashcardIds,
    DateTime? createdAt,
  }) {
    return ChapterModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      name: name ?? this.name,
      filePaths: filePaths ?? this.filePaths,
      flashcardIds: flashcardIds ?? this.flashcardIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, courseId, name, filePaths, flashcardIds, createdAt];
}

/// Manual Hive TypeAdapter for [ChapterModel].
class ChapterModelAdapter extends TypeAdapter<ChapterModel> {
  @override
  final int typeId = HiveConstants.chapterAdapterId;

  @override
  ChapterModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return ChapterModel(
      id: fields[0] as String,
      courseId: fields[1] as String,
      name: fields[2] as String,
      filePaths: (fields[3] as List).cast<String>(),
      flashcardIds: (fields[4] as List).cast<String>(),
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ChapterModel obj) {
    writer
      ..writeByte(6) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.courseId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.filePaths)
      ..writeByte(4)
      ..write(obj.flashcardIds)
      ..writeByte(5)
      ..write(obj.createdAt);
  }
}
