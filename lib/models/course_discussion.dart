class CourseDiscussion {
  final int id;
  final int courseId;
  final int userId;
  final String userName;
  final String? userPhoto;
  final String title;
  final String content;
  final bool isPinned;
  final bool isAnnouncement;
  final int likesCount;
  final int repliesCount;
  final bool isLiked;
  final DateTime createdAt;
  final List<CourseDiscussionReply> replies;

  CourseDiscussion({
    required this.id,
    required this.courseId,
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.title,
    required this.content,
    required this.isPinned,
    required this.isAnnouncement,
    required this.likesCount,
    required this.repliesCount,
    required this.isLiked,
    required this.createdAt,
    this.replies = const [],
  });

  factory CourseDiscussion.fromJson(Map<String, dynamic> json) {
    return CourseDiscussion(
      id: _parseInt(json['id']),
      courseId: _parseInt(json['course_id']),
      userId: _parseInt(json['user_id']),
      userName: json['user']?['name'] ?? 'Unknown',
      userPhoto: json['user']?['profile_photo'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      isPinned: json['is_pinned'] == true || json['is_pinned'] == 1 || json['is_pinned']?.toString() == '1',
      isAnnouncement: json['is_announcement'] == true || json['is_announcement'] == 1 || json['is_announcement']?.toString() == '1',
      likesCount: _parseInt(json['likes_count']),
      repliesCount: _parseInt(json['replies_count']),
      isLiked: json['is_liked'] == true || json['is_liked'] == 1 || json['is_liked']?.toString() == '1',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      replies: json['replies'] != null
          ? (json['replies'] as List)
              .map((i) => CourseDiscussionReply.fromJson(i))
              .toList()
          : [],
    );
  }
}

class CourseDiscussionReply {
  final int id;
  final int discussionId;
  final int userId;
  final String userName;
  final String? userPhoto;
  final String content;
  final int likesCount;
  final bool isLiked;
  final DateTime createdAt;

  CourseDiscussionReply({
    required this.id,
    required this.discussionId,
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.content,
    required this.likesCount,
    required this.isLiked,
    required this.createdAt,
  });

  factory CourseDiscussionReply.fromJson(Map<String, dynamic> json) {
    return CourseDiscussionReply(
      id: _parseInt(json['id']),
      discussionId: _parseInt(json['discussion_id']),
      userId: _parseInt(json['user_id']),
      userName: json['user']?['name'] ?? 'Unknown',
      userPhoto: json['user']?['profile_photo'],
      content: json['content'] ?? '',
      likesCount: _parseInt(json['likes_count']),
      isLiked: json['is_liked'] == true || json['is_liked'] == 1 || json['is_liked']?.toString() == '1',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
