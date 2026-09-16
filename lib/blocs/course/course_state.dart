import 'package:equatable/equatable.dart';
import 'package:note_bite/data/models/course_model.dart';

/// States for the CourseBloc.
abstract class CourseState extends Equatable {
  const CourseState();

  @override
  List<Object?> get props => [];
}

/// Initial state before courses are loaded.
class CourseInitial extends CourseState {
  const CourseInitial();
}

/// Courses are being loaded from storage.
class CoursesLoading extends CourseState {
  const CoursesLoading();
}

/// Courses loaded successfully.
class CoursesLoaded extends CourseState {
  final List<CourseModel> courses;

  const CoursesLoaded(this.courses);

  @override
  List<Object?> get props => [courses];
}

/// An error occurred while performing a course operation.
class CourseError extends CourseState {
  final String message;

  const CourseError(this.message);

  @override
  List<Object?> get props => [message];
}
