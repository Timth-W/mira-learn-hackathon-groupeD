class Note {
  const Note({
    required this.id,
    required this.classId,
    this.moduleId,
    required this.content,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String classId;
  final String? moduleId;
  final String content;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Note.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    return Note(
      id: (json['id'] ?? '').toString(),
      classId: (json['class_id'] ?? '').toString(),
      moduleId: json['module_id']?.toString(),
      content: (json['content'] ?? '').toString(),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }
}
