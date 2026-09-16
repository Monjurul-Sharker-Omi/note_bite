import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_bite/app/theme/app_colors.dart';
import 'package:note_bite/blocs/chapter/chapter_bloc.dart';
import 'package:note_bite/blocs/chapter/chapter_event.dart';
import 'package:note_bite/blocs/chapter/chapter_state.dart';
import 'package:note_bite/blocs/course/course_bloc.dart';
import 'package:note_bite/blocs/course/course_state.dart';
import 'package:note_bite/data/models/chapter_model.dart';
import 'package:note_bite/ui/animations/staggered_list_animation.dart';
import 'package:note_bite/ui/widgets/add_dialog.dart';
import 'package:note_bite/ui/widgets/empty_state.dart';
import 'package:note_bite/ui/widgets/retro_app_bar.dart';
import 'package:note_bite/ui/widgets/retro_card.dart';

/// Chapter screen showing chapters within a course.
///
/// Features cascading slide-up animations, file management,
/// and navigation to the flashcard view.
class ChapterScreen extends StatefulWidget {
  final String courseId;

  const ChapterScreen({super.key, required this.courseId});

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ChapterBloc>().add(LoadChapters(widget.courseId));
  }

  String get _courseName {
    final courseState = context.read<CourseBloc>().state;
    if (courseState is CoursesLoaded) {
      final course = courseState.courses.where((c) => c.id == widget.courseId).firstOrNull;
      return course?.name ?? 'Course';
    }
    return 'Course';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RetroAppBar(
        title: _courseName,
        katakanaSubtitle: 'チャプター',
        showBack: true,
        onBack: () => context.go('/'),
      ),
      body: BlocBuilder<ChapterBloc, ChapterState>(
        builder: (context, state) {
          if (state is ChaptersLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.indigo,
                strokeWidth: 2,
              ),
            );
          }

          if (state is ChapterError) {
            return Center(
              child: Text(
                state.message,
                style: GoogleFonts.andika(color: AppColors.crimson),
              ),
            );
          }

          if (state is ChaptersLoaded) {
            if (state.chapters.isEmpty) {
              return EmptyState(
                icon: Icons.bookmark_outline,
                title: 'No chapters yet',
                katakana: 'チャプターがありません',
                subtitle:
                    'Add chapters to organize your\nstudy material and flashcards.',
                actionLabel: 'Add Chapter',
                onAction: _showAddChapterDialog,
              );
            }

            return StaggeredListAnimation(
              padding: const EdgeInsets.all(20),
              children: state.chapters.map((chapter) {
                return _buildChapterTile(chapter);
              }).toList(),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildChapterTile(ChapterModel chapter) {
    return RetroCard(
      onTap: () {
        context.go('/course/${widget.courseId}/chapter/${chapter.id}');
      },
      onLongPress: () => _showChapterOptions(chapter),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.crimson.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.crimson.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(Icons.layers_outlined,
                    color: AppColors.crimson, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chapter.name,
                      style: GoogleFonts.andika(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.indigo,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildBadge(
                          '${chapter.filePaths.length} files',
                          AppColors.wasabi,
                        ),
                        const SizedBox(width: 8),
                        _buildBadge(
                          '${chapter.flashcardIds.length} cards',
                          AppColors.crimson,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.indigoLight,
                size: 22,
              ),
            ],
          ),
          // File list (collapsed preview)
          if (chapter.filePaths.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.indigo.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: chapter.filePaths.take(3).map((path) {
                  final fileName = path.split('/').last;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Icon(
                          _getFileIcon(fileName),
                          size: 14,
                          color: AppColors.indigoLight,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            fileName,
                            style: GoogleFonts.cutiveMono(
                              fontSize: 10,
                              color: AppColors.indigoLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.cutiveMono(
          fontSize: 9,
          fontWeight: FontWeight.w500,
          color: color,
          letterSpacing: 0.5,
        ),
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

  Widget _buildFab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Add file FAB
        GestureDetector(
          onTap: _showAddOptions,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.indigo,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.indigo, width: 1.5),
              boxShadow: AppColors.retroShadow,
            ),
            child: const Icon(
              Icons.add,
              color: AppColors.cream,
              size: 26,
            ),
          ),
        ),
      ],
    );
  }

  void _showAddOptions() {
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
                'Add to $_courseName',
                style: GoogleFonts.andika(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.indigo,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '追加',
                style: GoogleFonts.cutiveMono(
                  fontSize: 10,
                  color: AppColors.indigoLight,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.create_new_folder_outlined,
                    color: AppColors.wasabi),
                title: Text('New Chapter',
                    style: GoogleFonts.andika(color: AppColors.indigo)),
                subtitle: Text('Create a new chapter folder',
                    style: GoogleFonts.andika(
                        fontSize: 12, color: AppColors.indigoLight)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddChapterDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAddChapterDialog() async {
    final name = await AddDialog.show(
      context,
      title: 'New Chapter',
      katakana: '新しいチャプター',
      hintText: 'e.g. Chapter 1 - Introduction',
      confirmLabel: 'Create',
    );
    if (name != null && mounted) {
      context.read<ChapterBloc>().add(
            AddChapter(courseId: widget.courseId, name: name),
          );
    }
  }

  void _showChapterOptions(ChapterModel chapter) {
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
                chapter.name,
                style: GoogleFonts.andika(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.indigo,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.attach_file_outlined,
                    color: AppColors.wasabi),
                title: Text('Add File',
                    style: GoogleFonts.andika(color: AppColors.indigo)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<ChapterBloc>().add(
                        AddFileToChapter(
                          chapterId: chapter.id,
                          courseId: widget.courseId,
                        ),
                      );
                },
              ),
              ListTile(
                leading: const Icon(Icons.style_outlined,
                    color: AppColors.indigo),
                title: Text('View Flashcards',
                    style: GoogleFonts.andika(color: AppColors.indigo)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.go(
                      '/course/${widget.courseId}/chapter/${chapter.id}');
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline,
                    color: AppColors.crimson),
                title: Text('Delete Chapter',
                    style: GoogleFonts.andika(color: AppColors.crimson)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDeleteChapter(chapter);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteChapter(ChapterModel chapter) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.indigo, width: 1.5),
        ),
        title: Text('Delete "${chapter.name}"?',
            style: GoogleFonts.andika(
                fontWeight: FontWeight.w700, color: AppColors.indigo)),
        content: Text(
          'This will delete all flashcards in this chapter.',
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
              context.read<ChapterBloc>().add(
                    DeleteChapter(
                        id: chapter.id, courseId: widget.courseId),
                  );
            },
            child: Text('Delete',
                style: GoogleFonts.andika(color: AppColors.crimson)),
          ),
        ],
      ),
    );
  }
}
