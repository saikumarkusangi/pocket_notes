import 'package:flutter/material.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';

class NoteTitleField extends StatelessWidget {
  const NoteTitleField({
    super.key,
    required this.controller,
    this.hintText = 'Note title',
    this.readOnly = false,
  });

  final TextEditingController controller;
  final String hintText;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      maxLines: null,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        color: AppColors.text,
        fontWeight: FontWeight.w700,
        height: 1.3,
        fontSize: 24,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: AppColors.gray,
          fontWeight: FontWeight.w700,
          fontSize: 24,
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        isDense: true,
      ),
    );
  }
}
