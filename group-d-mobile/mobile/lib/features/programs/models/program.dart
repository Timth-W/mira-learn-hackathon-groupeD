class Program {
  const Program({
    required this.id,
    required this.title,
    this.mentorName,
    this.city,
    this.progressPct,
    this.nextModuleTitle,
    this.moduleCount,
    this.startsAt,
    this.endsAt,
  });

  final String id;
  final String title;
  final String? mentorName;
  final String? city;
  final int? progressPct;
  final String? nextModuleTitle;
  final int? moduleCount;
  final DateTime? startsAt;
  final DateTime? endsAt;

  factory Program.fromJson(Map<String, dynamic> json) {
    final session = _asMap(json['session']);
    final miraClass = _asMap(json['class']);
    final program = _asMap(json['program']);

    return Program(
      id: _stringOf(
            json['class_id'],
            miraClass['id'],
            program['id'],
            session['class_id'],
            json['id'],
          ) ??
          'unknown-program',
      title: _stringOf(
            json['class_title'],
            miraClass['title'],
            program['title'],
            json['title'],
            session['class_title'],
          ) ??
          'Programme sans titre',
      mentorName: _stringOf(
        json['mentor_display_name'],
        _asMap(json['mentor'])['display_name'],
        _asMap(json['mentor'])['name'],
      ),
      city: _stringOf(
        json['location_city'],
        session['location_city'],
      ),
      progressPct: _intOf(json['progress_pct'], json['progress']),
      nextModuleTitle: _stringOf(json['next_module_title']),
      moduleCount: _intOf(
        json['module_count'],
        json['modules_count'],
        _asList(json['modules']).length,
      ),
      startsAt: _dateOf(
        json['starts_at'],
        session['starts_at'],
      ),
      endsAt: _dateOf(
        json['ends_at'],
        session['ends_at'],
      ),
    );
  }
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  return const {};
}

List<dynamic> _asList(Object? value) {
  if (value is List<dynamic>) return value;
  return const [];
}

String? _stringOf([Object? a, Object? b, Object? c, Object? d, Object? e]) {
  final values = [a, b, c, d, e];
  for (final value in values) {
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return null;
}

int? _intOf([Object? a, Object? b, Object? c]) {
  final values = [a, b, c];
  for (final value in values) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
  }
  return null;
}

DateTime? _dateOf([Object? a, Object? b]) {
  final values = [a, b];
  for (final value in values) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
  }
  return null;
}
