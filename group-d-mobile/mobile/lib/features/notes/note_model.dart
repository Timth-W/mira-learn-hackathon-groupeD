class Note {
  const Note({
    required this.id,
    required this.classId,
    this.moduleId,
    required this.content,
    this.tags = const <String>[],
    this.isFavorite = false,
    this.color,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String classId;
  final String? moduleId;
  final String content;
  final List<String> tags;
  final bool isFavorite;
  final String? color;
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
      tags: ((json['tags'] as List<dynamic>?) ?? const <dynamic>[])
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
      isFavorite: json['is_favorite'] == true,
      color: json['color']?.toString(),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }
}

class NoteOrganization {
  const NoteOrganization({
    required this.id,
    required this.summary,
    required this.concepts,
    required this.keyTakeaways,
    required this.generatedByLlm,
    this.scopeModuleId,
  });

  final String id;
  final String summary;
  final List<OrganizedConcept> concepts;
  final List<String> keyTakeaways;
  final bool generatedByLlm;
  final String? scopeModuleId;

  factory NoteOrganization.fromJson(Map<String, dynamic> json) {
    return NoteOrganization(
      id: (json['id'] ?? '').toString(),
      summary: (json['summary'] ?? '').toString(),
      scopeModuleId: json['scope_module_id']?.toString(),
      generatedByLlm: json['generated_by_llm'] == true,
      keyTakeaways:
          ((json['key_takeaways'] as List<dynamic>?) ?? const <dynamic>[])
              .map((item) => item.toString())
              .where((item) => item.isNotEmpty)
              .toList(growable: false),
      concepts: ((json['concepts'] as List<dynamic>?) ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(OrganizedConcept.fromJson)
          .toList(growable: false),
    );
  }
}

class OrganizedConcept {
  const OrganizedConcept({
    required this.name,
    required this.description,
    required this.keyPoints,
    required this.relatedNoteIds,
  });

  final String name;
  final String description;
  final List<String> keyPoints;
  final List<String> relatedNoteIds;

  factory OrganizedConcept.fromJson(Map<String, dynamic> json) {
    return OrganizedConcept(
      name: (json['concept_name'] ?? 'general').toString(),
      description: (json['description'] ?? '').toString(),
      keyPoints: ((json['key_points'] as List<dynamic>?) ?? const <dynamic>[])
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
      relatedNoteIds:
          ((json['related_note_ids'] as List<dynamic>?) ?? const <dynamic>[])
              .map((item) => item.toString())
              .where((item) => item.isNotEmpty)
              .toList(growable: false),
    );
  }
}
