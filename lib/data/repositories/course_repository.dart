import 'package:hive/hive.dart';
import 'package:note_bite/data/models/course_model.dart';
import 'package:note_bite/utils/hive_constants.dart';

/// Repository handling all CRUD operations for courses.
class CourseRepository {
  Box<CourseModel> get _box => Hive.box<CourseModel>(HiveConstants.coursesBox);

  /// Returns all courses sorted by creation date (newest first).
  List<CourseModel> getAllCourses() {
    final courses = _box.values.toList();
    courses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return courses;
  }

  /// Returns a single course by ID, or null if not found.
  CourseModel? getCourse(String id) {
    return _box.get(id);
  }

  /// Adds a new course to the box.
  Future<void> addCourse(CourseModel course) async {
    await _box.put(course.id, course);
  }

  /// Updates an existing course.
  Future<void> updateCourse(CourseModel course) async {
    await _box.put(course.id, course);
  }

  /// Deletes a course by ID.
  Future<void> deleteCourse(String id) async {
    await _box.delete(id);
  }

  /// Adds a chapter ID reference to a course.
  Future<void> addChapterToCourse(String courseId, String chapterId) async {
    final course = _box.get(courseId);
    if (course != null) {
      final updatedChapterIds = List<String>.from(course.chapterIds)
        ..add(chapterId);
      await _box.put(courseId, course.copyWith(chapterIds: updatedChapterIds));
    }
  }

  /// Removes a chapter ID reference from a course.
  Future<void> removeChapterFromCourse(String courseId, String chapterId) async {
    final course = _box.get(courseId);
    if (course != null) {
      final updatedChapterIds = List<String>.from(course.chapterIds)
        ..remove(chapterId);
      await _box.put(courseId, course.copyWith(chapterIds: updatedChapterIds));
    }
  }
}
