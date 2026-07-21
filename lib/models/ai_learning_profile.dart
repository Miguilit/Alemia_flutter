class AiLearningProfile {
  const AiLearningProfile({
    required this.categoryIds,
    this.id,
    this.skillLevel,
    this.goal,
    this.customGoal,
    this.weeklyHours,
    this.targetDate,
    this.preferredLanguage = 'en',
    this.learningStyle,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final List<int> categoryIds;
  final String? skillLevel;
  final String? goal;
  final String? customGoal;
  final int? weeklyHours;
  final DateTime? targetDate;
  final String preferredLanguage;
  final String? learningStyle;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get exists => id != null;

  factory AiLearningProfile.fromJson(Map<String, dynamic> json) {
    return AiLearningProfile(
      id: _asInt(json['id']),
      categoryIds: _asIntList(json['category_ids']),
      skillLevel: _asNullableString(json['skill_level']),
      goal: _asNullableString(json['goal']),
      customGoal: _asNullableString(json['custom_goal']),
      weeklyHours: _asInt(json['weekly_hours']),
      targetDate: _asDateTime(json['target_date']),
      preferredLanguage: _asNullableString(json['preferred_language']) ?? 'en',
      learningStyle: _asNullableString(json['learning_style']),
      createdAt: _asDateTime(json['created_at']),
      updatedAt: _asDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toUpdateJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'category_ids': categoryIds,
      'skill_level': skillLevel,
      'goal': goal,
      'weekly_hours': weeklyHours,
      'preferred_language': preferredLanguage,
      'learning_style': learningStyle,
    };

    final String? normalizedGoal = customGoal?.trim();

    if (normalizedGoal != null && normalizedGoal.isNotEmpty) {
      data['custom_goal'] = normalizedGoal;
    }

    if (targetDate != null) {
      data['target_date'] = _formatDate(targetDate!);
    }

    data.removeWhere((String key, dynamic value) => value == null);

    return data;
  }

  static String _formatDate(DateTime value) {
    final String month = value.month.toString().padLeft(2, '0');
    final String day = value.day.toString().padLeft(2, '0');

    return '${value.year}-$month-$day';
  }

  static String? _asNullableString(dynamic value) {
    if (value == null) {
      return null;
    }

    final String normalized = value.toString().trim();

    return normalized.isEmpty ? null : normalized;
  }

  static int? _asInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '');
  }

  static List<int> _asIntList(dynamic value) {
    if (value is! List) {
      return const <int>[];
    }

    return value.map(_asInt).whereType<int>().toSet().toList(growable: false);
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}
