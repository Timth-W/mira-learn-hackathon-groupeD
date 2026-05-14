import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../app/providers/api_provider.dart';
import 'note_model.dart';

final notesProvider = AsyncNotifierProvider<Notes, List<Note>>(Notes.new);

class Notes extends AsyncNotifier<List<Note>> {
  @override
  FutureOr<List<Note>> build() async {
    return _fetchNotes();
  }

  Future<List<Note>> _fetchNotes() async {
    final api = ref.read(apiClientProvider);
    final body = await api.getAny('/v1/students/me/notes');
    final data = body is List<dynamic> ? body : const <dynamic>[];

    return data
        .whereType<Map<String, dynamic>>()
        .map(Note.fromJson)
        .toList(growable: false);
  }

  Future<void> addNote(String content, {String? moduleId, String? classId}) async {
    final api = ref.read(apiClientProvider);
    final resolvedClassId = classId ?? await _resolveClassId();

    await api.postAny(
      '/v1/students/me/notes',
      body: {
        'class_id': resolvedClassId,
        if (moduleId != null && moduleId.isNotEmpty) 'module_id': moduleId,
        'content': content,
      },
    );
    ref.invalidateSelf();
  }

  Future<void> updateNote(String id, String content) async {
    final api = ref.read(apiClientProvider);
    await api.patchAny('/v1/students/me/notes/$id', body: {'content': content});
    ref.invalidateSelf();
  }

  Future<void> deleteNote(String id) async {
    final api = ref.read(apiClientProvider);
    await api.deleteAny('/v1/students/me/notes/$id');
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
