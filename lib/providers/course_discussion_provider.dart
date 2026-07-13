import 'package:flutter/material.dart';
import '../models/course_discussion.dart';
import '../services/course_discussion_service.dart';

class CourseDiscussionProvider extends ChangeNotifier {
  final CourseDiscussionService _service = CourseDiscussionService();

  List<CourseDiscussion> _discussions = [];
  CourseDiscussion? _selectedDiscussion;
  
  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _error;
  
  int _currentPage = 1;
  bool _hasMore = true;
  String _currentFilter = 'all';
  String? _currentSearch;

  List<CourseDiscussion> get discussions => _discussions;
  CourseDiscussion? get selectedDiscussion => _selectedDiscussion;
  
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  Future<void> fetchDiscussions(
    int courseId, {
    bool refresh = false,
    String filter = 'all',
    String? search,
  }) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _discussions = [];
      _currentFilter = filter;
      _currentSearch = search;
    }

    if (!_hasMore && !refresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newDiscussions = await _service.getDiscussions(
        courseId,
        page: _currentPage,
        filter: _currentFilter,
        search: _currentSearch,
      );

      if (newDiscussions.isEmpty) {
        _hasMore = false;
      } else {
        _discussions.addAll(newDiscussions);
        _currentPage++;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDiscussionDetails(int courseId, int discussionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedDiscussion = await _service.getDiscussionDetails(courseId, discussionId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createDiscussion(int courseId, String title, String content) async {
    _isActionLoading = true;
    notifyListeners();

    try {
      await _service.postDiscussion(courseId, title, content);
      await fetchDiscussions(courseId, refresh: true, filter: _currentFilter, search: _currentSearch);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> createReply(int courseId, int discussionId, String content) async {
    _isActionLoading = true;
    notifyListeners();

    try {
      await _service.postReply(courseId, discussionId, content);
      await fetchDiscussionDetails(courseId, discussionId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleLikeDiscussion(int courseId, int discussionId) async {
    // Optimistic UI updates
    final index = _discussions.indexWhere((d) => d.id == discussionId);
    
    // Backup for rollback
    bool oldLiked = false;
    int oldLikesCount = 0;
    
    if (index != -1) {
      final d = _discussions[index];
      oldLiked = d.isLiked;
      oldLikesCount = d.likesCount;
      
      _discussions[index] = CourseDiscussion(
        id: d.id,
        courseId: d.courseId,
        userId: d.userId,
        userName: d.userName,
        userPhoto: d.userPhoto,
        title: d.title,
        content: d.content,
        isPinned: d.isPinned,
        isAnnouncement: d.isAnnouncement,
        likesCount: d.isLiked ? d.likesCount - 1 : d.likesCount + 1,
        repliesCount: d.repliesCount,
        isLiked: !d.isLiked,
        createdAt: d.createdAt,
        replies: d.replies,
      );
    }

    if (_selectedDiscussion != null && _selectedDiscussion!.id == discussionId) {
      final d = _selectedDiscussion!;
      _selectedDiscussion = CourseDiscussion(
        id: d.id,
        courseId: d.courseId,
        userId: d.userId,
        userName: d.userName,
        userPhoto: d.userPhoto,
        title: d.title,
        content: d.content,
        isPinned: d.isPinned,
        isAnnouncement: d.isAnnouncement,
        likesCount: d.isLiked ? d.likesCount - 1 : d.likesCount + 1,
        repliesCount: d.repliesCount,
        isLiked: !d.isLiked,
        createdAt: d.createdAt,
        replies: d.replies,
      );
    }
    
    notifyListeners();

    try {
      final result = await _service.toggleLikeDiscussion(courseId, discussionId);
      
      // Update with exact values from server
      if (index != -1) {
        final d = _discussions[index];
        _discussions[index] = _copyWithLike(d, result['liked'], result['likes_count']);
      }
      if (_selectedDiscussion != null && _selectedDiscussion!.id == discussionId) {
        _selectedDiscussion = _copyWithLike(_selectedDiscussion!, result['liked'], result['likes_count']);
      }
      notifyListeners();
    } catch (e) {
      // Rollback on failure
      if (index != -1) {
        final d = _discussions[index];
        _discussions[index] = _copyWithLike(d, oldLiked, oldLikesCount);
      }
      if (_selectedDiscussion != null && _selectedDiscussion!.id == discussionId) {
        _selectedDiscussion = _copyWithLike(_selectedDiscussion!, oldLiked, oldLikesCount);
      }
      notifyListeners();
    }
  }

  Future<void> toggleLikeReply(int courseId, int replyId) async {
    if (_selectedDiscussion == null) return;

    final replies = List<CourseDiscussionReply>.from(_selectedDiscussion!.replies);
    final index = replies.indexWhere((r) => r.id == replyId);
    if (index == -1) return;

    final r = replies[index];
    final oldLiked = r.isLiked;
    final oldLikesCount = r.likesCount;

    // Optimistic Update
    replies[index] = CourseDiscussionReply(
      id: r.id,
      discussionId: r.discussionId,
      userId: r.userId,
      userName: r.userName,
      userPhoto: r.userPhoto,
      content: r.content,
      likesCount: r.isLiked ? r.likesCount - 1 : r.likesCount + 1,
      isLiked: !r.isLiked,
      createdAt: r.createdAt,
    );

    _selectedDiscussion = _copyWithReplies(_selectedDiscussion!, replies);
    notifyListeners();

    try {
      final result = await _service.toggleLikeReply(courseId, replyId);
      
      // Update with exact values
      replies[index] = CourseDiscussionReply(
        id: r.id,
        discussionId: r.discussionId,
        userId: r.userId,
        userName: r.userName,
        userPhoto: r.userPhoto,
        content: r.content,
        likesCount: result['likes_count'],
        isLiked: result['liked'],
        createdAt: r.createdAt,
      );
      _selectedDiscussion = _copyWithReplies(_selectedDiscussion!, replies);
      notifyListeners();
    } catch (e) {
      // Rollback
      replies[index] = CourseDiscussionReply(
        id: r.id,
        discussionId: r.discussionId,
        userId: r.userId,
        userName: r.userName,
        userPhoto: r.userPhoto,
        content: r.content,
        likesCount: oldLikesCount,
        isLiked: oldLiked,
        createdAt: r.createdAt,
      );
      _selectedDiscussion = _copyWithReplies(_selectedDiscussion!, replies);
      notifyListeners();
    }
  }

  Future<void> deleteDiscussion(int courseId, int discussionId) async {
    _isActionLoading = true;
    notifyListeners();

    try {
      await _service.deleteDiscussion(courseId, discussionId);
      _discussions.removeWhere((d) => d.id == discussionId);
      if (_selectedDiscussion?.id == discussionId) {
        _selectedDiscussion = null;
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteReply(int courseId, int discussionId, int replyId) async {
    _isActionLoading = true;
    notifyListeners();

    try {
      await _service.deleteReply(courseId, discussionId, replyId);
      if (_selectedDiscussion != null) {
        final replies = List<CourseDiscussionReply>.from(_selectedDiscussion!.replies);
        replies.removeWhere((r) => r.id == replyId);
        _selectedDiscussion = _copyWithReplies(_selectedDiscussion!, replies);
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  CourseDiscussion _copyWithLike(CourseDiscussion d, bool isLiked, int likesCount) {
    return CourseDiscussion(
      id: d.id,
      courseId: d.courseId,
      userId: d.userId,
      userName: d.userName,
      userPhoto: d.userPhoto,
      title: d.title,
      content: d.content,
      isPinned: d.isPinned,
      isAnnouncement: d.isAnnouncement,
      likesCount: likesCount,
      repliesCount: d.repliesCount,
      isLiked: isLiked,
      createdAt: d.createdAt,
      replies: d.replies,
    );
  }

  CourseDiscussion _copyWithReplies(CourseDiscussion d, List<CourseDiscussionReply> replies) {
    return CourseDiscussion(
      id: d.id,
      courseId: d.courseId,
      userId: d.userId,
      userName: d.userName,
      userPhoto: d.userPhoto,
      title: d.title,
      content: d.content,
      isPinned: d.isPinned,
      isAnnouncement: d.isAnnouncement,
      likesCount: d.likesCount,
      repliesCount: replies.length,
      isLiked: d.isLiked,
      createdAt: d.createdAt,
      replies: replies,
    );
  }
}
