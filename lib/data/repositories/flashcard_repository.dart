import 'package:hive/hive.dart';
import 'package:note_bite/data/models/chapter_model.dart';
import 'package:note_bite/data/models/flashcard_model.dart';
import 'package:note_bite/utils/hive_constants.dart';

/// Repository handling CRUD for chapters and flashcards.
class FlashcardRepository {
  Box<ChapterModel> get _chapterBox =>
      Hive.box<ChapterModel>(HiveConstants.chaptersBox);

  Box<FlashcardModel> get _flashcardBox =>
      Hive.box<FlashcardModel>(HiveConstants.flashcardsBox);

  // ── Chapter Operations ──────────────────────────────────────────────

  /// Returns all chapters for a given course, sorted by creation date.
  List<ChapterModel> getChaptersForCourse(String courseId) {
    final chapters = _chapterBox.values
        .where((ch) => ch.courseId == courseId)
        .toList();
    chapters.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return chapters;
  }

  /// Returns a single chapter by ID.
  ChapterModel? getChapter(String id) {
    return _chapterBox.get(id);
  }

  /// Adds a new chapter.
  Future<void> addChapter(ChapterModel chapter) async {
    await _chapterBox.put(chapter.id, chapter);
  }

  /// Updates an existing chapter.
  Future<void> updateChapter(ChapterModel chapter) async {
    await _chapterBox.put(chapter.id, chapter);
  }

  /// Deletes a chapter and all its associated flashcards.
  Future<void> deleteChapter(String id) async {
    // Delete all flashcards in this chapter
    final chapter = _chapterBox.get(id);
    if (chapter != null) {
      for (final fcId in chapter.flashcardIds) {
        await _flashcardBox.delete(fcId);
      }
    }
    await _chapterBox.delete(id);
  }

  /// Adds a file path to a chapter.
  Future<void> addFileToChapter(String chapterId, String filePath) async {
    final chapter = _chapterBox.get(chapterId);
    if (chapter != null) {
      final updatedPaths = List<String>.from(chapter.filePaths)..add(filePath);
      await _chapterBox.put(
          chapterId, chapter.copyWith(filePaths: updatedPaths));
    }
  }

  /// Removes a file path from a chapter.
  Future<void> removeFileFromChapter(String chapterId, String filePath) async {
    final chapter = _chapterBox.get(chapterId);
    if (chapter != null) {
      final updatedPaths = List<String>.from(chapter.filePaths)
        ..remove(filePath);
      await _chapterBox.put(
          chapterId, chapter.copyWith(filePaths: updatedPaths));
    }
  }

  // ── Flashcard Operations ────────────────────────────────────────────

  /// Returns all flashcards for a given chapter, sorted by creation date.
  List<FlashcardModel> getFlashcardsForChapter(String chapterId) {
    final cards = _flashcardBox.values
        .where((fc) => fc.chapterId == chapterId)
        .toList();
    cards.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return cards;
  }

  /// Adds a flashcard and updates the parent chapter's reference list.
  Future<void> addFlashcard(FlashcardModel flashcard) async {
    await _flashcardBox.put(flashcard.id, flashcard);

    // Update chapter's flashcardIds
    final chapter = _chapterBox.get(flashcard.chapterId);
    if (chapter != null) {
      final updatedIds = List<String>.from(chapter.flashcardIds)
        ..add(flashcard.id);
      await _chapterBox.put(
          flashcard.chapterId, chapter.copyWith(flashcardIds: updatedIds));
    }
  }

  /// Adds multiple flashcards at once (used after Gemini generation).
  Future<void> addFlashcards(List<FlashcardModel> flashcards) async {
    for (final fc in flashcards) {
      await _flashcardBox.put(fc.id, fc);
    }

    if (flashcards.isNotEmpty) {
      final chapterId = flashcards.first.chapterId;
      final chapter = _chapterBox.get(chapterId);
      if (chapter != null) {
        final updatedIds = List<String>.from(chapter.flashcardIds)
          ..addAll(flashcards.map((fc) => fc.id));
        await _chapterBox.put(
            chapterId, chapter.copyWith(flashcardIds: updatedIds));
      }
    }
  }

  /// Updates a flashcard's text.
  Future<void> updateFlashcard(FlashcardModel flashcard) async {
    await _flashcardBox.put(flashcard.id, flashcard);
  }

  /// Deletes a flashcard and removes it from the parent chapter.
  Future<void> deleteFlashcard(String flashcardId, String chapterId) async {
    await _flashcardBox.delete(flashcardId);

    final chapter = _chapterBox.get(chapterId);
    if (chapter != null) {
      final updatedIds = List<String>.from(chapter.flashcardIds)
        ..remove(flashcardId);
      await _chapterBox.put(
          chapterId, chapter.copyWith(flashcardIds: updatedIds));
    }
  }
}
