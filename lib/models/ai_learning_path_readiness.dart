class AiLearningPathReadiness {
  const AiLearningPathReadiness({
    required this.ready,
    required this.code,
    required this.minimumRequired,
    required this.candidateCount,
    required this.publishedCatalogCount,
    required this.selectedCategoryIds,
    required this.availableCoursesByCategory,
    required this.excludedCompletedCourseIds,
    required this.matchingCatalogCount,
    required this.completedMatchingCourseIds,
    required this.candidates,
  });

  final bool ready;
  final String code;
  final int minimumRequired;
  final int candidateCount;
  final int publishedCatalogCount;
  final List<int> selectedCategoryIds;
  final Map<int, int> availableCoursesByCategory;
  final List<int> excludedCompletedCourseIds;
  final int matchingCatalogCount;
  final List<int> completedMatchingCourseIds;
  final List<Map<String, dynamic>> candidates;

  factory AiLearningPathReadiness.fromJson(Map<String, dynamic> json) {
    return AiLearningPathReadiness(
      ready: json['ready'] == true,
      code: json['code']?.toString() ?? 'UNKNOWN',
      minimumRequired: _asInt(json['minimum_required']),
      candidateCount: _asInt(json['candidate_count']),
      publishedCatalogCount: _asInt(json['published_catalog_count']),
      selectedCategoryIds: _asIntList(json['selected_category_ids']),
      availableCoursesByCategory: _asCategoryMap(
        json['available_courses_by_category'],
      ),
      excludedCompletedCourseIds: _asIntList(
        json['excluded_completed_course_ids'],
      ),
      matchingCatalogCount: _asInt(json['matching_catalog_count']),
      completedMatchingCourseIds: _asIntList(
        json['completed_matching_course_ids'],
      ),
      candidates: _asMapList(json['candidates']),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<int> _asIntList(dynamic value) {
    if (value is! List) {
      return const <int>[];
    }

    return value.map(_asInt).where((int id) => id > 0).toList(growable: false);
  }

  static Map<int, int> _asCategoryMap(dynamic value) {
    if (value is! Map) {
      return const <int, int>{};
    }

    final Map<int, int> result = <int, int>{};

    value.forEach((dynamic key, dynamic itemValue) {
      final int? categoryId = int.tryParse(key.toString());

      if (categoryId != null) {
        result[categoryId] = _asInt(itemValue);
      }
    });

    return result;
  }

  static List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is! List) {
      return const <Map<String, dynamic>>[];
    }

    return value
        .whereType<Map>()
        .map((Map<dynamic, dynamic> item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }
}
