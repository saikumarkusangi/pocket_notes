import 'package:pocket_notes/core/network/github_database.dart';
import 'package:pocket_notes/features/notes/data/models/note_category.dart';
import 'package:pocket_notes/features/notes/data/models/note_model.dart';

class RemoteNotesRepository {
  RemoteNotesRepository(this._database);

  RemoteNotesRepository.forTest() : _database = null;

  final GithubDatabase? _database;
  static final String _notesPath = githubDatabasePath('notes.json');

  GithubDatabase get _store {
    final database = _database;
    if (database == null) {
      throw StateError('Remote notes repository is not connected.');
    }
    return database;
  }

  Future<List<NoteModel>> getNotesByUserId(String userId) {
    return _store.run((session) async {
      final notes = await _notesWithBodies(session);
      final matched = notes.where((note) => note.userId == userId).toList();
      matched.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return matched;
    });
  }

  Future<NoteModel?> getNoteById(String id) {
    return _store.run((session) async {
      final notes = await _notesWithBodies(session);
      for (final note in notes) {
        if (note.remoteId == id || note.localId == id) return note;
      }
      return null;
    });
  }

  Future<NoteModel> createNote({
    required String userId,
    required String title,
    required String body,
    required NoteCategory category,
  }) {
    return _store.run((session) async {
      final records = await session.readJsonList(_notesPath);
      final id = nextRecordId(records);
      final now = _unixNow();
      final bodyFile = 'notes/$id.txt';
      records.add({
        'id': id,
        'userId': userId,
        'title': title,
        'type': category.apiType,
        'bodyFile': bodyFile,
        'createdAt': now,
        'updatedAt': now,
      });
      await session.writeText(
        path: githubDatabasePath(bodyFile),
        content: body,
        message: 'Add note $id',
      );
      await session.writeJsonList(
        path: _notesPath,
        records: records,
        message: 'Add note $id',
      );
      return NoteModel.fromJson({...records.last, 'body': body});
    });
  }

  Future<NoteModel> updateNote({
    required String id,
    required String title,
    required String body,
    required String userId,
    required NoteCategory category,
  }) {
    return _store.run((session) async {
      final records = await session.readJsonList(_notesPath);
      final index = records.indexWhere(
        (record) => record['id']?.toString() == id,
      );
      if (index < 0) {
        throw StateError('Note $id was not found in GitHub.');
      }
      final current = records[index];
      final bodyFile = current['bodyFile'] as String? ?? 'notes/$id.txt';
      final updated = {
        ...current,
        'userId': userId,
        'title': title,
        'type': category.apiType,
        'bodyFile': bodyFile,
        'updatedAt': _unixNow(),
      };
      records[index] = updated;
      await session.writeText(
        path: githubDatabasePath(bodyFile),
        content: body,
        message: 'Update note $id',
      );
      await session.writeJsonList(
        path: _notesPath,
        records: records,
        message: 'Update note $id',
      );
      return NoteModel.fromJson({...updated, 'body': body});
    });
  }

  Future<void> deleteNote(String id) {
    return _store.run((session) async {
      final records = await session.readJsonList(_notesPath);
      final index = records.indexWhere(
        (record) => record['id']?.toString() == id,
      );
      if (index < 0) return;
      final bodyFile = records[index]['bodyFile'] as String?;
      records.removeAt(index);
      await session.writeJsonList(
        path: _notesPath,
        records: records,
        message: 'Delete note $id',
      );
      if (bodyFile == null || bodyFile.isEmpty) return;
      await session.deleteFile(
        path: githubDatabasePath(bodyFile),
        message: 'Delete note $id body',
      );
    });
  }

  Future<List<NoteModel>> _notesWithBodies(GithubSession session) async {
    final records = await session.readJsonList(_notesPath);
    final notes = <NoteModel>[];
    for (final record in records) {
      final bodyFile = record['bodyFile'] as String?;
      final body = bodyFile == null
          ? record['body'] as String? ?? ''
          : await session.readText(githubDatabasePath(bodyFile));
      notes.add(NoteModel.fromJson({...record, 'body': body}));
    }
    return notes;
  }

  int _unixNow() => DateTime.now().millisecondsSinceEpoch ~/ 1000;
}
