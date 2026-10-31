import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';
import 'package:pocket_notes/core/constants/app_constants.dart';
import 'package:pocket_notes/features/notes/data/models/note_category.dart';
import 'package:pocket_notes/features/notes/providers/notes_provider.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/category_notes_list_body.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/notes_list_app_bar.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/offline_notes_banner.dart';

class NotesListScreen extends ConsumerWidget {
  const NotesListScreen({super.key, required this.category});

  final NoteCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesListProvider(category));
    final isOffline = ref.watch(isOfflineProvider);
    final isSyncing = ref.watch(notesSyncingProvider);
    final cacheInfo = ref.watch(notesCacheInfoProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: NotesListAppBar(title: category.title, appBarColor: Colors.white),
      body: Column(
        children: [
          if (isOffline || isSyncing)
            OfflineNotesBanner(
              isSyncing: isSyncing,
              lastSyncedAt: cacheInfo?.lastSyncedAt,
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => requestNotesSync(ref),
              child: CategoryNotesListBody(category: category, notes: notes),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        onPressed: () async {
          await context.push(
            '${AppConstants.createNoteRoute}?category=${category.name}',
          );
          bumpNotesRefresh(ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
