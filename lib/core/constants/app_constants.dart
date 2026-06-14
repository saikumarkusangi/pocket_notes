class AppConstants {

    // App Constants
    static const String appName = 'Pocket Notes';
    static const String appVersion = '1.0.0';
    static const String appDescription = 'A simple offline first note-taking app to keep your thoughts organized.';

    // API Constants
    static const String apiBaseUrl = 'https://api.pocketnotes.com';

    // Storage Constants
    static const String notesStorageKey = 'notes_storage_key';
    static const String userSettingsStorageKey = 'user_settings_storage_key';
    static const String authTokenStorageKey = 'auth_token_storage_key';
    static const String userDataStorageKey = 'user_data_storage_key';

    // Timeout Durations
    static const Duration apiConnectTimeoutDuration = Duration(seconds: 30);
    static const Duration apiReceiveTimeoutDuration = Duration(seconds: 30);
    
    // Route Constants
    staic const String splashRoute = '/splash';
    static const String loginRoute = '/login';
    static const String registerRoute = '/register';
    static const String forgotPasswordRoute = '/forgot_password';
    static const String homeRoute = '/home';
    static const String createNoteRoute = '/create_note';
    static const String noteDetailRoute = '/note_detail';
    static const String editNoteRoute = '/edit_note';
    static const String noteConflictRoute = '/note_conflict';
    static const String settingsRoute = '/settings';

    // Isar Box Names
    static const String notes = 'notes_box';
    static const String offlineSyncQueue = 'offline_sync_queue_box';

}