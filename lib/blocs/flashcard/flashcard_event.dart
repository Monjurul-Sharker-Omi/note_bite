import 'package:equatable/equatable.dart';

/// Events for the FlashcardBloc.
abstract class FlashcardEvent extends Equatable {
  const FlashcardEvent();

  @override
  List<Object?> get props => [];
}

/// Load all flashcards for a specific chapter.
class LoadFlashcards extends FlashcardEvent {
  final String chapterId;

  const LoadFlashcards(this.chapterId);

  @override
  List<Object?> get props => [chapterId];
}

/// Generate flashcards from a document using Gemini AI.
class GenerateFlashcards extends FlashcardEvent {
  final String chapterId;
  final String filePath;

  const GenerateFlashcards({required this.chapterId, required this.filePath});

  @override
  List<Object?> get props => [chapterId, filePath];
}

/// Add a single flashcard manually.
class AddFlashcard extends FlashcardEvent {
  final String chapterId;
  final String frontText;
  final String backText;

  const AddFlashcard({
    required this.chapterId,
    required this.frontText,
    required this.backText,
  });

  @override
  List<Object?> get props => [chapterId, frontText, backText];
}

/// Update flashcard text (inline editing).
class UpdateFlashcard extends FlashcardEvent {
  final String id;
  final String chapterId;
  final String frontText;
  final String backText;

  const UpdateFlashcard({
    required this.id,
    required this.chapterId,
    required this.frontText,
    required this.backText,
  });

  @override
  List<Object?> get props => [id, chapterId, frontText, backText];
}

/// Delete a flashcard.
class DeleteFlashcard extends FlashcardEvent {
  final String id;
  final String chapterId;

  const DeleteFlashcard({required this.id, required this.chapterId});

  @override
  List<Object?> get props => [id, chapterId];
}
