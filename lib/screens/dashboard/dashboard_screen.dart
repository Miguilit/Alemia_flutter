import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../models/dashboard_data.dart';
import '../../config/config.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../course_access/course_access_screen.dart';
import '../../router/app_router.dart';
import '../../widgets/live_class_banner.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final dashboardProvider = Provider.of<DashboardProvider>(
      context,
      listen: false,
    );
    await dashboardProvider.loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, DashboardProvider>(
      builder: (context, auth, dashboard, child) {
        if (!auth.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(AppRouter.auth);
          });
          return Scaffold(
            backgroundColor: AppTheme.getBackgroundColor(context),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (dashboard.isLoading && dashboard.dashboardData == null) {
          return Scaffold(
            backgroundColor: AppTheme.getBackgroundColor(context),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (dashboard.error != null && dashboard.dashboardData == null) {
          return Scaffold(
            backgroundColor: AppTheme.getBackgroundColor(context),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${dashboard.error}'),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final data = dashboard.dashboardData;
        final stats = dashboard.dashboardData?.stats;

        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowLeft01,
                          size: 20,
                          color: AppTheme.getTextColor(context),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                      ),
                      Expanded(
                        child: Text(
                          context.l10n.dashboard,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.getTextColor(context),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (data?.upcomingLiveClass != null) ...[
                            LiveClassBanner(
                              liveClass: data!.upcomingLiveClass!,
                              margin: const EdgeInsets.only(bottom: 24),
                            ),
                          ],
                          if (data != null && data.continueLearning.isNotEmpty) ...[
                            Text(
                              context.l10n.continueLearning,
                              style: TextStyle(
                                color: AppTheme.getTextColor(context),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _ContinueLearningHeroCard(
                              courseId: data.continueLearning.first.courseId,
                              courseTitle: data.continueLearning.first.title,
                              progress: data.continueLearning.first.progress,
                              nextLesson: data.continueLearning.first.nextLesson,
                              imageUrl: data.continueLearning.first.image,
                            ),
                            const SizedBox(height: 28),
                          ],

                          // Stats Cards
                          LayoutBuilder(
                            builder: (
                                BuildContext context,
                                BoxConstraints constraints,
                                ) {
                              final bool compact = constraints.maxWidth < 340;

                              return GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: compact ? 1 : 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: compact ? 2.55 : 1.15,
                                children: <Widget>[
                                  _StatCard(
                                    title: context.l10n.totalCourses,
                                    value: stats?.totalCourses.toString() ?? '0',
                                    icon: HugeIcons.strokeRoundedBook01,
                                    color: AppTheme.gold,
                                    onTap: () {
                                      Navigator.of(context).pushNamed(
                                        AppRouter.myCourses,
                                      );
                                    },
                                  ),
                                  _StatCard(
                                    title: context.l10n.completedCourses,
                                    value: stats?.completedCourses.toString() ?? '0',
                                    icon: Icons.check_circle,
                                    color: AppTheme.success,
                                    onTap: () {
                                      Navigator.of(context).pushNamed(
                                        AppRouter.myCourses,
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                          // Learning Activity Chart
                          Text(
                            context.l10n.learningActivity,
                            style: TextStyle(
                              color: AppTheme.getTextColor(context),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _LearningActivityChart(
                            activity: data?.activity ?? [],
                          ),
                          const SizedBox(height: 32),
                          // Quick Access Section
                          Text(
                            context.l10n.quickAccess,
                            style: TextStyle(
                              color: AppTheme.getTextColor(context),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _QuickAccessGrid(
                            items: <_QuickAccessItem>[
                              _QuickAccessItem(
                                title: context.l10n.myAssignments,
                                icon: HugeIcons.strokeRoundedAssignments,
                                route: AppRouter.myAssignments,
                              ),
                              _QuickAccessItem(
                                title: context.l10n.myQuizAttempts,
                                icon: Icons.quiz,
                                route: AppRouter.myQuizAttempts,
                              ),
                              _QuickAccessItem(
                                title: context.l10n.certificates,
                                icon: HugeIcons.strokeRoundedCertificate01,
                                route: AppRouter.certificates,
                              ),
                              _QuickAccessItem(
                                title: 'Bookings',
                                icon: HugeIcons.strokeRoundedTicket01,
                                route: AppRouter.myTicketBookings,
                              ),
                              _QuickAccessItem(
                                title: context.l10n.studyTimer,
                                icon: Icons.timer,
                                route: AppRouter.studyTimer,
                              ),
                              _QuickAccessItem(
                                title: context.l10n.messages,
                                icon: HugeIcons.strokeRoundedBubbleChat,
                                route: AppRouter.messages,
                              ),
                            ],
                          ),
                          if (data != null && data.continueLearning.length > 1) ...[
                            const SizedBox(height: 32),
                            // Continue Learning Section
                            Text(
                              context.l10n.continueLearning,
                              style: TextStyle(
                                color: AppTheme.getTextColor(context),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: data.continueLearning.length - 1,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final course = data.continueLearning[index + 1];
                                return _ContinueLearningCard(
                                  courseId: course.courseId,
                                  courseTitle: course.title,
                                  progress: course.progress,
                                  nextLesson: course.nextLesson,
                                  imageUrl: course.image,
                                );
                              },
                            ),
                          ],
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

BoxDecoration _dashboardCardDecoration(
    BuildContext context, {
      double radius = 20,
      Color? borderColor,
    }) {
  final bool isDark = AppTheme.isDark(context);

  return BoxDecoration(
    color: AppTheme.getCardColor(context),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: borderColor ?? AppTheme.getBorderColor(context),
      width: 0.8,
    ),
    boxShadow: <BoxShadow>[
      BoxShadow(
        color: Colors.black.withValues(
          alpha: isDark ? 0.24 : 0.055,
        ),
        blurRadius: 20,
        spreadRadius: -6,
        offset: const Offset(0, 8),
      ),
    ],
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String value;
  final dynamic icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _dashboardCardDecoration(
          context,
          radius: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: icon is IconData
                    ? Icon(
                        icon as IconData,
                        size: 20,
                        color: color,
                    )
                    : HugeIcon(
                        icon: icon,
                        size: 20,
                        color: color,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: AppTheme.getTextColor(context),
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.left,
                maxLines: 3,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessItem {
  const _QuickAccessItem({
    required this.title,
    required this.icon,
    required this.route,
  });

  final String title;
  final dynamic icon;
  final String route;
}

class _QuickAccessGrid extends StatelessWidget {
  const _QuickAccessGrid({required this.items});

  final List<_QuickAccessItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (
          BuildContext context,
          BoxConstraints constraints,
          ) {
        final bool compact = constraints.maxWidth < 350;
        final int columnCount = compact ? 2 : 3;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: compact ? 1.25 : 0.92,
          ),
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            final _QuickAccessItem item = items[index];

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (item.route.startsWith('/')) {
                    Navigator.of(context).pushNamed(item.route);
                  }
                },
                borderRadius: BorderRadius.circular(18),
                child: Ink(
                  decoration: _dashboardCardDecoration(
                    context,
                    radius: 18,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.getMint100(context),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.getAccentColor(context)
                                  .withValues(alpha: 0.22),
                              width: 0.8,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: item.icon is IconData
                              ? Icon(
                            item.icon as IconData,
                            size: 24,
                            color: AppTheme.getAccentColor(context),
                          )
                              : HugeIcon(
                            icon: item.icon,
                            size: 24,
                            color: AppTheme.getAccentColor(context),
                          ),
                        ),
                        const SizedBox(height: 9),
                        Flexible(
                          child: Text(
                            item.title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppTheme.getTextColor(context),
                              fontSize: compact ? 12 : 11.5,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ContinueLearningHeroCard extends StatelessWidget {
  const _ContinueLearningHeroCard({
    required this.courseId,
    required this.courseTitle,
    required this.progress,
    required this.nextLesson,
    required this.imageUrl,
  });

  final int courseId;
  final String courseTitle;
  final double progress;
  final String nextLesson;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final double safeProgress = progress.clamp(0.0, 1.0).toDouble();

    return Semantics(
      button: true,
      label: courseTitle,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return CourseAccessScreen(
                    courseId: courseId,
                    courseTitle: courseTitle,
                  );
                },
              ),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            decoration: BoxDecoration(
              color: AppTheme.black,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.gold.withValues(alpha: 0.50),
                width: 0.9,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.24),
                  blurRadius: 26,
                  spreadRadius: -8,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: AppTheme.gold.withValues(alpha: 0.08),
                  blurRadius: 20,
                  spreadRadius: -8,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 104,
                    height: 112,
                    decoration: BoxDecoration(
                      color: AppTheme.blackElevated,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppTheme.gold.withValues(alpha: 0.18),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: imageUrl != null && imageUrl!.isNotEmpty
                        ? Image.network(
                      AppConfig.getImageUrl(imageUrl),
                      fit: BoxFit.cover,
                      errorBuilder: (
                          BuildContext context,
                          Object error,
                          StackTrace? stackTrace,
                          ) {
                        return Image.asset(
                          'assets/img/banner.png',
                          fit: BoxFit.cover,
                        );
                      },
                    )
                        : Image.asset(
                      'assets/img/banner.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppTheme.gold.withValues(alpha: 0.28),
                            ),
                          ),
                          child: Text(
                            context.l10n.continueLearning,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.goldLight,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          courseTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.25,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          nextLesson,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.62),
                            fontSize: 11,
                            height: 1.3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 13),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: safeProgress,
                            minHeight: 6,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.12,
                            ),
                            valueColor:
                            const AlwaysStoppedAnimation<Color>(
                              AppTheme.goldLight,
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                '${(safeProgress * 100).toStringAsFixed(0)}% '
                                    '${context.l10n.complete}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.70),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: AppTheme.goldLight,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedArrowRight01,
                                size: 16,
                                color: AppTheme.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContinueLearningCard extends StatelessWidget {
  const _ContinueLearningCard({
    required this.courseId,
    required this.courseTitle,
    required this.progress,
    required this.nextLesson,
    required this.imageUrl,
  });

  final int courseId;
  final String courseTitle;
  final double progress;
  final String nextLesson;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CourseAccessScreen(
              courseId: courseId,
              courseTitle: courseTitle,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _dashboardCardDecoration(
          context,
          radius: 20,
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.mint200,
              ),
              clipBehavior: Clip.antiAlias,
              child: (imageUrl != null && imageUrl!.isNotEmpty)
                  ? Image.network(
                      AppConfig.getImageUrl(imageUrl),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/img/banner.png',
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset('assets/img/banner.png', fit: BoxFit.cover),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    courseTitle,
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    nextLesson,
                    style: TextStyle(
                      color: AppTheme.getTextColor(
                        context,
                      ).withValues(alpha: 0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0).toDouble(),
                      backgroundColor: AppTheme.getMint100(context),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.getAccentColor(context),
                      ),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}% ${context.l10n.complete}',
                    style: TextStyle(
                      color: AppTheme.getTextColor(
                        context,
                      ).withValues(alpha: 0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LearningActivityChart extends StatelessWidget {
  const _LearningActivityChart({required this.activity});

  final List<DashboardActivity> activity;

  @override
  Widget build(BuildContext context) {
    if (activity.isEmpty) {
      return Container(
        height: 100,
        padding: const EdgeInsets.all(20),
        decoration: _dashboardCardDecoration(
          context,
          radius: 20,
        ),
        alignment: Alignment.center,
        child: Text(
          context.l10n.noActivity,
          style: TextStyle(
            color: AppTheme.getTextColor(context).withValues(alpha: 0.5),
            fontSize: 14,
          ),
        ),
      );
    }

    final int maxCompleted = activity.fold<int>(
      0,
      (max, e) => e.lessons > max ? e.lessons : max,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _dashboardCardDecoration(
        context,
        radius: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                context.l10n.lessonsCompleted,
                style: TextStyle(
                  color: AppTheme.getTextColor(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.getMint100(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${activity.fold<int>(0, (sum, e) => sum + e.lessons)} ${context.l10n.total}',
                  style: TextStyle(
                    color: AppTheme.getPrimaryColor(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: activity.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final DashboardActivity data = entry.value;
                  final double barHeight = maxCompleted > 0
                      ? (data.lessons / maxCompleted) * 120
                      : 4;

                  // Show labels every 5 days or if it's the last day
                  final bool showLabel =
                      index % 5 == 0 || index == activity.length - 1;

                  return Container(
                    width: 32,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        if (data.lessons > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '${data.lessons}',
                              style: TextStyle(
                                color: AppTheme.getTextColor(context),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        // Bar
                        Container(
                          height: barHeight.clamp(6, 120),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppTheme.getAccentColor(context),
                                AppTheme.getAccentColor(context).withValues(alpha: 0.55),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Label
                        SizedBox(
                          height: 24,
                          child: showLabel
                              ? Text(
                                  data.label,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppTheme.getTextColor(
                                      context,
                                    ).withValues(alpha: 0.6),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
