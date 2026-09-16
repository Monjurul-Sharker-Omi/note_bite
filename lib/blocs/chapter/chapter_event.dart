import 'package:equatable/equatable.dart';

/// Events for the ChapterBloc.
abstract class ChapterEvent extends Equatable {
  const ChapterEvent();

  @override
  List<Object?> get props => [];
}

/// Load all chapters for a specific course.
class LoadChapters extends ChapterEvent {
  final String courseId;

  const LoadChapters(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

/// Add a new chapter to a course.
class AddChapter extends ChapterEvent {
  final String courseId;
  final String name;

  const AddChapter({required this.courseId, required this.name});

  @override
  List<Object?> get props => [courseId, name];
}

/// Delete a chapter.
class DeleteChapter extends ChapterEvent {
  final String id;
  final String courseId;

  const DeleteChapter({required this.id, required this.courseId});

  @override
  List<Object?> get props => [id, courseId];
}

/// Add a file to a chapter via file picker.
class AddFileToChapter extends ChapterEvent {
  final String chapterId;
  final String courseId;

  const AddFileToChapter({required this.chapterId, required this.courseId});

  @override
  List<Object?> get props => [chapterId, courseId];
}

/// Remove a file from a chapter.
class RemoveFileFromChapter extends ChapterEvent {
  final String chapterId;
  final String courseId;
  final String filePath;

  const RemoveFileFromChapter({
    required this.chapterId,
    required this.courseId,
    required this.filePath,
  });

  @override
  List<Object?> get props => [chapterId, courseId, filePath];
}
