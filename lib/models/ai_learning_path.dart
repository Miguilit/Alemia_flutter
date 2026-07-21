class AiLearningPath {
  const AiLearningPath({
    required this.id,
    required this.title,
    required this.summary,
    required this.status,
    required this.generationMode,
    required this.locale,
    required this.estimatedWeeks,
    required this.steps,
    this.generatedAt,
  });

  final int id;
  final String title;
  final String summary;
  final String status;
  final String generationMode;
  final String locale;
  final int estimatedWeeks;
  final DateTime? generatedAt;
  final List<AiLearningPathStep> steps;

  bool get isActive => status == 'active';

  bool get wasGeneratedByGemini =>
      generationMode == 'hybrid' || generationMode == 'gemini';

  factory AiLearningPath.fromJson(Map<String, dynamic> json) {
    return AiLearningPath(
      id: _asInt(json['id']),
      title: json['title']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      generationMode: json['generation_mode']?.toString() ?? 'rules',
      locale: json['locale']?.toString() ?? 'en',
      estimatedWeeks: _asInt(json['estimated_weeks']),
      generatedAt: _asDateTime(json['generated_at']),
      steps: _asList(
        json['steps'],
      ).map(AiLearningPathStep.fromJson).toList(growable: false),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }

  static List<Map<String, dynamic>> _asList(dynamic value) {
    if (value is! List) {
      return const <Map<String, dynamic>>[];
    }

    return value
        .whereType<Map>()
        .map((Map<dynamic, dynamic> item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }
}

class AiLearningPathStep {
  const AiLearningPathStep({
    required this.id,
    required this.courseId,
    required this.position,
    required this.stage,
    required this.objective,
    required this.reason,
    required this.estimatedHours,
    required this.recommendationScore,
    required this.course,
  });

  final int id;
  final int courseId;
  final int position;
  final String stage;
  final String objective;
  final String reason;
  final int estimatedHours;
  final double recommendationScore;
  final AiLearningPathCourse course;

  factory AiLearningPathStep.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> courseJson = _asMap(json['course']);

    final int courseId = _asInt(json['course_id'] ?? courseJson['id']);

    return AiLearningPathStep(
      id: _asInt(json['id']),
      courseId: courseId,
      position: _asInt(json['position']),
      stage: json['stage']?.toString() ?? '',
      objective: json['objective']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      estimatedHours: _asInt(json['estimated_hours']),
      recommendationScore: _asDouble(json['recommendation_score']),
      course: AiLearningPathCourse.fromJson(<String, dynamic>{
        ...courseJson,
        'id': courseId,
      }),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }
}

class AiLearningPathCourse {
  const AiLearningPathCourse({
    required this.id,
    required this.title,
    this.slug,
    this.thumbnail,
    this.difficulty,
    this.language,
    this.categoryName,
    this.instructorName,
  });

  final int id;
  final String title;
  final String? slug;
  final String? thumbnail;
  final String? difficulty;
  final String? language;
  final String? categoryName;
  final String? instructorName;

  factory AiLearningPathCourse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> category = _asMap(json['category']);

    final Map<String, dynamic> instructor = _asMap(json['instructor']);

    return AiLearningPathCourse(
      id: _asInt(json['id']),
      title: json['title']?.toString() ?? '',
      slug: _nullableString(json['slug']),
      thumbnail: _nullableString(json['thumbnail'] ?? json['featured_image']),
      difficulty: _nullableString(json['difficulty']),
      language: _nullableString(json['language']),
      categoryName: _nullableString(json['category_name'] ?? category['name']),
      instructorName: _nullableString(
        json['instructor_name'] ?? instructor['name'],
      ),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String? _nullableString(dynamic value) {
    if (value == null) {
      return null;
    }

    final String normalized = value.toString().trim();

    return normalized.isEmpty ? null : normalized;
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }
}
