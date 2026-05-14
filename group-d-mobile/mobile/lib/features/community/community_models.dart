class CommunityActivity {
  const CommunityActivity({
    required this.id,
    required this.eventType,
    required this.displayText,
    required this.occurredAt,
    this.displayIcon,
    this.context = const <String, Object?>{},
  });

  final String id;
  final String eventType;
  final String displayText;
  final String? displayIcon;
  final Map<String, Object?> context;
  final DateTime occurredAt;

  factory CommunityActivity.fromJson(Map<String, dynamic> json) {
    return CommunityActivity(
      id: (json['id'] ?? 'unknown-event').toString(),
      eventType: (json['event_type'] ?? 'milestone_reached').toString(),
      displayText: _cleanDisplayText((json['display_text'] ?? '').toString()),
      displayIcon: json['display_icon']?.toString(),
      context: _mapOf(json['context']),
      occurredAt: _dateOf(json['occurred_at']) ?? DateTime.now(),
    );
  }
}

class CommunityMapSpot {
  const CommunityMapSpot({
    required this.city,
    required this.label,
    required this.left,
    required this.top,
    required this.count,
  });

  final String city;
  final String label;
  final double left;
  final double top;
  final int count;
}

String _cleanDisplayText(String value) {
  return value.replaceAll('\u00c2\u00b7', '-').replaceAll('\u00b7', '-');
}

Map<String, Object?> _mapOf(Object? value) {
  if (value is Map<String, dynamic>) return value.cast<String, Object?>();
  return const <String, Object?>{};
}

DateTime? _dateOf(Object? value) {
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}
