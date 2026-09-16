import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_bite/app/theme/app_colors.dart';
import 'package:note_bite/blocs/chapter/chapter_bloc.dart';
import 'package:note_bite/blocs/chapter/chapter_state.dart';
import 'package:note_bite/blocs/flashcard/flashcard_bloc.dart';
import 'package:note_bite/blocs/flashcard/flashcard_event.dart';
import 'package:note_bite/blocs/flashcard/flashcard_state.dart';
import 'package:note_bite/ui/widgets/empty_state.dart';
import 'package:note_bite/ui/widgets/flashcard_stack.dart';
import 'package:note_bite/ui/widgets/retro_app_bar.dart';
import 'package:note_bite/ui/widgets/scanner_loading.dart';

/// Flashcard screen showing the interactive 3D flashcard deck.
///
/// Features physics-based swiping, 3D flip animation, inline editing,
/// and the retro scanner loading animation during AI generation.
class FlashcardScreen extends StatefulWidget {
  final String courseId;
  final String chapterId;

  const FlashcardScreen({
    super.key,
    required this.courseId,
    required this.chapterId,
  });

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    context.read<FlashcardBloc>().add(LoadFlashcards(widget.chapterId));
  }

  String get _chapterName {
    final chapterState = context.read<ChapterBloc>().state;
    if (chapterState is ChaptersLoaded) {
      final chapter = chapterState.chapters
          .where((ch) => ch.id == widget.chapterId)
          .firstOrNull;
      return chapter?.name ?? 'Chapter';
    }
    return 'Chapter';
  }

  List<String> get _chapterFiles {
    final chapterState = context.read<ChapterBloc>().state;
    if (chapterState is ChaptersLoaded) {
      final chapter = chapterState.chapters
          .where((ch) => ch.id == widget.chapterId)
          .firstOrNull;
      return chapter?.filePaths ?? [];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RetroAppBar(
        title: _chapterName,
        katakanaSubtitle: 'フラッシュカード',
        showBack: true,
        onBack: () => context.go('/course/${widget.courseId}'),
        actions: [
          // Add manual flashcard
          GestureDetector(
            onTap: _showAddFlashcardDialog,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.indigo, width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.indigo,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Generate from AI
          GestureDetector(
            onTap: _showGenerateOptions,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.wasabi.withValues(alpha: 0.15),
                border: Border.all(color: AppColors.wasabi, width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.wasabi,
                size: 18,
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<FlashcardBloc, FlashcardState>(
        listener: (context, state) {
          if (state is FlashcardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is FlashcardsLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.indigo,
                strokeWidth: 2,
              ),
            );
          }

          if (state is FlashcardsGenerating) {
            return const ScannerLoading(
              message: 'Generating flashcards with AI...',
            );
          }

          if (state is FlashcardsLoaded) {
            if (state.flashcards.isEmpty) {
              return EmptyState(
                icon: Icons.style_outlined,
                title: 'No flashcards yet',
                katakana: 'カードがありません',
                subtitle:
                    'Add flashcards manually or generate\nthem from a document using AI.',
                actionLabel: 'Add Flashcard',
                onAction: _showAddFlashcardDialog,
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: FlashcardStack(
                flashcards: state.flashcards,
                editingIndex: _editingIndex,
                onToggleEdit: (index) {
                  setState(() {
                    if (_editingIndex == index) {
                      _editingIndex = null;
                    } else {
                      _editingIndex = index;
                    }
                  });
                },
                onCardUpdated: (index, front, back) {
                  final card = state.flashcards[index];
                  context.read<FlashcardBloc>().add(
                        UpdateFlashcard(
                          id: card.id,
                          chapterId: widget.chapterId,
                          frontText: front,
                          backText: back,
                        ),
                      );
                },
                onCardDeleted: (index) {
                  final card = state.flashcards[index];
                  _confirmDeleteFlashcard(card.id);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Future<void> _showAddFlashcardDialog() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _AddFlashcardDialog(),
    );
    if (result != null && mounted) {
      context.read<FlashcardBloc>().add(
            AddFlashcard(
              chapterId: widget.chapterId,
              frontText: result['front']!,
              backText: result['back']!,
            ),
          );
    }
  }

  void _showGenerateOptions() {
    final files = _chapterFiles;
    if (files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No files in this chapter. Add a document first.',
            style: GoogleFonts.andika(color: AppColors.cream),
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: AppColors.indigo, width: 1.5),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Generate from file',
                style: GoogleFonts.andika(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.indigo,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'AI生成 ・ Select a document',
                style: GoogleFonts.cutiveMono(
                  fontSize: 10,
                  color: AppColors.indigoLight,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),
              ...files.map((path) {
                final fileName = path.split('/').last;
                return ListTile(
                  leading: Icon(
                    _getFileIcon(fileName),
                    color: AppColors.wasabi,
                  ),
                  title: Text(
                    fileName,
                    style: GoogleFonts.andika(color: AppColors.indigo),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.read<FlashcardBloc>().add(
                          GenerateFlashcards(
                            chapterId: widget.chapterId,
                            filePath: path,
                          ),
                        );
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteFlashcard(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.indigo, width: 1.5),
        ),
        title: Text('Delete flashcard?',
            style: GoogleFonts.andika(
                fontWeight: FontWeight.w700, color: AppColors.indigo)),
        content: Text(
          'This action cannot be undone.',
          style: GoogleFonts.andika(color: AppColors.indigoLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.andika(color: AppColors.indigo)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<FlashcardBloc>().add(
                    DeleteFlashcard(
                        id: id, chapterId: widget.chapterId),
                  );
              setState(() => _editingIndex = null);
            },
            child: Text('Delete',
                style: GoogleFonts.andika(color: AppColors.crimson)),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final ext = fileName.toLowerCase().split('.').last;
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'doc':
      case 'docx':
        return Icons.description_outlined;
      case 'txt':
      case 'md':
        return Icons.text_snippet_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }
}

/// Dialog for manually adding a flashcard with front and back text.
class _AddFlashcardDialog extends StatefulWidget {
  @override
  State<_AddFlashcardDialog> createState() => _AddFlashcardDialogState();
}

class _AddFlashcardDialogState extends State<_AddFlashcardDialog> {
  final _frontController = TextEditingController();
  final _backController = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _frontController.addListener(_validate);
    _backController.addListener(_validate);
  }

  void _validate() {
    setState(() {
      _isValid = _frontController.text.trim().isNotEmpty &&
          _backController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cream,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.indigo, width: 1.5),
      ),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppColors.retroShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'New Flashcard',
                  style: GoogleFonts.andika(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.indigo,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '新しいカード',
                  style: GoogleFonts.cutiveMono(
                    fontSize: 10,
                    color: AppColors.indigoLight,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Front text
            Text(
              'FRONT',
              style: GoogleFonts.cutiveMono(
                fontSize: 11,
                color: AppColors.crimson,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _frontController,
              autofocus: true,
              maxLines: 3,
              style: GoogleFonts.andika(
                fontSize: 14,
                color: AppColors.indigo,
              ),
              decoration: const InputDecoration(
                hintText: 'Question or term...',
              ),
            ),
            const SizedBox(height: 16),
            // Back text
            Text(
              'BACK',
              style: GoogleFonts.cutiveMono(
                fontSize: 11,
                color: AppColors.wasabi,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _backController,
              maxLines: 3,
              style: GoogleFonts.andika(
                fontSize: 14,
                color: AppColors.indigo,
              ),
              decoration: const InputDecoration(
                hintText: 'Answer or definition...',
              ),
            ),
            const SizedBox(height: 24),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppColors.indigo, width: 1.5),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.andika(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.indigo,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _isValid ? _submit : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: _isValid
                          ? AppColors.indigo
                          : AppColors.indigo.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isValid
                            ? AppColors.indigo
                            : AppColors.indigo.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: _isValid ? AppColors.retroShadowSmall : null,
                    ),
                    child: Text(
                      'Create',
                      style: GoogleFonts.andika(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cream,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    Navigator.of(context).pop({
      'front': _frontController.text.trim(),
      'back': _backController.text.trim(),
    });
  }
}
