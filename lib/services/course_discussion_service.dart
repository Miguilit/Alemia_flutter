import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import '../models/course_discussion.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CourseDiscussionService {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<CourseDiscussion>> getDiscussions(
    int courseId, {
    int page = 1,
    String filter = 'all',
    String? search,
  }) async {
    String url =
        '${AppConfig.apiBaseUrl}/courses/$courseId/discussions?page=$page&filter=$filter';
    if (search != null && search.isNotEmpty) {
      url += '&search=$search';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data']['data'] as List)
          .map((json) => CourseDiscussion.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load discussions');
    }
  }

  Future<CourseDiscussion> getDiscussionDetails(
    int courseId,
    int discussionId,
  ) async {
    final url =
        '${AppConfig.apiBaseUrl}/courses/$courseId/discussions/$discussionId';
    final response = await http.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CourseDiscussion.fromJson(data['data']);
    } else {
      throw Exception('Failed to load discussion details');
    }
  }

  Future<CourseDiscussion> postDiscussion(
    int courseId,
    String title,
    String content,
  ) async {
    final url = '${AppConfig.apiBaseUrl}/courses/$courseId/discussions';
    final response = await http.post(
      Uri.parse(url),
      headers: await _getHeaders(),
      body: jsonEncode({
        'title': title,
        'content': content,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return CourseDiscussion.fromJson(data['data']);
    } else {
      throw Exception('Failed to post discussion');
    }
  }

  Future<CourseDiscussionReply> postReply(
    int courseId,
    int discussionId,
    String content,
  ) async {
    final url =
        '${AppConfig.apiBaseUrl}/courses/$courseId/discussions/$discussionId/replies';
    final response = await http.post(
      Uri.parse(url),
      headers: await _getHeaders(),
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return CourseDiscussionReply.fromJson(data['data']);
    } else {
      throw Exception('Failed to post reply');
    }
  }

  Future<Map<String, dynamic>> toggleLikeDiscussion(
    int courseId,
    int discussionId,
  ) async {
    final url =
        '${AppConfig.apiBaseUrl}/courses/$courseId/discussions/$discussionId/like';
    final response = await http.post(
      Uri.parse(url),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'liked': data['liked'],
        'likes_count': data['likes_count'],
      };
    } else {
      throw Exception('Failed to like discussion');
    }
  }

  Future<Map<String, dynamic>> toggleLikeReply(
    int courseId,
    int replyId,
  ) async {
    final url =
        '${AppConfig.apiBaseUrl}/courses/$courseId/discussions/replies/$replyId/like';
    final response = await http.post(
      Uri.parse(url),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'liked': data['liked'],
        'likes_count': data['likes_count'],
      };
    } else {
      throw Exception('Failed to like reply');
    }
  }

  Future<void> deleteDiscussion(int courseId, int discussionId) async {
    final url =
        '${AppConfig.apiBaseUrl}/courses/$courseId/discussions/$discussionId';
    final response = await http.delete(
      Uri.parse(url),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete discussion');
    }
  }

  Future<void> deleteReply(int courseId, int discussionId, int replyId) async {
    final url =
        '${AppConfig.apiBaseUrl}/courses/$courseId/discussions/$discussionId/replies/$replyId';
    final response = await http.delete(
      Uri.parse(url),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete reply');
    }
  }
}
