import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotesRefreshNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final notesRefreshProvider =
    NotifierProvider<NotesRefreshNotifier, int>(NotesRefreshNotifier.new);

void bumpNotesRefresh(WidgetRef ref) {
  ref.read(notesRefreshProvider.notifier).bump();
}

class NotesSyncingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setSyncing(bool value) => state = value;
}

final notesSyncingProvider =
    NotifierProvider<NotesSyncingNotifier, bool>(NotesSyncingNotifier.new);
