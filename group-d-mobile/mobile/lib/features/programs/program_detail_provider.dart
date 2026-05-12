import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/api_provider.dart';
import 'program_detail_model.dart';
import '../modules/module_model.dart';

part 'program_detail_provider.g.dart';

@riverpod
Future<ProgramDetail> programDetail(ProgramDetailRef ref, int id) async {
  final dio = ref.read(dioProvider);
  try {
    final response = await dio.get('/programs/$id');
    return ProgramDetail.fromJson(response.data);
  } catch (e) {
    // Mock data
    return ProgramDetail(
      id: id,
      title: "Remote Freelance",
      description: "Apprenez à devenir freelance et travailler à distance.",
      globalProgress: 72,
      modules: [
        const Module(id: 1, title: "Introduction au Freelancing", duration: "1h 30", progress: 100),
        const Module(id: 2, title: "Trouver ses premiers clients", duration: "2h 00", progress: 80),
        const Module(id: 3, title: "Gestion administrative", duration: "1h 45", progress: 0, isLocked: true),
      ],
    );
  }
}
