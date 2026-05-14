import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/providers/api_provider.dart';
import '../modules/module_model.dart';
import 'program_detail_model.dart';

part 'program_detail_provider.g.dart';

@riverpod
Future<ProgramDetail> programDetail(ProgramDetailRef ref, String id) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/v1/me/enrolments/$id');
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

  final modules = ((data['modules'] as List<dynamic>?) ?? const <dynamic>[])
      .whereType<Map<String, dynamic>>()
      .map(
        (module) => Module(
          id: module['id']?.toString() ?? 'unknown-module',
          classId: data['class_id']?.toString(),
          title: module['title']?.toString() ?? 'Module',
          duration: module['duration_label']?.toString() ?? 'Duree inconnue',
          progress: (module['progress_pct'] as num?)?.toInt() ?? 0,
          description: module['description']?.toString(),
          quizId: module['quiz_id']?.toString(),
          status: module['status']?.toString(),
          materials: ((module['materials'] as List<dynamic>?) ?? const <dynamic>[])
              .map((item) => item.toString())
              .toList(growable: false),
          isLocked: module['status']?.toString() == 'locked',
        ),
      )
      .toList(growable: false);

  return ProgramDetail(
    id: id,
    title: data['class_title']?.toString() ?? 'Programme',
    description: data['description']?.toString() ?? 'Description indisponible.',
    globalProgress: (data['progress_pct'] as num?)?.toInt() ?? 0,
    modules: modules,
  );
}
