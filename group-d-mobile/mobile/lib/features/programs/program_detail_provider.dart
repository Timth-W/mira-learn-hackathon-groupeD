import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/providers/api_provider.dart';
import '../modules/module_model.dart';
import 'program_detail_model.dart';

part 'program_detail_provider.g.dart';

@riverpod
Future<ProgramDetail> programDetail(ProgramDetailRef ref, String id) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get(
    '/v1/students/me/notes',
    queryParameters: {'class_id': id},
  );

  final body = response.data;
  final List<dynamic> notes;

  if (body is Map<String, dynamic> &&
      body['status'] == 'success' &&
      body['data'] is List<dynamic>) {
    notes = body['data'] as List<dynamic>;
  } else if (body is List<dynamic>) {
    notes = body;
  } else {
    notes = const <dynamic>[];
  }

  final classNotes = notes.whereType<Map<String, dynamic>>().toList(growable: false);
  final modulesById = <String, List<Map<String, dynamic>>>{};

  for (final note in classNotes) {
    final moduleId = note['module_id']?.toString();
    if (moduleId == null || moduleId.isEmpty) continue;
    modulesById.putIfAbsent(moduleId, () => <Map<String, dynamic>>[]).add(note);
  }

  final modules = modulesById.entries.map((entry) {
    final moduleNotes = entry.value;
    return Module(
      id: entry.key,
      title: 'Module ${entry.key.substring(0, entry.key.length > 8 ? 8 : entry.key.length)}',
      duration: '${moduleNotes.length} note(s)',
      progress: (moduleNotes.length * 25).clamp(10, 100),
      isLocked: false,
    );
  }).toList()
    ..sort((a, b) => a.title.compareTo(b.title));

  final noteCount = classNotes.length;
  final globalProgress = (noteCount * 20).clamp(10, 100);

  return ProgramDetail(
    id: id,
    title: 'Classe ${id.substring(0, id.length > 8 ? 8 : id.length)}',
    description: noteCount == 0
        ? 'Aucune note disponible pour ce programme.'
        : 'Programme construit a partir de $noteCount note(s) synchronisee(s) depuis le backend.',
    globalProgress: globalProgress,
    modules: modules,
  );
}
