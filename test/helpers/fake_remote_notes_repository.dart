import 'package:pocket_notes/features/notes/data/models/note_category.dart';
import 'package:pocket_notes/features/notes/data/models/note_model.dart';
import 'package:pocket_notes/features/notes/data/models/note_sync_status.dart';
import 'package:pocket_notes/features/notes/data/repositories/remote_notes_repository.dart';

/// Controllable remote API used by sync conflict tests.
class FakeRemoteNotesRepository {
  final List<NoteModel> notesByUser = [];
  final Map<String, NoteModel> notesById = {};

  void seedNote(NoteModel note) {
    notesById[note.remoteId!] = note;
    notesByUser.removeWhere((item) => item.remoteId == note.remoteId);
    notesByUser.add(note);
  }

  Future<List<NoteModel>> getNotesByUserId(String userId) async {
    return notesByUser.where((note) => note.userId == userId).toList();
  }

  Future<NoteModel?> getNoteById(String id) async => notesById[id];

  Future<NoteModel> updateNote({
    required String id,
    required String title,
    required String body,
    required String userId,
    required NoteCategory category,
  }) async {
    final existing = notesById[id]!;
    final updated = existing.copyWith(
      title: title,
      body: body,
      updatedAt: DateTime.now(),
    );
    notesById[id] = updated;
    notesByUser
      ..removeWhere((note) => note.remoteId == id)
      ..add(updated);
    return updated;
  }

  Future<NoteModel> createNote({
    required String userId,
    required String title,
    required String body,
    required NoteCategory category,
  }) async {
    final note = NoteModel(
      localId: 'remote-created',
      remoteId: 'remote-${notesById.length + 1}',
      userId: userId,
      title: title,
      body: body,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      category: category,
      syncStatus: NoteSyncStatus.synced,
    );
    seedNote(note);
    return note;
  }

  Future<void> deleteNote(String id) async {
    notesById.remove(id);
    notesByUser.removeWhere((note) => note.remoteId == id);
  }
}

/// Sync service test double that delegates to [FakeRemoteNotesRepository].
class TestableRemoteNotesRepository extends RemoteNotesRepository {
  TestableRemoteNotesRepository(this.fake) : super.forTest();

  final FakeRemoteNotesRepository fake;

  @override
  Future<List<NoteModel>> getNotesByUserId(String userId) =>
      fake.getNotesByUserId(userId);

  @override
  Future<NoteModel?> getNoteById(String id) => fake.getNoteById(id);

  @override
  Future<NoteModel> updateNote({
    required String id,
    required String title,
    required String body,
    required String userId,
    required NoteCategory category,
  }) => fake.updateNote(
    id: id,
    title: title,
    body: body,
    userId: userId,
    category: category,
  );

  @override
  Future<NoteModel> createNote({
    required String userId,
    required String title,
    required String body,
    required NoteCategory category,
  }) => fake.createNote(
    userId: userId,
    title: title,
    body: body,
    category: category,
  );

  @override
  Future<void> deleteNote(String id) => fake.deleteNote(id);
}
