import 'package:dio/dio.dart';
import 'package:pocket_notes/core/constants/api_endpoints.dart';
import 'package:pocket_notes/features/notes/data/models/note_category.dart';
import 'package:pocket_notes/features/notes/data/models/note_model.dart';

class RemoteNotesRepository {
  RemoteNotesRepository(this._dio);

  final Dio _dio;

  Future<List<NoteModel>> getNotesByUserId(String userId) async {
    final response = await _dio.get<List<dynamic>>(
      ApiEndpoints.notes,
      queryParameters: {'userId': userId},
    );

    final notes = _parseNotes(response.data);
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  Future<NoteModel?> getNoteById(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiEndpoints.notes}/$id',
    );

    final data = response.data;
    if (data == null) return null;
    return NoteModel.fromJson(data);
  }

  Future<NoteModel> createNote({
    required String userId,
    required String title,
    required String body,
    required NoteCategory category,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.notes,
      data: {
        'userId': userId,
        'title': title,
        'body': body,
        'type': category.apiType,
        'createdAt': now,
        'updatedAt': now,
      },
    );

    return NoteModel.fromJson(response.data ?? {});
  }

  Future<NoteModel> updateNote({
    required String id,
    required String title,
    required String body,
    required String userId,
    required NoteCategory category,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final response = await _dio.put<Map<String, dynamic>>(
      '${ApiEndpoints.notes}/$id',
      data: {
        'userId': userId,
        'title': title,
        'body': body,
        'type': category.apiType,
        'updatedAt': now,
      },
    );

    return NoteModel.fromJson(response.data ?? {});
  }

  Future<void> deleteNote(String id) async {
    await _dio.delete('${ApiEndpoints.notes}/$id');
  }

  List<NoteModel> _parseNotes(List<dynamic>? data) {
    if (data == null) return [];

    return data
        .whereType<Map<String, dynamic>>()
        .map(NoteModel.fromJson)
        .toList();
  }
}
