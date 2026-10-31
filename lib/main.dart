import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pocket_notes/core/constants/app_constants.dart';
import 'package:pocket_notes/core/services/sync_notification_service.dart';
import 'package:pocket_notes/core/providers/storage_provider.dart';
import 'package:pocket_notes/core/providers/theme_provider.dart';
import 'package:pocket_notes/core/router/app_router.dart';
import 'package:pocket_notes/features/notes/data/local/hive_notes_storage.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/password_vault_gate.dart';
import 'package:pocket_notes/features/notes/providers/notes_offline_provider.dart';
import 'package:pocket_notes/features/notes/providers/notes_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await Hive.initFlutter();

  final sharedPrefs = await SharedPreferences.getInstance();
  final hiveStorage = await HiveNotesStorage.open();
  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  await SyncNotificationService(notificationsPlugin).initialize();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        hiveNotesStorageProvider.overrideWithValue(hiveStorage),
        syncNotificationsPluginProvider.overrideWithValue(notificationsPlugin),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(notesBackgroundSyncProvider);

    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: ref.watch(lightThemeProvider),
      darkTheme: ref.watch(darkThemeProvider),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        return PasswordVaultGate(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
