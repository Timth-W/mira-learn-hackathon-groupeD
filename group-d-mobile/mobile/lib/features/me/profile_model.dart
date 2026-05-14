class ProfileSummary {
  const ProfileSummary({
    required this.displayName,
    required this.role,
    required this.activeClassCount,
    required this.noteCount,
    required this.quizCount,
    required this.validatedSkills,
    required this.targetSkills,
    required this.badges,
    this.email,
    this.avatarUrl,
  });

  final String displayName;
  final String? email;
  final String role;
  final String? avatarUrl;
  final int activeClassCount;
  final int noteCount;
  final int quizCount;
  final List<ProfileSkill> validatedSkills;
  final List<ProfileSkill> targetSkills;
  final List<ProfileBadge> badges;

  factory ProfileSummary.fromJson(Map<String, dynamic> json) {
    return ProfileSummary(
      displayName: (json['display_name'] ?? 'Nomade Mira').toString(),
      email: json['email']?.toString(),
      role: (json['role'] ?? 'nomad').toString(),
      avatarUrl: json['avatar_url']?.toString(),
      activeClassCount: _intOf(json['active_class_count']) ?? 0,
      noteCount: _intOf(json['note_count']) ?? 0,
      quizCount: _intOf(json['quiz_count']) ?? 0,
      validatedSkills: _listOf(json['validated_skills'])
          .whereType<Map<String, dynamic>>()
          .map(ProfileSkill.fromJson)
          .toList(growable: false),
      targetSkills: _listOf(json['target_skills'])
          .whereType<Map<String, dynamic>>()
          .map(ProfileSkill.fromJson)
          .toList(growable: false),
      badges: _listOf(json['badges'])
          .whereType<Map<String, dynamic>>()
          .map(ProfileBadge.fromJson)
          .toList(growable: false),
    );
  }
}

class ProfileSkill {
  const ProfileSkill({
    required this.name,
    required this.category,
    required this.status,
    this.scorePct,
  });

  final String name;
  final String category;
  final String status;
  final int? scorePct;

  factory ProfileSkill.fromJson(Map<String, dynamic> json) {
    return ProfileSkill(
      name: (json['name'] ?? 'Skill Mira').toString(),
      category: (json['category'] ?? 'business').toString(),
      status: (json['status'] ?? 'target').toString(),
      scorePct: _intOf(json['score_pct']),
    );
  }
}

class ProfileBadge {
  const ProfileBadge({
    required this.label,
    required this.description,
    required this.icon,
    required this.tone,
  });

  final String label;
  final String description;
  final String icon;
  final String tone;

  factory ProfileBadge.fromJson(Map<String, dynamic> json) {
    return ProfileBadge(
      label: (json['label'] ?? 'Badge Mira').toString(),
      description: (json['description'] ?? '').toString(),
      icon: (json['icon'] ?? 'flag').toString(),
      tone: (json['tone'] ?? 'neutral').toString(),
    );
  }
}

List<dynamic> _listOf(Object? value) {
  if (value is List<dynamic>) return value;
  return const <dynamic>[];
}

int? _intOf(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
