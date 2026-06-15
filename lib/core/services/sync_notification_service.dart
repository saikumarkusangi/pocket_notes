import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_notes/core/utils/sync_notification_messages.dart';

class SyncNotificationService {
  SyncNotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static const _syncNotificationId = 9101;
  static const _syncChannelId = 'pocket_notes_sync_progress';
  static const _resultChannelId = 'pocket_notes_sync_result';

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _syncChannelId,
        'Note sync progress',
        description: 'Silent progress while your notes sync',
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
        showBadge: false,
      ),
    );

    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _resultChannelId,
        'Sync updates',
        description: 'When your notes finish syncing',
        importance: Importance.defaultImportance,
      ),
    );

    await android?.requestNotificationsPermission();

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await ios?.requestPermissions(alert: true, sound: true);

    _initialized = true;
  }

  Future<void> showSyncProgress({
    required int progress,
    String? message,
  }) async {
    await initialize();

    final body = message ?? SyncNotificationMessages.syncingBody(progress);
    final clampedProgress = progress.clamp(0, 100);

    await _plugin.show(
      id: _syncNotificationId,
      title: SyncNotificationMessages.syncingTitle(),
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _syncChannelId,
          'Note sync progress',
          channelDescription: 'Silent progress while your notes sync',
          importance: Importance.low,
          priority: Priority.low,
          playSound: false,
          enableVibration: false,
          onlyAlertOnce: true,
          showProgress: true,
          maxProgress: 100,
          progress: clampedProgress,
          indeterminate: clampedProgress == 0,
          ongoing: clampedProgress < 100,
          silent: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: false,
          presentSound: false,
          presentBadge: false,
          threadIdentifier: 'pocket_notes_sync',
        ),
      ),
    );
  }

  Future<void> showSyncSuccess({
    required int pushedCount,
    required int pulledCount,
    required int pendingCount,
  }) async {
    await initialize();
    await _plugin.cancel(id: _syncNotificationId);

    final body = SyncNotificationMessages.successBody(
      pushedCount: pushedCount,
      pulledCount: pulledCount,
      pendingCount: pendingCount,
    );

    await _plugin.show(
      id: _syncNotificationId,
      title: SyncNotificationMessages.successTitle(),
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _resultChannelId,
          'Sync updates',
          channelDescription: 'When your notes finish syncing',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: false,
          threadIdentifier: 'pocket_notes_sync',
        ),
      ),
    );
  }

  Future<void> showSyncFailure() async {
    await initialize();
    await _plugin.cancel(id: _syncNotificationId);

    await _plugin.show(
      id: _syncNotificationId,
      title: SyncNotificationMessages.failureTitle(),
      body: SyncNotificationMessages.failureBody(),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _resultChannelId,
          'Sync updates',
          channelDescription: 'When your notes finish syncing',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          threadIdentifier: 'pocket_notes_sync',
        ),
      ),
    );
  }

  Future<void> dismiss() => _plugin.cancel(id: _syncNotificationId);
}

final syncNotificationsPluginProvider =
    Provider<FlutterLocalNotificationsPlugin>(
      (ref) => FlutterLocalNotificationsPlugin(),
    );

final syncNotificationServiceProvider = Provider<SyncNotificationService>((
  ref,
) {
  return SyncNotificationService(ref.watch(syncNotificationsPluginProvider));
});
