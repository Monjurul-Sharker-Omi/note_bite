import 'package:equatable/equatable.dart';
import 'package:note_bite/data/models/chapter_model.dart';

/// States for the ChapterBloc.
abstract class ChapterState extends Equatable {
  const ChapterState();

  @override
  List<Object?> get props => [];
}

/// Initial state before chapters are loaded.
class ChapterInitial extends ChapterState {
  const ChapterInitial();
}

/// Chapters are being loaded from storage.
class ChaptersLoading extends ChapterState {
  const ChaptersLoading();
}

/// Chapters loaded successfully.
class ChaptersLoaded extends ChapterState {
  final List<ChapterModel> chapters;
  final String courseId;

  const ChaptersLoaded({required this.chapters, required this.courseId});

  @override
  List<Object?> get props => [chapters, courseId];
}

/// An error occurred during a chapter operation.
class ChapterError extends ChapterState {
  final String message;

  const ChapterError(this.message);

  @override
  List<Object?> get props => [message];
}
