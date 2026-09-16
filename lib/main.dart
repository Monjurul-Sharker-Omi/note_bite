import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:note_bite/app/app.dart';
import 'package:note_bite/blocs/chapter/chapter_bloc.dart';
import 'package:note_bite/blocs/course/course_bloc.dart';
import 'package:note_bite/blocs/flashcard/flashcard_bloc.dart';
import 'package:note_bite/data/models/chapter_model.dart';
import 'package:note_bite/data/models/course_model.dart';
import 'package:note_bite/data/models/flashcard_model.dart';
import 'package:note_bite/data/repositories/course_repository.dart';
import 'package:note_bite/data/repositories/flashcard_repository.dart';
import 'package:note_bite/data/services/gemini_service.dart';
import 'package:note_bite/utils/hive_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Hive
  await Hive.initFlutter();

  // Register TypeAdapters
  Hive.registerAdapter(CourseModelAdapter());
  Hive.registerAdapter(ChapterModelAdapter());
  Hive.registerAdapter(FlashcardModelAdapter());

  // Open Hive boxes
  await Hive.openBox<CourseModel>(HiveConstants.coursesBox);
  await Hive.openBox<ChapterModel>(HiveConstants.chaptersBox);
  await Hive.openBox<FlashcardModel>(HiveConstants.flashcardsBox);

  // Create repositories and services
  final courseRepository = CourseRepository();
  final flashcardRepository = FlashcardRepository();
  final geminiService = GeminiService();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<CourseBloc>(
          create: (_) => CourseBloc(repository: courseRepository),
        ),
        BlocProvider<ChapterBloc>(
          create: (_) => ChapterBloc(
            flashcardRepository: flashcardRepository,
            courseRepository: courseRepository,
          ),
        ),
        BlocProvider<FlashcardBloc>(
          create: (_) => FlashcardBloc(
            repository: flashcardRepository,
            geminiService: geminiService,
          ),
        ),
      ],
      child: NoteBiteApp(),
    ),
  );
}
