import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_bite/app/theme/app_colors.dart';
import 'package:note_bite/blocs/course/course_bloc.dart';
import 'package:note_bite/blocs/course/course_event.dart';
import 'package:note_bite/blocs/course/course_state.dart';
import 'package:note_bite/ui/widgets/add_dialog.dart';
import 'package:note_bite/ui/widgets/empty_state.dart';
import 'package:note_bite/ui/widgets/folder_tile.dart';
import 'package:note_bite/ui/widgets/retro_app_bar.dart';
import 'package:note_bite/ui/animations/staggered_list_animation.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Home screen showing all courses/subjects.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CourseBloc>().add(const LoadCourses());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const RetroAppBar(
        title: 'NoteBite',
        katakanaSubtitle: 'ノートバイト ・ コース',
      ),
      body: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          if (state is CoursesLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.indigo,
                strokeWidth: 2,
              ),
            );
          }

          if (state is CourseError) {
            return Center(
              child: Text(
                state.message,
                style: GoogleFonts.andika(color: AppColors.crimson),
              ),
            );
          }

          if (state is CoursesLoaded) {
            if (state.courses.isEmpty) {
              return EmptyState(
                icon: Icons.school_outlined,
                title: 'No courses yet',
                katakana: 'コースがありません',
                subtitle: 'Create your first course to start organizing\nyour study materials.',
                actionLabel: 'Create Course',
                onAction: _showAddCourseDialog,
              );
            }

            return StaggeredListAnimation(
              padding: const EdgeInsets.all(20),
              children: state.courses.map((course) {
                return FolderTile(
                  name: course.name,
                  icon: Icons.menu_book_outlined,
                  subtitle: _formatDate(course.createdAt),
                  itemCount: course.chapterIds.length,
                  itemLabel: 'chapters',
                  accentColor: AppColors.wasabi,
                  onTap: () {
                    context.go('/course/${course.id}');
                  },
                  onLongPress: () => _showCourseOptions(course.id, course.name),
                );
              }).toList(),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildFab() {
    return GestureDetector(
      onTap: _showAddCourseDialog,
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
    );
  }

  Future<void> _showAddCourseDialog() async {
    final name = await AddDialog.show(
      context,
      title: 'New Course',
      katakana: '新しいコース',
      hintText: 'e.g. Biology 101',
      confirmLabel: 'Create',
    );
    if (name != null && mounted) {
      context.read<CourseBloc>().add(AddCourse(name));
    }
  }

  void _showCourseOptions(String id, String name) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: AppColors.indigo, width: 1.5),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.andika(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.indigo,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.edit_outlined,
                    color: AppColors.indigoLight),
                title: Text('Rename',
                    style: GoogleFonts.andika(color: AppColors.indigo)),
                onTap: () {
                  Navigator.pop(context);
                  _showRenameDialog(id, name);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.delete_outline, color: AppColors.crimson),
                title: Text('Delete',
                    style: GoogleFonts.andika(color: AppColors.crimson)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(id, name);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showRenameDialog(String id, String currentName) async {
    final name = await AddDialog.show(
      context,
      title: 'Rename Course',
      katakana: '名前変更',
      hintText: currentName,
      confirmLabel: 'Rename',
    );
    if (name != null && mounted) {
      context.read<CourseBloc>().add(RenameCourse(id, name));
    }
  }

  void _confirmDelete(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.indigo, width: 1.5),
        ),
        title: Text('Delete "$name"?',
            style: GoogleFonts.andika(
                fontWeight: FontWeight.w700, color: AppColors.indigo)),
        content: Text(
          'This will permanently delete this course and all its chapters and flashcards.',
          style: GoogleFonts.andika(color: AppColors.indigoLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.andika(color: AppColors.indigo)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              this.context.read<CourseBloc>().add(DeleteCourse(id));
            },
            child: Text('Delete',
                style: GoogleFonts.andika(color: AppColors.crimson)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
