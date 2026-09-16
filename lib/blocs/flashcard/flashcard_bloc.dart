import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_bite/blocs/flashcard/flashcard_event.dart';
import 'package:note_bite/blocs/flashcard/flashcard_state.dart';
import 'package:note_bite/data/models/flashcard_model.dart';
import 'package:note_bite/data/repositories/flashcard_repository.dart';
import 'package:note_bite/data/services/gemini_service.dart';
import 'package:uuid/uuid.dart';

/// BLoC managing flashcard CRUD and Gemini AI generation.
class FlashcardBloc extends Bloc<FlashcardEvent, FlashcardState> {
  final FlashcardRepository _repository;
  final GeminiService _geminiService;
  static const _uuid = Uuid();

  FlashcardBloc({
    required FlashcardRepository repository,
    required GeminiService geminiService,
  })  : _repository = repository,
        _geminiService = geminiService,
        super(const FlashcardInitial()) {
    on<LoadFlashcards>(_onLoadFlashcards);
    on<GenerateFlashcards>(_onGenerateFlashcards);
    on<AddFlashcard>(_onAddFlashcard);
    on<UpdateFlashcard>(_onUpdateFlashcard);
    on<DeleteFlashcard>(_onDeleteFlashcard);
  }

  Future<void> _onLoadFlashcards(
    LoadFlashcards event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(const FlashcardsLoading());
    try {
      final flashcards =
          _repository.getFlashcardsForChapter(event.chapterId);
      emit(FlashcardsLoaded(
          flashcards: flashcards, chapterId: event.chapterId));
    } catch (e) {
      emit(FlashcardError(
          message: 'Failed to load flashcards: $e',
          chapterId: event.chapterId));
    }
  }

  Future<void> _onGenerateFlashcards(
    GenerateFlashcards event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardsGenerating(chapterId: event.chapterId));
    try {
      final generatedCards = await _geminiService.generateFlashcards(
        filePath: event.filePath,
        chapterId: event.chapterId,
      );

      await _repository.addFlashcards(generatedCards);

      final flashcards =
          _repository.getFlashcardsForChapter(event.chapterId);
      emit(FlashcardsLoaded(
          flashcards: flashcards, chapterId: event.chapterId));
    } catch (e) {
      emit(FlashcardError(
          message: 'Failed to generate flashcards: $e',
          chapterId: event.chapterId));
    }
  }

  Future<void> _onAddFlashcard(
    AddFlashcard event,
    Emitter<FlashcardState> emit,
  ) async {
    try {
      final flashcard = FlashcardModel(
        id: _uuid.v4(),
        chapterId: event.chapterId,
        frontText: event.frontText,
        backText: event.backText,
        createdAt: DateTime.now(),
      );
      await _repository.addFlashcard(flashcard);

      final flashcards =
          _repository.getFlashcardsForChapter(event.chapterId);
      emit(FlashcardsLoaded(
          flashcards: flashcards, chapterId: event.chapterId));
    } catch (e) {
      emit(FlashcardError(
          message: 'Failed to add flashcard: $e',
          chapterId: event.chapterId));
    }
  }

  Future<void> _onUpdateFlashcard(
    UpdateFlashcard event,
    Emitter<FlashcardState> emit,
  ) async {
    try {
      final existing = _repository.getFlashcardsForChapter(event.chapterId)
          .where((fc) => fc.id == event.id)
          .firstOrNull;

      if (existing != null) {
        final updated = existing.copyWith(
          frontText: event.frontText,
          backText: event.backText,
        );
        await _repository.updateFlashcard(updated);

        final flashcards =
            _repository.getFlashcardsForChapter(event.chapterId);
        emit(FlashcardsLoaded(
            flashcards: flashcards, chapterId: event.chapterId));
      }
    } catch (e) {
      emit(FlashcardError(
          message: 'Failed to update flashcard: $e',
          chapterId: event.chapterId));
    }
  }

  Future<void> _onDeleteFlashcard(
    DeleteFlashcard event,
    Emitter<FlashcardState> emit,
  ) async {
    try {
      await _repository.deleteFlashcard(event.id, event.chapterId);

      final flashcards =
          _repository.getFlashcardsForChapter(event.chapterId);
      emit(FlashcardsLoaded(
          flashcards: flashcards, chapterId: event.chapterId));
    } catch (e) {
      emit(FlashcardError(
          message: 'Failed to delete flashcard: $e',
          chapterId: event.chapterId));
    }
  }
}
