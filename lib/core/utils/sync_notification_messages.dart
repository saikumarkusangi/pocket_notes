import 'dart:math';

class SyncNotificationMessages {
  SyncNotificationMessages._();

  static final _random = Random();

  static String syncingTitle() => _pick([
    'Syncing your notes',
    'Backing up your ideas',
    'Updating Pocket Notes',
    'Keeping everything in sync',
  ]);

  static String syncingBody(int progress) {
    if (progress < 25) {
      return _pick([
        'Warming up the sync engine…',
        'Getting your notes ready…',
        'Preparing a safe backup…',
      ]);
    }
    if (progress < 55) {
      return _pick([
        'Uploading your latest changes…',
        'Sending your thoughts to the cloud…',
        'Sharing your notes with the server…',
      ]);
    }
    if (progress < 90) {
      return _pick([
        'Downloading fresh updates…',
        'Pulling in your newest notes…',
        'Bringing everything up to date…',
      ]);
    }
    return _pick([
      'Almost there…',
      'Putting the finishing touches…',
      'Just a moment more…',
    ]);
  }

  static String successTitle() => _pick([
    'All synced!',
    'You\'re up to date!',
    'Notes secured!',
    'Sync complete!',
    'Boom — synced!',
  ]);

  static String successBody({
    required int pushedCount,
    required int pulledCount,
    required int pendingCount,
  }) {
    if (pushedCount > 0 && pulledCount > 0) {
      return _pick([
        '$pushedCount change(s) sent up and $pulledCount update(s) pulled down. Your ideas are everywhere now.',
        'Uploaded $pushedCount and refreshed $pulledCount notes. Pocket Notes is in perfect harmony.',
        'Cloud handshake complete — $pushedCount sent, $pulledCount received.',
      ]);
    }

    if (pushedCount > 0) {
      return _pick([
        '$pushedCount note(s) safely uploaded. Your thoughts are backed up.',
        'Your latest $pushedCount change(s) are now in the cloud. Nice work!',
        '$pushedCount update(s) sent — your ideas are protected.',
      ]);
    }

    if (pulledCount > 0) {
      return _pick([
        'Pulled $pulledCount fresh update(s). Welcome back to your notes.',
        '$pulledCount note(s) refreshed from the cloud. Everything looks current.',
        'Caught $pulledCount new change(s) from the server. You\'re all set.',
      ]);
    }

    if (pendingCount == 0) {
      return _pick([
        'Everything already matches. Your notes are snug and synced.',
        'No changes needed — you\'re perfectly in sync.',
        'All clear! Your notes are safe, synced, and ready.',

      ]);
    }

    return _pick([
      'Sync finished. Your notes are ready when you are.',
      'Your Pocket Notes are backed up and good to go.',
      'Another smooth sync in the books.',
    ]);
  }

  static String failureTitle() => _pick([
    'Sync paused',
    'Couldn\'t finish syncing',
    'Sync hit a snag',
  ]);

  static String failureBody() => _pick([
    'No worries — your notes are still safe on this device. We\'ll try again when you\'re online.',
    'Your offline notes are untouched. Sync will retry automatically.',
    'Connection hiccup? Your notes remain saved locally.',
  ]);

  static String _pick(List<String> options) =>
      options[_random.nextInt(options.length)];
}
