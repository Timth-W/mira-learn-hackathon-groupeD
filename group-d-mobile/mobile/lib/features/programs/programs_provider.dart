import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../app/providers/api_provider.dart';
import 'program_model.dart';

part 'programs_provider.g.dart';

@riverpod
class Programs extends _$Programs {
  @override
  FutureOr<List<Program>> build() async {
    return _fetchPrograms();
  }

  Future<List<Program>> _fetchPrograms() async {
    final dio = ref.read(dioProvider);
    final response = await dio.get('/v1/students/me/notes');

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

    final groupedByClass = <String, List<Map<String, dynamic>>>{};
    for (final item in notes) {
      if (item is! Map<String, dynamic>) continue;
      final classId = item['class_id']?.toString();
      if (classId == null || classId.isEmpty) continue;
      groupedByClass.putIfAbsent(classId, () => <Map<String, dynamic>>[]).add(item);
    }

    final programs = <Program>[];
    groupedByClass.forEach((classId, classNotes) {
      classNotes.sort((a, b) {
        final aDate = DateTime.tryParse(a['updated_at']?.toString() ?? '') ?? DateTime(1970);
        final bDate = DateTime.tryParse(b['updated_at']?.toString() ?? '') ?? DateTime(1970);
        return bDate.compareTo(aDate);
      });

      final latest = classNotes.first;
      final latestDate =
          DateTime.tryParse(latest['updated_at']?.toString() ?? '') ?? DateTime.now();

      programs.add(
        Program(
          id: classId,
          title: 'Classe ${classId.substring(0, classId.length > 8 ? 8 : classId.length)}',
          mentor: 'Mira Learn',
          progress: (classNotes.length * 20).clamp(5, 100),
          nextSession: latestDate,
        ),
      );
    });

    programs.sort((a, b) => b.nextSession.compareTo(a.nextSession));
    return programs;
  }
}
