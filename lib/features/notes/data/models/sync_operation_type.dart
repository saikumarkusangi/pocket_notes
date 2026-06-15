enum SyncOperationType {
  create,
  update,
  delete;

  static SyncOperationType fromValue(String? value) {
    return SyncOperationType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => SyncOperationType.update,
    );
  }
}
