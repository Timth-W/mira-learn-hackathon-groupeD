import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers/api_provider.dart';
import 'models/enrolment.dart';
import 'models/program.dart';

final programmesServiceProvider = Provider<ProgrammesService>((ref) {
  return ProgrammesService(ref.read(apiClientProvider));
});

class ProgrammesService {
  ProgrammesService(this._api);

  final ApiClient _api;

  Future<ProgrammesResult> fetchEnrolments() async {
    try {
      final payload = await _api.getAny('/v1/me/enrolments');
      final enrolments = _extractEnrolments(payload);
      return ProgrammesResult(enrolments: enrolments);
    } on DioException catch (error) {
      if (_shouldUseMockData(error)) {
        return ProgrammesResult(
          enrolments: _mockEnrolments,
          isMocked: true,
        );
      }
      rethrow;
    }
  }

  List<Enrolment> _extractEnrolments(Object? payload) {
    final List<dynamic> items;
    if (payload is List<dynamic>) {
      items = payload;
    } else if (payload is Map<String, dynamic> &&
        payload['items'] is List<dynamic>) {
      items = payload['items'] as List<dynamic>;
    } else if (payload is Map<String, dynamic> &&
        payload['enrolments'] is List<dynamic>) {
      items = payload['enrolments'] as List<dynamic>;
    } else if (payload is Map<String, dynamic> &&
        payload['results'] is List<dynamic>) {
      items = payload['results'] as List<dynamic>;
    } else {
      items = const <dynamic>[];
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map(Enrolment.fromJson)
        .toList(growable: false);
  }

  bool _shouldUseMockData(DioException error) {
    return error.response == null ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout;
  }
}

class ProgrammesResult {
  const ProgrammesResult({
    required this.enrolments,
    this.isMocked = false,
  });

  final List<Enrolment> enrolments;
  final bool isMocked;
}

final _mockEnrolments = <Enrolment>[
  Enrolment(
    id: 'mock-enrolment-1',
    status: 'accepted',
    enrolledAt: DateTime(2026, 5, 12),
    program: Program(
      id: 'mock-program-1',
      title: 'Pitch Investor',
      mentorName: 'Antoine Mira',
      city: 'Barcelone',
      moduleCount: 5,
      nextModuleTitle: 'Storytelling pour investisseurs',
      startsAt: DateTime(2026, 7, 5),
      endsAt: DateTime(2026, 7, 26),
    ),
  ),
  Enrolment(
    id: 'mock-enrolment-2',
    status: 'waitlist',
    enrolledAt: DateTime(2026, 5, 18),
    program: Program(
      id: 'mock-program-2',
      title: 'Funding Basics for Nomads',
      mentorName: 'Lea Simon',
      city: 'Lisbonne',
      moduleCount: 4,
      nextModuleTitle: 'Pre-seed metrics',
      startsAt: DateTime(2026, 8, 2),
      endsAt: DateTime(2026, 8, 16),
    ),
  ),
];
