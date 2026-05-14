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
    // For now, let's use mock data if API fails or for demo
    try {
      final response = await dio.get('/student/programs');
      final List<dynamic> data = response.data['programs'];
      return data.map((json) => Program.fromJson(json)).toList();
    } catch (e) {
      // Mock data for demo
      return [
        Program(
          id: 1,
          title: "Remote Freelance",
          mentor: "Sarah",
          progress: 72,
          nextSession: DateTime.parse("2025-05-20T18:00:00"),
        ),
        Program(
          id: 2,
          title: "Fullstack Dev",
          mentor: "Alex",
          progress: 30,
          nextSession: DateTime.parse("2025-06-10T14:00:00"),
        ),
      ];
    }
  }
}
