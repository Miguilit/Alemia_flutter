import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:vimeo_video_player/vimeo_video_player.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:convert';

import 'package:hugeicons/hugeicons.dart';
import '../../l10n/app_localizations.dart';
import '../../router/app_router.dart';
import '../../services/student_course_service.dart';
import '../../theme/app_theme.dart';
import 'quiz_attempt_screen.dart';
import 'assignment_submit_screen.dart';
import 'widgets/course_discussion_tab.dart';

class CourseAccessScreen extends StatefulWidget {
  final int courseId;
  final String courseTitle;

  const CourseAccessScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<CourseAccessScreen> createState() => _CourseAccessScreenState();
}

class _CourseAccessScreenState extends State<CourseAccessScreen> {
  final StudentCourseService _studentCourseService = StudentCourseService();

  bool _isLoading = true;
  String? _error;
  String? _videoError;

  Map<String, dynamic>? _currentLesson;
  List<dynamic> _topics = [];

  // Video Controllers
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  YoutubePlayerController? _youtubePlayerController;
  String? _vimeoVideoId;

  bool _isVideoLoading = false;

  @override
  void initState() {
    super.initState();
    // Block screenshots & screen recording to protect course content
    NoScreenshot.instance.screenshotOff();
    _fetchCourseCurriculum();
  }

  @override
  void dispose() {
    // Re-enable screenshots when leaving the protected screen
    NoScreenshot.instance.screenshotOn();
    _disposeVideoControllers();
    super.dispose();
  }

