import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';
import 'package:pocket_notes/core/constants/app_constants.dart';
import 'package:pocket_notes/core/constants/app_images.dart';
import 'package:pocket_notes/features/home/presentation/widgets/home_app_bar.dart';
import 'package:pocket_notes/features/home/presentation/widgets/home_category_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.notesListBackground,
      appBar: const HomeAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                // Quick Notes
                HomeCategoryCard(
                  title: 'Quick Notes',
                  subtitle: 'Last updated: 15 Jun, 26',
                  backgroundColor: Colors.blue.shade100,
                  imageAsset: AppImages.quickNotes,
                  imageWidth: 190,
                  imageHeight: 190,
                  imageBottom: -50,
                  imageRight: -40,
                  rotation: 6.96,
                ),
                SizedBox(height: 16),

                // Journal
                HomeCategoryCard(
                  title: 'Journal',
                  subtitle: 'Last updated: 15 Jun, 26',
                  backgroundColor: Colors.cyan.shade100,
                  imageAsset: AppImages.journal,
                  rotation: 6.96,
                  imageWidth: 130,
                  imageHeight: 130,
                  imageBottom: -14,
                  imageRight: -8,
                  onTap: () => context.push(AppConstants.notesListRoute),
                ),
                SizedBox(height: 16),

                // Shopping List
                HomeCategoryCard(
                  title: 'Shopping List',
                  subtitle: '2 items left',
                  backgroundColor: Colors.orange.shade100,
                  imageAsset: AppImages.shopping,
                  imageWidth: 160,
                  imageHeight: 160,
                  imageBottom: -40,
                  imageRight: -20,
                  rotation: 6.96,
                ),

                SizedBox(height: 16),

                // To-Do List
                HomeCategoryCard(
                  title: 'To-Do List',
                  subtitle: 'Last updated: 15 Jun, 26',
                  backgroundColor: Colors.green.shade100,
                  imageAsset: AppImages.toDoList,
                  imageWidth: 150,
                  imageHeight: 150,
                  imageBottom: -20,
                  imageRight: -20,
                  rotation: 6.96,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
