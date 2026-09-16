import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:note_bite/app/theme/app_theme.dart';
import 'package:note_bite/ui/screens/chapter_screen.dart';
import 'package:note_bite/ui/screens/flashcard_screen.dart';
import 'package:note_bite/ui/screens/home_screen.dart';

/// The root app widget with GoRouter configuration and theme.
class NoteBiteApp extends StatelessWidget {
  NoteBiteApp({super.key});

  final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/course/:courseId',
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          return ChapterScreen(courseId: courseId);
        },
      ),
      GoRoute(
        path: '/course/:courseId/chapter/:chapterId',
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          final chapterId = state.pathParameters['chapterId']!;
          return FlashcardScreen(
            courseId: courseId,
            chapterId: chapterId,
          );
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NoteBite',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: _router,
    );
  }
}
