class LiveClass {
  final int id;
  final int courseId;
  final int? lessonId;
  final int instructorId;
  final String title;
  final String? description;
  final String joinUrl;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String status; // scheduled, live, ended, cancelled
  final String? recordingUrl;
  final String? recordingVideoUrl;

  LiveClass({
    required this.id,
    required this.courseId,
    this.lessonId,
    required this.instructorId,
    required this.title,
    this.description,
    required this.joinUrl,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.status,
    this.recordingUrl,
    this.recordingVideoUrl,
  });

  factory LiveClass.fromJson(Map<String, dynamic> json) {
    return LiveClass(
      id: _parseInt(json['id']),
      courseId: _parseInt(json['course_id']),
      lessonId: json['lesson_id'] != null ? _parseInt(json['lesson_id']) : null,
      instructorId: _parseInt(json['instructor_id']),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      joinUrl: json['join_url']?.toString() ?? json['join_url'] ?? '',
      scheduledAt: DateTime.parse(json['scheduled_at'] ?? DateTime.now().toIso8601String()),
      durationMinutes: _parseInt(json['duration_minutes'] ?? 60),
      status: json['status']?.toString() ?? 'scheduled',
      recordingUrl: json['recording_url']?.toString(),
      recordingVideoUrl: json['recording_video_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'lesson_id': lessonId,
      'instructor_id': instructorId,
      'title': title,
      'description': description,
      'join_url': joinUrl,
      'scheduled_at': scheduledAt.toIso8601String(),
      'duration_minutes': durationMinutes,
      'status': status,
      'recording_url': recordingUrl,
      'recording_video_url': recordingVideoUrl,
    };
  }
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
