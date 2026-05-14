import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../app/providers/api_provider.dart';
import 'note_model.dart';

part 'notes_provider.g.dart';

@riverpod
class Notes extends _$Notes {
  @override
  FutureOr<List<Note>> build() async {
    return _fetchNotes();
  }

  Future<List<Note>> _fetchNotes() async {
    final dio = ref.read(dioProvider);
    try {
      final response = await dio.get('/notes');
      final List<dynamic> data = response.data;
      return data.map((json) => Note.fromJson(json)).toList();
    } catch (e) {
      // Mock data
      return [
        const Note(id: 1, moduleId: 1, content: "Le freelancing demande de l'organisation."),
        const Note(id: 2, moduleId: 2, content: "LinkedIn est un bon outil pour prospecter."),
      ];
    }
  }

  Future<void> addNote(int moduleId, String content) async {
    final dio = ref.read(dioProvider);
    try {
      await dio.post('/notes', data: {
        'module_id': moduleId,
        'content': content,
      });
      ref.invalidateSelf();
    } catch (e) {
      // For demo, just add to local state if needed or ignore
      state = AsyncData([
        ...?state.value,
        Note(id: DateTime.now().millisecondsSinceEpoch, moduleId: moduleId, content: content),
      ]);
    }
  }

  Future<void> updateNote(int id, String content) async {
    final dio = ref.read(dioProvider);
    try {
      await dio.put('/notes/$id', data: {'content': content});
      ref.invalidateSelf();
    } catch (e) {
      if (state.hasValue) {
        state = AsyncData(state.value!.map((n) => n.id == id ? n.copyWith(content: content) : n).toList());
      }
    }
  }

  Future<void> deleteNote(int id) async {
    final dio = ref.read(dioProvider);
    try {
      await dio.delete('/notes/$id');
      ref.invalidateSelf();
    } catch (e) {
      if (state.hasValue) {
        state = AsyncData(state.value!.where((n) => n.id != id).toList());
      }
    }
  }
}
