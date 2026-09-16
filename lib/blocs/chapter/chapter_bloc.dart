import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_bite/blocs/chapter/chapter_event.dart';
import 'package:note_bite/blocs/chapter/chapter_state.dart';
import 'package:note_bite/data/models/chapter_model.dart';
import 'package:note_bite/data/repositories/course_repository.dart';
import 'package:note_bite/data/repositories/flashcard_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// BLoC managing chapter CRUD and file operations.
class ChapterBloc extends Bloc<ChapterEvent, ChapterState> {
  final FlashcardRepository _flashcardRepository;
  final CourseRepository _courseRepository;
  static const _uuid = Uuid();

  ChapterBloc({
    required FlashcardRepository flashcardRepository,
    required CourseRepository courseRepository,
  })  : _flashcardRepository = flashcardRepository,
        _courseRepository = courseRepository,
        super(const ChapterInitial()) {
    on<LoadChapters>(_onLoadChapters);
    on<AddChapter>(_onAddChapter);
    on<DeleteChapter>(_onDeleteChapter);
    on<AddFileToChapter>(_onAddFileToChapter);
    on<RemoveFileFromChapter>(_onRemoveFileFromChapter);
  }

  Future<void> _onLoadChapters(
    LoadChapters event,
    Emitter<ChapterState> emit,
  ) async {
    emit(const ChaptersLoading());
    try {
      final chapters =
          _flashcardRepository.getChaptersForCourse(event.courseId);
      emit(ChaptersLoaded(chapters: chapters, courseId: event.courseId));
    } catch (e) {
      emit(ChapterError('Failed to load chapters: $e'));
    }
  }

  Future<void> _onAddChapter(
    AddChapter event,
    Emitter<ChapterState> emit,
  ) async {
    try {
      final chapter = ChapterModel(
        id: _uuid.v4(),
        courseId: event.courseId,
        name: event.name,
        createdAt: DateTime.now(),
      );
      await _flashcardRepository.addChapter(chapter);
      await _courseRepository.addChapterToCourse(event.courseId, chapter.id);

      final chapters =
          _flashcardRepository.getChaptersForCourse(event.courseId);
      emit(ChaptersLoaded(chapters: chapters, courseId: event.courseId));
    } catch (e) {
      emit(ChapterError('Failed to add chapter: $e'));
    }
  }

  Future<void> _onDeleteChapter(
    DeleteChapter event,
    Emitter<ChapterState> emit,
  ) async {
    try {
      await _flashcardRepository.deleteChapter(event.id);
      await _courseRepository.removeChapterFromCourse(
          event.courseId, event.id);

      final chapters =
          _flashcardRepository.getChaptersForCourse(event.courseId);
      emit(ChaptersLoaded(chapters: chapters, courseId: event.courseId));
    } catch (e) {
      emit(ChapterError('Failed to delete chapter: $e'));
    }
  }

  Future<void> _onAddFileToChapter(
    AddFileToChapter event,
    Emitter<ChapterState> emit,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'md'],
      );

      if (result != null && result.files.single.path != null) {
        final pickedPath = result.files.single.path!;

        // Copy file to app documents directory for persistence
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = pickedPath.split('/').last;
        final savedPath = '${appDir.path}/note_bite_files/$fileName';

        // Create directory if it doesn't exist
        final dir = Directory('${appDir.path}/note_bite_files');
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }

        // Copy file
        await File(pickedPath).copy(savedPath);

        // Save the path reference in Hive
        await _flashcardRepository.addFileToChapter(
            event.chapterId, savedPath);

        final chapters =
            _flashcardRepository.getChaptersForCourse(event.courseId);
        emit(ChaptersLoaded(chapters: chapters, courseId: event.courseId));
      }
    } catch (e) {
      emit(ChapterError('Failed to add file: $e'));
    }
  }

  Future<void> _onRemoveFileFromChapter(
    RemoveFileFromChapter event,
    Emitter<ChapterState> emit,
  ) async {
    try {
      await _flashcardRepository.removeFileFromChapter(
          event.chapterId, event.filePath);

      final chapters =
          _flashcardRepository.getChaptersForCourse(event.courseId);
      emit(ChaptersLoaded(chapters: chapters, courseId: event.courseId));
    } catch (e) {
      emit(ChapterError('Failed to remove file: $e'));
    }
  }
}
