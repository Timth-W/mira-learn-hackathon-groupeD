import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers/api_provider.dart';
import 'models/enrolment.dart';

final programmesServiceProvider = Provider<ProgrammesService>((ref) {
  return ProgrammesService(ref.read(apiClientProvider));
});

class ProgrammesService {
  ProgrammesService(this._api);

  final ApiClient _api;

  Future<ProgrammesResult> fetchEnrolments() async {
    final payload = await _api.getAny('/v1/me/enrolments');
    final enrolments = _extractEnrolments(payload);
    return ProgrammesResult(enrolments: enrolments);
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
}

class ProgrammesResult {
  const ProgrammesResult({
    required this.enrolments,
  });

  final List<Enrolment> enrolments;
}
