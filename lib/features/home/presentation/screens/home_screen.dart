import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';
import 'package:pocket_notes/core/constants/app_constants.dart';
import 'package:pocket_notes/core/constants/app_images.dart';
import 'package:pocket_notes/core/network/connectivity_service.dart';
import 'package:pocket_notes/core/providers/connectivity_provider.dart';
import 'package:pocket_notes/core/services/notes_sync_coordinator.dart';
import 'package:pocket_notes/features/home/presentation/widgets/home_app_bar.dart';
import 'package:pocket_notes/features/home/presentation/widgets/home_category_card.dart';
import 'package:pocket_notes/features/home/providers/home_category_subtitle_provider.dart';
import 'package:pocket_notes/features/notes/data/models/note_category.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/offline_notes_banner.dart';
import 'package:pocket_notes/features/notes/providers/notes_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quickNotesSubtitle = ref.watch(
      homeCategorySubtitleProvider(NoteCategory.quickNotes),
    );
    final journalSubtitle = ref.watch(
      homeCategorySubtitleProvider(NoteCategory.journal),
    );
    final shoppingSubtitle = ref.watch(
      homeCategorySubtitleProvider(NoteCategory.shoppingList),
    );
    final todoSubtitle = ref.watch(
      homeCategorySubtitleProvider(NoteCategory.todoList),
    );
    final passwordManagerSubtitle = ref.watch(
      homeCategorySubtitleProvider(NoteCategory.passwordManager),
    );

    final isOffline = ref.watch(isOfflineProvider);
    final isSyncing = ref.watch(notesSyncingProvider);
    final cacheInfo = ref.watch(notesCacheInfoProvider);
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const HomeAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              if (isOffline || isSyncing)
                OfflineNotesBanner(
                  isSyncing: isSyncing,
                  lastSyncedAt: cacheInfo?.lastSyncedAt,
                ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      HomeCategoryCard(
                        title: 'Quick Notes',
                        subtitle: quickNotesSubtitle,
                        backgroundColor: Colors.blue.shade100,
                        imageAsset: AppImages.quickNotes,
                        imageWidth: 170,
                        imageHeight: 170,
                        imageBottom: -30,
                        imageRight: -30,
                        rotation: 6.96,
                        onTap: () =>
                            context.push(AppConstants.quickNotesListRoute),
                      ),
                      const SizedBox(height: 16),
                      HomeCategoryCard(
                        title: 'Journal',
                        subtitle: journalSubtitle,
                        backgroundColor: Colors.cyan.shade100,
                        imageAsset: AppImages.journal,
                        rotation: 6.96,
                        imageWidth: 130,
                        imageHeight: 130,
                        imageBottom: -14,
                        imageRight: -8,
                        onTap: () => context.push(AppConstants.notesListRoute),
                      ),
                      const SizedBox(height: 16),
                      HomeCategoryCard(
                        title: 'Passwords',
                        subtitle: passwordManagerSubtitle,
                        backgroundColor: Colors.purple.shade100,
                        imageAsset: AppImages.passwordManager,
                        rotation: 6.98,
                        imageWidth: 140,
                        imageHeight: 140,
                        imageBottom: -20,
                        imageRight: -20,
                        onTap: () =>
                            context.push(AppConstants.passwordManagerRoute),
                      ),
                      const SizedBox(height: 16),
                      HomeCategoryCard(
                        title: 'Shopping List',
                        subtitle: shoppingSubtitle,
                        backgroundColor: Colors.orange.shade100,
                        imageAsset: AppImages.shopping,
                        imageWidth: 160,
                        imageHeight: 160,
                        imageBottom: -40,
                        imageRight: -20,
                        rotation: 6.96,
                        onTap: () =>
                            context.push(AppConstants.shoppingListRoute),
                      ),
                      const SizedBox(height: 16),
                      HomeCategoryCard(
                        title: 'To-Do List',
                        subtitle: todoSubtitle,
                        backgroundColor: Colors.green.shade100,
                        imageAsset: AppImages.toDoList,
                        imageWidth: 150,
                        imageHeight: 150,
                        imageBottom: -20,
                        imageRight: -20,
                        rotation: 6.96,
                        onTap: () => context.push(AppConstants.todoListRoute),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
