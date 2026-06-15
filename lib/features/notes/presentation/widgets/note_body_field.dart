import 'package:flutter/material.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';

class NoteBodyField extends StatelessWidget {
  const NoteBodyField({
    super.key,
    required this.controller,
    this.hintText = 'Tap here to continue',
    this.readOnly = false,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String hintText;
  final bool readOnly;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      autofocus: autofocus,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: AppColors.text,
        height: 1.6,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.gray,
          height: 1.6,
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        isDense: true,
      ),
    );
  }
}
