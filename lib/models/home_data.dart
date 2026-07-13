import 'banner.dart';
import 'category.dart';
import 'course.dart';
import 'live_class.dart';

class HomeData {
  final List<BannerModel> banners;
  final List<Category> categories;
  final List<Course> popularCourses;
  final List<Course> aiSuggestions;
  final List<Course> recentCourses;
  final LiveClass? upcomingLiveClass;

  HomeData({
    required this.banners,
    required this.categories,
    required this.popularCourses,
    required this.aiSuggestions,
    required this.recentCourses,
    this.upcomingLiveClass,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return HomeData(
      banners:
          (data['banners'] as List?)
              ?.map((x) => BannerModel.fromJson(x))
              .toList() ??
          [],
      categories:
          (data['categories'] as List?)
              ?.map((x) => Category.fromJson(x))
              .toList() ??
          [],
      popularCourses:
          (data['popular_courses'] as List?)
              ?.map((x) => Course.fromJson(x))
              .toList() ??
          [],
      aiSuggestions:
          (data['ai_suggestions'] as List?)
              ?.map((x) => Course.fromJson(x))
              .toList() ??
          [],
      recentCourses:
          (data['recent_courses'] as List?)
              ?.map((x) => Course.fromJson(x))
              .toList() ??
          [],
      upcomingLiveClass: data['upcoming_live_class'] != null
          ? LiveClass.fromJson(data['upcoming_live_class'])
          : null,
    );
  }
}
