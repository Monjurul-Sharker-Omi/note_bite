import 'package:equatable/equatable.dart';

/// Events for the CourseBloc.
abstract class CourseEvent extends Equatable {
  const CourseEvent();

  @override
  List<Object?> get props => [];
}

/// Load all courses from storage.
class LoadCourses extends CourseEvent {
  const LoadCourses();
}

/// Add a new course with a given name.
class AddCourse extends CourseEvent {
  final String name;

  const AddCourse(this.name);

  @override
  List<Object?> get props => [name];
}

/// Delete a course by its ID.
class DeleteCourse extends CourseEvent {
  final String id;

  const DeleteCourse(this.id);

  @override
  List<Object?> get props => [id];
}

/// Rename an existing course.
class RenameCourse extends CourseEvent {
  final String id;
  final String newName;

  const RenameCourse(this.id, this.newName);

  @override
  List<Object?> get props => [id, newName];
}
