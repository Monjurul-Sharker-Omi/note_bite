import 'package:equatable/equatable.dart';
import 'package:note_bite/data/models/flashcard_model.dart';

/// States for the FlashcardBloc.
abstract class FlashcardState extends Equatable {
  const FlashcardState();

  @override
  List<Object?> get props => [];
}

/// Initial state before flashcards are loaded.
class FlashcardInitial extends FlashcardState {
  const FlashcardInitial();
}

/// Flashcards are being loaded from storage.
class FlashcardsLoading extends FlashcardState {
  const FlashcardsLoading();
}

/// Flashcards loaded successfully.
class FlashcardsLoaded extends FlashcardState {
  final List<FlashcardModel> flashcards;
  final String chapterId;

  const FlashcardsLoaded({required this.flashcards, required this.chapterId});

  @override
  List<Object?> get props => [flashcards, chapterId];
}

/// Flashcards are being generated via Gemini AI.
/// This triggers the scanner loading animation.
class FlashcardsGenerating extends FlashcardState {
  final String chapterId;

  const FlashcardsGenerating({required this.chapterId});

  @override
  List<Object?> get props => [chapterId];
}

/// An error occurred during a flashcard operation.
class FlashcardError extends FlashcardState {
  final String message;
  final String chapterId;

  const FlashcardError({required this.message, required this.chapterId});

  @override
  List<Object?> get props => [message, chapterId];
}
