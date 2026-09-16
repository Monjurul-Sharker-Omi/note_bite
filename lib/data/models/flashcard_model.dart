import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:note_bite/utils/hive_constants.dart';

/// Represents a single flashcard with front and back text.
class FlashcardModel extends Equatable {
  final String id;
  final String chapterId;
  final String frontText;
  final String backText;
  final DateTime createdAt;

  const FlashcardModel({
    required this.id,
    required this.chapterId,
    required this.frontText,
    required this.backText,
    required this.createdAt,
  });

  FlashcardModel copyWith({
    String? id,
    String? chapterId,
    String? frontText,
    String? backText,
    DateTime? createdAt,
  }) {
    return FlashcardModel(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      frontText: frontText ?? this.frontText,
      backText: backText ?? this.backText,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Creates a FlashcardModel from a Gemini API JSON response map.
  factory FlashcardModel.fromGeminiJson(
    Map<String, dynamic> json, {
    required String id,
    required String chapterId,
  }) {
    return FlashcardModel(
      id: id,
      chapterId: chapterId,
      frontText: json['front'] as String? ?? '',
      backText: json['back'] as String? ?? '',
      createdAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, chapterId, frontText, backText, createdAt];
}

/// Manual Hive TypeAdapter for [FlashcardModel].
class FlashcardModelAdapter extends TypeAdapter<FlashcardModel> {
  @override
  final int typeId = HiveConstants.flashcardAdapterId;

  @override
  FlashcardModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return FlashcardModel(
      id: fields[0] as String,
      chapterId: fields[1] as String,
      frontText: fields[2] as String,
      backText: fields[3] as String,
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FlashcardModel obj) {
    writer
      ..writeByte(5) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.chapterId)
      ..writeByte(2)
      ..write(obj.frontText)
      ..writeByte(3)
      ..write(obj.backText)
      ..writeByte(4)
      ..write(obj.createdAt);
  }
}
