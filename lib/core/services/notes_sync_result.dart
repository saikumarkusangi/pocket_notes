class NotesSyncResult {
  const NotesSyncResult({
    required this.pushedCount,
    required this.pulledCount,
    required this.pendingCount,
    required this.success,
  });

  final int pushedCount;
  final int pulledCount;
  final int pendingCount;
  final bool success;

  bool get hasChanges => pushedCount > 0 || pulledCount > 0;
}

typedef SyncProgressCallback = void Function(int progress, String message);
