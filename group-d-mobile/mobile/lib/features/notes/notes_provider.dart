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

  Future<void> addNote(String content,
      {String? moduleId, String? classId}) async {
    final dio = ref.read(dioProvider);
    final resolvedClassId = classId ?? await _resolveClassId();
    final tags = _suggestTags(content);

    await dio.post(
      '/v1/students/me/notes',
      data: {
        'class_id': resolvedClassId,
        if (moduleId != null && moduleId.isNotEmpty) 'module_id': moduleId,
        'content': content,
        'tags': tags,
        'color': _suggestColor(tags),
      },
    );
    ref.invalidateSelf();
  }

  Future<void> updateNote(String id, String content) async {
    final dio = ref.read(dioProvider);
    await dio.patch('/v1/students/me/notes/$id', data: {'content': content});
    ref.invalidateSelf();
  }

  Future<void> toggleFavorite(Note note) async {
    final dio = ref.read(dioProvider);
    await dio.patch(
      '/v1/students/me/notes/${note.id}',
      data: {'is_favorite': !note.isFavorite},
    );
    ref.invalidateSelf();
  }

  Future<void> deleteNote(String id) async {
    final dio = ref.read(dioProvider);
    await dio.delete('/v1/students/me/notes/$id');
    ref.invalidateSelf();
  }

  Future<NoteOrganization> organizeNotes({
    required String classId,
    String? moduleId,
  }) async {
    final dio = ref.read(dioProvider);
    final response = await dio.post(
      '/v1/students/me/note-organizations',
      data: {
        'class_id': classId,
        if (moduleId != null && moduleId.isNotEmpty)
          'scope_module_id': moduleId,
      },
    );
    final body = response.data;
    final Map<String, dynamic> data;
    if (body is Map<String, dynamic> &&
        body['status'] == 'success' &&
        body['data'] is Map<String, dynamic>) {
      data = body['data'] as Map<String, dynamic>;
    } else if (body is Map<String, dynamic>) {
      data = body;
    } else {
      data = const <String, dynamic>{};
    }
    return NoteOrganization.fromJson(data);
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

    throw StateError(
        'Impossible de creer une note: aucun class_id disponible.');
  }

  List<String> _suggestTags(String content) {
    final lower = content.toLowerCase();
    final tags = <String>[];
    void addWhen(String tag, List<String> keywords) {
      if (keywords.any(lower.contains)) tags.add(tag);
    }

    addWhen('pitch', ['pitch', 'story', 'investisseur', 'hook']);
    addWhen('objection', ['objection', 'risque', 'faq', 'repondre']);
    addWhen('traction', ['traction', 'kpi', 'revenu', 'croissance']);
    addWhen('ask', ['ask', 'besoin', 'montant', 'prochaine etape']);
    if (tags.isEmpty) tags.add('general');
    return tags.take(3).toList(growable: false);
  }

  String _suggestColor(List<String> tags) {
    if (tags.contains('objection')) return 'red';
    if (tags.contains('traction')) return 'green';
    if (tags.contains('pitch')) return 'purple';
    if (tags.contains('ask')) return 'blue';
    return 'yellow';
  }
}
