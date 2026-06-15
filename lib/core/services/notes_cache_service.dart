import 'package:pocket_notes/core/constants/app_constants.dart';
import 'package:pocket_notes/features/auth/data/models/user_model.dart';
import 'package:pocket_notes/features/notes/data/models/note_category.dart';
import 'package:pocket_notes/features/notes/data/models/note_model.dart';
import 'package:pocket_notes/features/notes/data/repositories/notes_offline_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotesCacheService {
  NotesCacheService(this._prefs, this._offlineRepository);

  final SharedPreferences _prefs;
  final NotesOfflineRepository _offlineRepository;

  List<NoteModel> getNotesForCategory({
    required UserModel user,
    required NoteCategory category,
  }) {
    if (user.id.isEmpty) {
      return _offlineRepository.getOrphanedNotesByCategory(category);
    }

    return _offlineRepository.getNotesByUserAndCategory(
      userId: user.id,
      category: category,
    );
  }

  NoteModel? getNoteByLocalId(String localId) {
    return _offlineRepository.getNoteByLocalId(localId);
  }

  bool hasCachedNotesForUser(String userId) {
    if (userId.isEmpty) {
      return _offlineRepository.hasOrphanedNotes();
    }
    return _offlineRepository.hasNotesForUser(userId);
  }

  Future<void> markSynced(String userId) async {
    if (userId.isEmpty) return;
    await _prefs.setString(
      _syncedAtKey(userId),
      DateTime.now().toIso8601String(),
    );
  }

  DateTime? getLastSyncedAt(String userId) {
    if (userId.isEmpty) return null;
    final raw = _prefs.getString(_syncedAtKey(userId));
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  String _syncedAtKey(String userId) =>
      '${AppConstants.notesCacheSyncedAtKey}_$userId';
}
