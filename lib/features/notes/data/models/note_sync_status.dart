enum NoteSyncStatus {
  synced,
  pendingSync,
  conflict;

  String get label => switch (this) {
    NoteSyncStatus.synced => 'Synced',
    NoteSyncStatus.pendingSync => 'Pending Sync',
    NoteSyncStatus.conflict => 'Conflict',
  };

  static NoteSyncStatus fromValue(String? value) {
    return NoteSyncStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => NoteSyncStatus.synced,
    );
  }
}
