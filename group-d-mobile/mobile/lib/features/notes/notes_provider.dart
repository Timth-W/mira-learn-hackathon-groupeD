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

  Future<void> addNote(
    String content, {
    String? moduleId,
    String? classId,
    String? concept,
  }) async {
    final api = ref.read(apiClientProvider);
    final resolvedClassId = classId ?? await _resolveClassId();
    final tags = _resolveTags(content, concept);

    await api.postAny(
      '/v1/students/me/notes',
      body: {
        'class_id': resolvedClassId,
        if (moduleId != null && moduleId.isNotEmpty) 'module_id': moduleId,
        'content': content,
        'tags': tags,
        'color': _suggestColor(tags),
      },
    );
    ref.invalidateSelf();
  }

  Future<void> updateNote(
    String id,
    String content, {
    String? concept,
  }) async {
    final api = ref.read(apiClientProvider);
    final tags = _resolveTags(content, concept);
    await api.patchAny(
      '/v1/students/me/notes/$id',
      body: {
        'content': content,
        'tags': tags,
        'color': _suggestColor(tags),
      },
    );
    ref.invalidateSelf();
  }

  Future<void> toggleFavorite(Note note) async {
    final api = ref.read(apiClientProvider);
    await api.patchAny(
      '/v1/students/me/notes/${note.id}',
      body: {'is_favorite': !note.isFavorite},
    );
    ref.invalidateSelf();
  }

  Future<void> deleteNote(String id) async {
    final api = ref.read(apiClientProvider);
    await api.deleteAny('/v1/students/me/notes/$id');
    ref.invalidateSelf();
  }

  Future<NoteOrganization> organizeNotes({
    required String classId,
    String? moduleId,
  }) async {
    final api = ref.read(apiClientProvider);
    final body = await api.post(
      '/v1/students/me/note-organizations',
      body: {
        'class_id': classId,
        if (moduleId != null && moduleId.isNotEmpty)
          'scope_module_id': moduleId,
      },
    );
    return NoteOrganization.fromJson(body);
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
      'Impossible de creer une note: aucun class_id disponible.',
    );
  }

  List<String> _resolveTags(String content, String? concept) {
    final normalizedConcept = concept?.trim().toLowerCase();
    if (normalizedConcept != null && normalizedConcept.isNotEmpty) {
      return [normalizedConcept];
    }
    return _suggestTags(content);
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
