import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_provider.dart';
import 'note_model.dart';

final notesProvider = AsyncNotifierProvider<Notes, List<Note>>(Notes.new);

class Notes extends AsyncNotifier<List<Note>> {
  @override
  FutureOr<List<Note>> build() async {
    return _fetchNotes();
  }

  Future<List<Note>> _fetchNotes() async {
    final dio = ref.read(dioProvider);
    final response = await dio.get('/v1/students/me/notes');
    final body = response.data;

    final List<dynamic> data;
    if (body is Map<String, dynamic> &&
        body['status'] == 'success' &&
        body['data'] is List<dynamic>) {
      data = body['data'] as List<dynamic>;
    } else if (body is List<dynamic>) {
      data = body;
    } else {
      data = const <dynamic>[];
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(Note.fromJson)
        .toList(growable: false);
  }

  Future<void> addNote(String content, {String? moduleId}) async {
    final dio = ref.read(dioProvider);
    final classId = await _resolveClassId();

    await dio.post(
      '/v1/students/me/notes',
      data: {
        'class_id': classId,
        if (moduleId != null && moduleId.isNotEmpty) 'module_id': moduleId,
        'content': content,
      },
    );
    ref.invalidateSelf();
  }

  Future<void> updateNote(String id, String content) async {
    final dio = ref.read(dioProvider);
    await dio.patch('/v1/students/me/notes/$id', data: {'content': content});
    ref.invalidateSelf();
  }

  Future<void> deleteNote(String id) async {
    final dio = ref.read(dioProvider);
    await dio.delete('/v1/students/me/notes/$id');
    ref.invalidateSelf();
  }

  Future<String> _resolveClassId() async {
    final current = state.valueOrNull;
    if (current != null && current.isNotEmpty) {
      return current.first.classId;
    }

    final notes = await _fetchNotes();
    if (notes.isNotEmpty) {
      return notes.first.classId;
    }

    throw StateError('Impossible de creer une note: aucun class_id disponible.');
  }
}