  void _disposeVideoControllers() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _youtubePlayerController?.dispose();
    _videoPlayerController = null;
    _chewieController = null;
    _youtubePlayerController = null;
    _vimeoVideoId = null;
  }

  Future<void> _fetchCourseCurriculum() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _studentCourseService.getCourseCurriculum(
        widget.courseId,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _topics = data['data']['topics'] ?? [];
            _isLoading = false;
          });

          // Load current item if available
          if (data['data']['current_item'] != null) {
            final currentItem = data['data']['current_item'];
            if (currentItem['type'] == 'lesson') {
              // Wait for UI build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _loadLesson(currentItem['id']);
              });
            }
          }
        } else {
          setState(() {
            _error = data['message'] ?? context.l10n.failedToLoadCourseData;
            _isLoading = false;
          });
        }
      } else {
        if (response.statusCode == 403) {
          setState(() {
            _error = context.l10n.accessDeniedCourse;
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = '${context.l10n.failedToLoadCourse} (${response.statusCode})';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadLesson(int lessonId) async {
    setState(() {
      _isVideoLoading = true;
      _videoError = null;
    });

    // Pause existing players
    _disposeVideoControllers();

    try {
      final response = await _studentCourseService.loadLesson(
        widget.courseId,
        lessonId,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          if (!mounted) return;

          final lessonData = data['data'] as Map<String, dynamic>;
          final lesson = lessonData['lesson'];
          final isLiveLesson =
              lesson != null &&
              (lesson['is_live'] == true || lesson['is_live'] == 1);

          setState(() {
            _currentLesson = lessonData;
            _videoError = null;
          });

          if (isLiveLesson) {
            setState(() {
              _isVideoLoading = false;
            });
          } else {
            final videoData = lessonData['video'];

            if (videoData is Map<String, dynamic>) {
              _initializeVideoPlayer(videoData);
            } else {
              setState(() {
                _isVideoLoading = false;
              });
            }
          }
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${context.l10n.failedToLoadLesson} (${response.statusCode})'),
          ),
        );
      }
    } catch (e) {
      // debugPrint('Error loading lesson: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isVideoLoading = false;
        });
      }
    }
  }

  void _initializeVideoPlayer(Map<String, dynamic> videoData) {
    if (videoData['is_youtube'] == true && videoData['video_id'] != null) {
      _youtubePlayerController = YoutubePlayerController(
        initialVideoId: videoData['video_id'],
        flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
      );
      setState(() {
        _isVideoLoading = false;
      });
    } else if (videoData['is_vimeo'] == true && videoData['video_id'] != null) {
      setState(() {
        _vimeoVideoId = videoData['video_id'];
        _isVideoLoading = false;
      });
    } else if (videoData['url'] != null) {
      // debugPrint('Initializing video with URL: ${videoData['url']}');
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(videoData['url']),
      );
      _videoPlayerController!
          .initialize()
          .then((_) {
            if (!mounted) return;

            setState(() {
              _chewieController = ChewieController(
                videoPlayerController: _videoPlayerController!,
                autoPlay: true,
                looping: false,
                aspectRatio: _videoPlayerController!.value.aspectRatio,
                deviceOrientationsOnEnterFullScreen: const [
                  DeviceOrientation.landscapeLeft,
                  DeviceOrientation.landscapeRight,
                ],
                deviceOrientationsAfterFullScreen: const [
                  DeviceOrientation.portraitUp,
                ],
                systemOverlaysOnEnterFullScreen: const [],
                systemOverlaysAfterFullScreen: SystemUiOverlay.values,
                errorBuilder: (context, errorMessage) {
                  if (kDebugMode) {
                    debugPrint('Chewie playback error: $errorMessage');
                  }

                  return _VideoUnavailableView(
                      title: context.l10n.videoUnavailable,
                      message: context.l10n.videoUnavailableMessage,
                  );
                },
              );
              _isVideoLoading = false;
            });
          })
          .catchError((Object error, StackTrace stackTrace) {
            if (!mounted) return;

            setState(() {
              _isVideoLoading = false;
              _videoError =
                  context.l10n.videoUnavailableMessage;
            });

            if (kDebugMode) {
              debugPrint('Video initialization error: $error');
              debugPrint('Video URL: ${videoData['url']}');
              debugPrintStack(stackTrace: stackTrace);
            }
          });
    } else {
      setState(() {
        _isVideoLoading = false;
      });
    }
  }

  Future<void> _markComplete() async {
    if (_currentLesson == null) return;

    try {
      final lessonId = _currentLesson!['lesson']['id'];
      final response = await _studentCourseService.markLessonComplete(
        widget.courseId,
        lessonId,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(context.l10n.lessonCompleted)));

          // Refresh curriculum to show checkmark
          _fetchCourseCurriculum();

          // Auto-advance if next item exists
          if (data['next_item'] != null) {
            final next = data['next_item'];
            if (next['type'] == 'lesson') {
              _loadLesson(next['id']);
            }
          }
        }
      }
    } catch (e) {
      // debugPrint(e.toString());
    }
  }

  List<dynamic> _getFlattenedItems() {
    final List<dynamic> items = [];
    for (var topic in _topics) {
      if (topic['items'] != null) {
        items.addAll(topic['items']);
      }
    }
    return items;
  }

  int _getCurrentIndex() {
    if (_currentLesson == null) return -1;
    final allItems = _getFlattenedItems();
    final currentId = _currentLesson!['lesson']['id'];
    return allItems.indexWhere(
      (item) => item['id'] == currentId && item['type'] == 'lesson',
    );
  }

  bool _hasPreviousItem() {
    final index = _getCurrentIndex();
    return index > 0;
  }

  bool _hasNextItem() {
    final index = _getCurrentIndex();
    final allItems = _getFlattenedItems();
    // Check if next item exists and is accessible
    if (index >= 0 && index < allItems.length - 1) {
      // Find next lesson (skip non-lessons if needed, but for now navigate all)
      // Assuming we only navigate lessons here or handle types in load
      return true;
    }
    return false;
  }

  void _goToPrevious() {
    final index = _getCurrentIndex();
    if (index > 0) {
      final allItems = _getFlattenedItems();
      final prevItem = allItems[index - 1];
      if (prevItem['type'] == 'lesson') {
        _loadLesson(prevItem['id']);
      }
    }
  }

  void _goToNext() {
    final index = _getCurrentIndex();
    final allItems = _getFlattenedItems();
    if (index >= 0 && index < allItems.length - 1) {
      final nextItem = allItems[index + 1];

      if (nextItem['is_accessible'] == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              (context.l10n.lessonLocked),
            ),
          ),
        );
        return;
      }

      if (nextItem['type'] == 'lesson') {
        _loadLesson(nextItem['id']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_youtubePlayerController != null) {
      return YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _youtubePlayerController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: AppTheme.primary,
        ),
        builder: (context, player) {
          return _buildScaffold(context, player);
        },
      );
    }
    return _buildScaffold(context, null);
  }

  Widget _buildScaffold(BuildContext context, Widget? youtubePlayer) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed(AppRouter.aiChat);
          },
          backgroundColor: AppTheme.primary,
          child: const HugeIcon(
            icon: HugeIcons.strokeRoundedAiChat02,
            size: 24,
            color: Colors.white,
          ),
        ),
        appBar: AppBar(
          title: Text(widget.courseTitle),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              )
            : Column(
                children: [
                  // Video Player Section
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      color: Colors.black,
                      child: _isVideoLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : (youtubePlayer ?? _buildVideoPlayer()),
                    ),
                  ),
  
                  // Lesson Title & Controls
                  if (_currentLesson != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: _hasPreviousItem()
                                    ? _goToPrevious
                                    : null,
                                icon: const Icon(Icons.arrow_back_ios),
                                tooltip: context.l10n.previousLesson,
                              ),
                              Expanded(
                                child: Text(
                                  _currentLesson!['lesson']['title'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              IconButton(
                                onPressed: _hasNextItem() ? _goToNext : null,
                                icon: const Icon(Icons.arrow_forward_ios),
                                tooltip: context.l10n.nextLesson,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _markComplete,
                                icon: const Icon(Icons.check_circle_outline),
                                label: Text(context.l10n.markComplete),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.getPrimaryColor(
                                    context,
                                  ),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
  
                  const Divider(height: 1),
  
                  TabBar(
                    labelColor: AppTheme.getPrimaryColor(context),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppTheme.getPrimaryColor(context),
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: [
                      Tab(
                        icon: const Icon(Icons.menu_book),
                        text: context.l10n.curriculum,
                      ),
                      Tab(
                        icon: const Icon(Icons.forum_outlined),
                        text: context.l10n.forums,
                      ),
                    ],
                  ),
                  const Divider(height: 1),
  
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Tab 1: Curriculum List
                        ListView.builder(
                          itemCount: _topics.length,
                          itemBuilder: (context, index) {
                            final topic = _topics[index];
                            final items = topic['items'] as List<dynamic>;
  
                            return ExpansionTile(
                              title: Text(topic['title']),
                              initiallyExpanded: index == 0,
                              children: items.map((item) {
                                final isLesson = item['type'] == 'lesson';
                                final isCompleted = item['is_completed'] == true;
                                final isLocked = item['is_accessible'] == false;
                                final isCurrent =
                                    _currentLesson != null &&
                                    _currentLesson!['lesson']['id'] == item['id'] &&
                                    item['type'] == 'lesson';
  
                                return ListTile(
                                  leading: Icon(
                                    isLocked
                                        ? Icons.lock
                                        : (isLesson
                                              ? Icons.play_circle_outline
                                              : Icons.quiz),
                                    color: isLocked
                                        ? Colors.grey
                                        : (isCurrent
                                              ? AppTheme.getPrimaryColor(context)
                                              : null),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item['title'],
                                          style: TextStyle(
                                            color: isCurrent
                                                ? AppTheme.getPrimaryColor(context)
                                                : null,
                                            fontWeight: isCurrent
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      if (item['is_live'] == true || item['is_live'] == 1) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: item['live_class']?['status'] == 'live' ? Colors.red : Colors.blue,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            item['live_class']?['status'] == 'live'
                                                ? context.l10n.live
                                                : context.l10n.liveClassLabel,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ]
                                    ],
                                  ),
                                  trailing: isCompleted
                                      ? const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        )
                                      : null,
                                  onTap: isLocked
                                      ? null
                                      : () {
                                          if (isLesson) {
                                            _loadLesson(item['id']);
                                          } else if (item['type'] == 'quiz') {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    QuizAttemptScreen(
                                                      courseId: widget.courseId,
                                                      quizId: item['id'],
                                                      quizTitle: item['title'],
                                                      showAppBar: true,
                                                    ),
                                              ),
                                            ).then(
                                              (_) => _fetchCourseCurriculum(),
                                            ); // Refresh on return
                                          } else if (item['type'] == 'assignment') {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AssignmentSubmitScreen(
                                                      courseId: widget.courseId,
                                                      assignmentId: item['id'],
                                                      assignmentTitle: item['title'],
                                                      showAppBar: true,
                                                    ),
                                              ),
                                            ).then(
                                              (_) => _fetchCourseCurriculum(),
                                            ); // Refresh on return
                                          } else {
                                            // Handle unknown types
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  context.l10n.unsupportedItemType,
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                );
                              }).toList(),
                            );
                          },
                        ),
                        // Tab 2: Course Discussions Tab View
                        CourseDiscussionTab(courseId: widget.courseId),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    final lessonData = _currentLesson?['lesson'];
    final isLive = lessonData != null && (lessonData['is_live'] == 1 || lessonData['is_live'] == true);
    final liveClass = lessonData?['live_class'];

    if (isLive && liveClass != null) {
      final classStatus = liveClass['status'];
      final isClassLive = classStatus == 'live';
      final isClassEnded = classStatus == 'ended';
      final scheduledAtStr = liveClass['scheduled_at'];
      final formattedTime = scheduledAtStr != null 
          ? DateFormat('MMM dd, yyyy @ hh:mm a').format(DateTime.parse(scheduledAtStr).toLocal())
          : context.l10n.notAvailable;

      return Container(
        color: const Color(0xFF1E293B),
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isClassLive ? Colors.redAccent : Colors.deepPurpleAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isClassLive) ...[
                      const Icon(Icons.circle, color: Colors.white, size: 10),
                      const SizedBox(width: 6),
                      Text(
                        context.l10n.liveNow,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ] else if (isClassEnded) ...[
                      Text(
                        context.l10n.sessionEnded,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ] else ...[
                      const Icon(Icons.calendar_month, color: Colors.white, size: 12),
                      const SizedBox(width: 6),
                      Text(
                        context.l10n.scheduled,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                liveClass['title'] ?? context.l10n.liveClassSession,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (!isClassLive && !isClassEnded)
                Text(
                  '${context.l10n.startsAt}: $formattedTime',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),
              if (!isClassEnded)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1E293B),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    final joinUrl = liveClass['recording_url'] ?? liveClass['join_url'] ?? '';
                    if (joinUrl.isNotEmpty) {
                      final uri = Uri.parse(joinUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    }
                  },
                  icon: const Icon(Icons.videocam),
                  label: Text(
                    isClassLive
                        ? context.l10n.joinLiveClass
                        : context.l10n.openJoiningLink,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              if (isClassEnded)
                Text(
                  context.l10n.liveSessionEndedMessage,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      );
    }

    if (_youtubePlayerController != null) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    } else if (_vimeoVideoId != null) {
      return VimeoVideoPlayer(videoId: _vimeoVideoId!);
    } else if (_chewieController != null &&
        _videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized) {
      return Chewie(controller: _chewieController!);
    } else {
      if (_videoError != null) {
        return _VideoUnavailableView(
          title: context.l10n.videoUnavailable,
          message: _videoError!,
          onRetry: () {
            setState(() {
              _videoError = null;
            });

            final lessonId = _currentLesson?['lesson']?['id'];
            if (lessonId is int) {
              _loadLesson(lessonId);
            }
          },
        );
      }
      return Center(
        child: Text(
          context.l10n.selectLessonToPlay,
          style: const TextStyle(color: Colors.white),
        ),
      );
    }
  }
}

class _VideoUnavailableView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const _VideoUnavailableView({
    required this.title,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF111827),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.videocam_off_outlined,
              color: Colors.white70,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(context.l10n.retry),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

