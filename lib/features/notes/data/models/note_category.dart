import 'package:flutter/material.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';

enum NoteCategory {
  journal,
  quickNotes,
  shoppingList,
  todoList,
  passwordManager;

  String get title => switch (this) {
    NoteCategory.journal => 'Journal',
    NoteCategory.quickNotes => 'Quick Notes',
    NoteCategory.shoppingList => 'Shopping List',
    NoteCategory.todoList => 'To-Do List',
    NoteCategory.passwordManager => 'Passwords',
  };

  String get routePath => switch (this) {
    NoteCategory.journal => '/notes',
    NoteCategory.quickNotes => '/quick-notes',
    NoteCategory.shoppingList => '/shopping-list',
    NoteCategory.todoList => '/todo-list',
    NoteCategory.passwordManager => '/password-manager',
  };

  String get newEntryLabel => switch (this) {
    NoteCategory.journal => 'Start a new entry',
    NoteCategory.quickNotes => 'Add a quick note',
    NoteCategory.shoppingList => 'Add new items',
    NoteCategory.todoList => 'Add a new task',
    NoteCategory.passwordManager => 'Add a new password',
  };

  String get createTitleHint => switch (this) {
    NoteCategory.journal => 'Journal title',
    NoteCategory.quickNotes => 'Quick note title',
    NoteCategory.shoppingList => 'List name',
    NoteCategory.todoList => 'List name',
    NoteCategory.passwordManager => 'Password name',
  };

  String get createBodyHint => switch (this) {
    NoteCategory.journal => 'Tap here to continue',
    NoteCategory.quickNotes => 'Write your note...',
    NoteCategory.shoppingList => 'Add items, one per line...',
    NoteCategory.todoList => 'Add tasks, one per line...',
    NoteCategory.passwordManager => 'Add passwords, one per line...',
  };

  Color get accentColor => switch (this) {
    NoteCategory.journal => Colors.cyan,
    NoteCategory.quickNotes => Colors.blue,
    NoteCategory.shoppingList => Colors.orange,
    NoteCategory.todoList => Colors.green,
    NoteCategory.passwordManager => Colors.purple,
  };

  Color get appBarColor => switch (this) {
    NoteCategory.journal => Colors.cyan.shade400,
    NoteCategory.quickNotes => Colors.blue.shade400,
    NoteCategory.shoppingList => Colors.orange.shade400,
    NoteCategory.todoList => Colors.green.shade400,
    NoteCategory.passwordManager => Colors.purple.shade400,
  };

  Color get actionButtonColor => switch (this) {
    NoteCategory.journal => Colors.cyan.shade500,
    NoteCategory.quickNotes => Colors.blue.shade500,
    NoteCategory.shoppingList => Colors.orange.shade500,
    NoteCategory.todoList => Colors.green.shade500,
    NoteCategory.passwordManager => Colors.purple.shade500,
  };

  Color get listBackgroundColor => switch (this) {
    NoteCategory.journal => AppColors.notesListBackground,
    NoteCategory.quickNotes => const Color(0xFFF8F9FC),
    NoteCategory.shoppingList => const Color(0xFFFFF8F0),
    NoteCategory.todoList => const Color(0xFFF4FBF4),
    NoteCategory.passwordManager => const Color(0xFFF4FBF4),
  };

  Color get editorBackgroundColor => switch (this) {
    NoteCategory.journal => AppColors.noteEditorBackground,
    NoteCategory.quickNotes => const Color(0xFFFFF9C4),
    NoteCategory.shoppingList => const Color(0xFFFFF3E0),
    NoteCategory.todoList => const Color(0xFFE8F5E9),
    NoteCategory.passwordManager => const Color(0xFFF4FBF4),
  };

  static NoteCategory fromName(String? value) {
    return NoteCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => NoteCategory.journal,
    );
  }

  String get apiType => name;

  static NoteCategory fromType(String? value) {
    if (value == null || value.isEmpty) return NoteCategory.journal;

    return NoteCategory.values.firstWhere(
      (category) => category.name == value || category.apiType == value,
      orElse: () => NoteCategory.journal,
    );
  }
}
