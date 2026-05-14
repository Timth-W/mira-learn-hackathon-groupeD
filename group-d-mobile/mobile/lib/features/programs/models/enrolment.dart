import 'program.dart';

class Enrolment {
  const Enrolment({
    required this.id,
    required this.status,
    required this.program,
    this.enrolledAt,
  });

  final String id;
  final String status;
  final Program program;
  final DateTime? enrolledAt;

  factory Enrolment.fromJson(Map<String, dynamic> json) {
    return Enrolment(
      id: (json['enrolment_id'] ??
              json['id'] ??
              json['enrollment_id'] ??
              'unknown-enrolment')
          .toString(),
      status: (json['status'] ?? 'unknown').toString(),
      program: Program.fromJson(json),
      enrolledAt: _dateOf(json['enrolled_at'], json['created_at']),
    );
  }
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
