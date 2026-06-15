import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_notes/core/constants/app_constants.dart';
import 'package:pocket_notes/core/router/error_screen.dart';
import 'package:pocket_notes/features/auth/presentation/screens/login_screen.dart';
import 'package:pocket_notes/features/auth/providers/auth_provider.dart';
import 'package:pocket_notes/features/home/presentation/screens/home_screen.dart';
import 'package:pocket_notes/features/notes/data/models/note_category.dart';
import 'package:pocket_notes/features/notes/presentation/screens/create_note_screen.dart';
import 'package:pocket_notes/features/notes/presentation/screens/note_conflict_screen.dart';
import 'package:pocket_notes/features/notes/presentation/screens/note_detail_screen.dart';
import 'package:pocket_notes/features/notes/presentation/screens/notes_list_screen.dart';
import 'package:pocket_notes/features/splash/presentation/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppConstants.splashRoute,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final isLoggedIn = ref.read(authProvider).isAuthenticated;
      final isGoingToLogin = state.matchedLocation == AppConstants.loginRoute;
      final isGoingToSplash = state.matchedLocation == AppConstants.splashRoute;

      if (isLoggedIn && isGoingToLogin) {
        return AppConstants.homeRoute;
      }

      if (!isLoggedIn && !isGoingToLogin && !isGoingToSplash) {
        return AppConstants.loginRoute;
      }

      return null;
    },
    routes: [
      // Splash Route
      GoRoute(
        path: AppConstants.splashRoute,
        builder: (context, state) => const SplashScreen(),
      ),
      // Login Route
      GoRoute(
        path: AppConstants.loginRoute,
        builder: (context, state) => const LoginScreen(),
      ),
      // Home Route
      GoRoute(
        path: AppConstants.homeRoute,
        builder: (context, state) => const HomeScreen(),
      ),
      // Notes List Routes
      GoRoute(
        path: AppConstants.notesListRoute,
        builder: (context, state) => const NotesListScreen(
          category: NoteCategory.journal,
        ),
      ),
      GoRoute(
        path: AppConstants.quickNotesListRoute,
        builder: (context, state) => const NotesListScreen(
          category: NoteCategory.quickNotes,
        ),
      ),
      GoRoute(
        path: AppConstants.shoppingListRoute,
        builder: (context, state) => const NotesListScreen(
          category: NoteCategory.shoppingList,
        ),
      ),
      GoRoute(
        path: AppConstants.todoListRoute,
        builder: (context, state) => const NotesListScreen(
          category: NoteCategory.todoList,
        ),
      ),
      // Create Note Route
      GoRoute(
        path: AppConstants.createNoteRoute,
        builder: (context, state) {
          final category = NoteCategory.fromName(
            state.uri.queryParameters['category'],
          );
          return CreateNoteScreen(category: category);
        },
      ),
      // Note Detail / Edit Route
      GoRoute(
        path: '${AppConstants.noteDetailRoute}/:id',
        builder: (context, state) => NoteDetailScreen(
          noteId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '${AppConstants.editNoteRoute}/:id',
        builder: (context, state) => NoteDetailScreen(
          noteId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '${AppConstants.noteConflictRoute}/:id',
        builder: (context, state) => NoteConflictScreen(
          localId: state.pathParameters['id']!,
        ),
      ),
    ],
    errorBuilder: (context, state) => const ErrorScreen(),
  );

  ref.listen(authProvider, (_, __) => router.refresh());
  ref.onDispose(router.dispose);

  return router;
});
