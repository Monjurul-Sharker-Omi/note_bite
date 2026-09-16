import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_bite/blocs/course/course_event.dart';
import 'package:note_bite/blocs/course/course_state.dart';
import 'package:note_bite/data/models/course_model.dart';
import 'package:note_bite/data/repositories/course_repository.dart';
import 'package:uuid/uuid.dart';

/// BLoC managing course CRUD operations.
class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final CourseRepository _repository;
  static const _uuid = Uuid();

  CourseBloc({required CourseRepository repository})
      : _repository = repository,
        super(const CourseInitial()) {
    on<LoadCourses>(_onLoadCourses);
    on<AddCourse>(_onAddCourse);
    on<DeleteCourse>(_onDeleteCourse);
    on<RenameCourse>(_onRenameCourse);
  }

  Future<void> _onLoadCourses(
    LoadCourses event,
    Emitter<CourseState> emit,
  ) async {
    emit(const CoursesLoading());
    try {
      final courses = _repository.getAllCourses();
      emit(CoursesLoaded(courses));
    } catch (e) {
      emit(CourseError('Failed to load courses: $e'));
    }
  }

  Future<void> _onAddCourse(
    AddCourse event,
    Emitter<CourseState> emit,
  ) async {
    try {
      final course = CourseModel(
        id: _uuid.v4(),
        name: event.name,
        createdAt: DateTime.now(),
      );
      await _repository.addCourse(course);
      final courses = _repository.getAllCourses();
      emit(CoursesLoaded(courses));
    } catch (e) {
      emit(CourseError('Failed to add course: $e'));
    }
  }

  Future<void> _onDeleteCourse(
    DeleteCourse event,
    Emitter<CourseState> emit,
  ) async {
    try {
      await _repository.deleteCourse(event.id);
      final courses = _repository.getAllCourses();
      emit(CoursesLoaded(courses));
    } catch (e) {
      emit(CourseError('Failed to delete course: $e'));
    }
  }

  Future<void> _onRenameCourse(
    RenameCourse event,
    Emitter<CourseState> emit,
  ) async {
    try {
      final course = _repository.getCourse(event.id);
      if (course != null) {
        await _repository.updateCourse(course.copyWith(name: event.newName));
        final courses = _repository.getAllCourses();
        emit(CoursesLoaded(courses));
      }
    } catch (e) {
      emit(CourseError('Failed to rename course: $e'));
    }
  }
}
