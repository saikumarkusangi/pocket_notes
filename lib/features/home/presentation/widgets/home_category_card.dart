import 'package:flutter/material.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';

class HomeCategoryCard extends StatelessWidget {
  const HomeCategoryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.imageAsset,
    this.imageWidth = 120,
    this.imageHeight = 120,
    this.imageBottom = -14,
    this.imageRight = 0,
    this.onTap,
    this.rotation = 0,
  });

  final String title;
  final String subtitle;
  final Color backgroundColor;
  final String imageAsset;
  final double imageWidth;
  final double imageHeight;
  final double imageBottom;
  final double imageRight;
  final double rotation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 140,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.border,
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade800,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: imageBottom,
              right: imageRight,
              child: RotationTransition(
                turns: AlwaysStoppedAnimation(rotation),
                child: Image.asset(
                  imageAsset,
                  width: imageWidth,
                  height: imageHeight,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
