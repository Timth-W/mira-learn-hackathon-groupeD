import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers/api_provider.dart';
import 'community_models.dart';

final communityProvider = FutureProvider<CommunityResult>((ref) async {
  final api = ref.read(apiClientProvider);

  try {
    final payload = await api.getAny('/v1/community/feed');
    return CommunityResult(
      activities: _activitiesFromPayload(payload),
      spots: _mapSpots,
    );
  } on DioException catch (error) {
    if (_shouldUseMockData(error)) {
      return CommunityResult(
        activities: _mockActivities,
        spots: _mapSpots,
        isMocked: true,
      );
    }
    rethrow;
  }
});

class CommunityResult {
  const CommunityResult({
    required this.activities,
    required this.spots,
    this.isMocked = false,
  });

  final List<CommunityActivity> activities;
  final List<CommunityMapSpot> spots;
  final bool isMocked;
}

List<CommunityActivity> _activitiesFromPayload(Object? payload) {
  final List<dynamic> items;
  if (payload is List<dynamic>) {
    items = payload;
  } else if (payload is Map<String, dynamic> &&
      payload['items'] is List<dynamic>) {
    items = payload['items'] as List<dynamic>;
  } else {
    items = const <dynamic>[];
  }

  return items
      .whereType<Map<String, dynamic>>()
      .map(CommunityActivity.fromJson)
      .toList(growable: false);
}

bool _shouldUseMockData(DioException error) {
  return error.response == null ||
      error.type == DioExceptionType.connectionError ||
      error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout;
}

final _mapSpots = <CommunityMapSpot>[
  const CommunityMapSpot(
    city: 'Lisbonne',
    label: '18 sessions actives',
    left: 0.42,
    top: 0.38,
    count: 18,
  ),
  const CommunityMapSpot(
    city: 'Barcelone',
    label: '9 sessions actives',
    left: 0.46,
    top: 0.42,
    count: 9,
  ),
  const CommunityMapSpot(
    city: 'Bali',
    label: '7 sessions actives',
    left: 0.78,
    top: 0.58,
    count: 7,
  ),
  const CommunityMapSpot(
    city: 'Mexico City',
    label: '5 sessions actives',
    left: 0.18,
    top: 0.52,
    count: 5,
  ),
];

final _mockActivities = <CommunityActivity>[
  CommunityActivity(
    id: 'mock-1',
    eventType: 'skill_validated',
    displayText: 'Une nomade vient de valider Pitch investor - Portugal',
    displayIcon: 'workspace_premium',
    occurredAt: DateTime.now().subtract(const Duration(minutes: 12)),
  ),
  CommunityActivity(
    id: 'mock-2',
    eventType: 'enrolment_made',
    displayText: '3 nouvelles inscriptions sur Pitch Investor - Lisbonne',
    displayIcon: 'person_add',
    occurredAt: DateTime.now().subtract(const Duration(minutes: 28)),
  ),
  CommunityActivity(
    id: 'mock-3',
    eventType: 'class_started',
    displayText: 'Une Mira Class vient de demarrer - Barcelone',
    displayIcon: 'travel_explore',
    occurredAt: DateTime.now().subtract(const Duration(hours: 1)),
  ),
];
