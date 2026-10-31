class AppConstants {
  // App Constants
  static const String appName = 'Pocket Notes';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Pocket Notes keeps your ideas safe and within reach even when you’re offline.';
  static const String appTagline = 'Think 🤔 ➜ Write ✍️ ➜ Sync 🔄';

  // Legacy MockAPI base URL. Notes and users are stored in DB/ and
  // updated through the GitHub Contents API.
  static const String apiBaseUrl =
      'https://6a2e5b5cc9776ca6c0c486fe.mockapi.io/api/v1';

  // Storage Constants
  static const String notesStorageKey = 'notes_storage_key';
  static const String userSettingsStorageKey = 'user_settings_storage_key';
  static const String authTokenStorageKey = 'auth_token_storage_key';
  static const String userDataStorageKey = 'user_data_storage_key';
  static const String notesCacheSyncedAtKey = 'notes_cache_synced_at';
  static const String themeStorageKey = 'theme';

  // Timeout Durations
  static const Duration apiConnectTimeoutDuration = Duration(seconds: 30);
  static const Duration apiReceiveTimeoutDuration = Duration(seconds: 30);

  // Retry Constants
  static const int apiMaxRetryCount = 3;
  static const List<Duration> apiRetryDelays = [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 3),
  ];

  // Route Constants
  static const String splashRoute = '/splash';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String forgotPasswordRoute = '/forgot_password';
  static const String homeRoute = '/home';
  static const String notesListRoute = '/notes';
  static const String quickNotesListRoute = '/quick-notes';
  static const String shoppingListRoute = '/shopping-list';
  static const String todoListRoute = '/todo-list';
  static const String passwordManagerRoute = '/password-manager';
  static const String createNoteRoute = '/create_note';
  static const String noteDetailRoute = '/note_detail';
  static const String editNoteRoute = '/edit_note';
  static const String noteConflictRoute = '/note_conflict';
  static const String settingsRoute = '/settings';

  // Hive Box Names
  static const String notes = 'notes_box';
  static const String offlineSyncQueue = 'offline_sync_queue_box';
}
