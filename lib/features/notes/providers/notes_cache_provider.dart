import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_notes/core/providers/storage_provider.dart';
import 'package:pocket_notes/core/services/notes_cache_service.dart';
import 'package:pocket_notes/features/notes/providers/notes_offline_provider.dart';

final notesCacheServiceProvider = Provider<NotesCacheService>((ref) {
  return NotesCacheService(
    ref.watch(sharedPreferencesProvider),
    ref.watch(notesOfflineRepositoryProvider),
  );
});
