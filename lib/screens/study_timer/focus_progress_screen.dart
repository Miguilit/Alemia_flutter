import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import 'task_breakdown_screen.dart';

import '../../services/focus_service.dart';

String _formatLocalizedHours(BuildContext context, double value) {
  final String languageCode = Localizations.localeOf(context).languageCode;

  return NumberFormat('0.0', languageCode).format(value);
}

String _localizedWeekday(
  BuildContext context,
  String rawDay, {
  bool abbreviated = false,
}) {
  final String normalized = rawDay.trim().toLowerCase().replaceAll('.', '');

  final Map<String, int> weekdays = <String, int>{
    'mon': DateTime.monday,
    'monday': DateTime.monday,
    'lun': DateTime.monday,
    'lundi': DateTime.monday,

    'tue': DateTime.tuesday,
    'tues': DateTime.tuesday,
    'tuesday': DateTime.tuesday,
    'mar': DateTime.tuesday,
    'mardi': DateTime.tuesday,

    'wed': DateTime.wednesday,
    'wednesday': DateTime.wednesday,
    'mer': DateTime.wednesday,
    'mercredi': DateTime.wednesday,

    'thu': DateTime.thursday,
    'thur': DateTime.thursday,
    'thurs': DateTime.thursday,
    'thursday': DateTime.thursday,
    'jeu': DateTime.thursday,
    'jeudi': DateTime.thursday,

    'fri': DateTime.friday,
    'friday': DateTime.friday,
    'ven': DateTime.friday,
    'vendredi': DateTime.friday,

    'sat': DateTime.saturday,
    'saturday': DateTime.saturday,
    'sam': DateTime.saturday,
    'samedi': DateTime.saturday,

    'sun': DateTime.sunday,
    'sunday': DateTime.sunday,
    'dim': DateTime.sunday,
    'dimanche': DateTime.sunday,
  };

  final int? weekday = weekdays[normalized];

  if (weekday == null) {
    return rawDay;
  }

  // Le 1er janvier 2024 était un lundi.
  final DateTime date = DateTime(2024, 1, weekday);

  final String languageCode = Localizations.localeOf(context).languageCode;

  return abbreviated
      ? DateFormat.E(languageCode).format(date)
      : DateFormat.EEEE(languageCode).format(date);
}

class FocusProgressScreen extends StatefulWidget {
  const FocusProgressScreen({super.key});

  @override
  State<FocusProgressScreen> createState() => _FocusProgressScreenState();
}

class _FocusProgressScreenState extends State<FocusProgressScreen> {
  final FocusService _focusService = FocusService();
  bool _isLoading = true;
  bool _hasLoadError = false;
  double _totalHours = 0;
  double _averageHours = 0;
  int _streak = 0;
  double _maxHours = 0;
  List<_DailyProgressData> _dailyProgress = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final Map<String, dynamic> data = await _focusService.getStats();

      if (!mounted) {
        return;
      }

      final List<dynamic> weeklyData = data['weekly_progress'] is List
          ? data['weekly_progress'] as List<dynamic>
          : <dynamic>[];

      final List<_DailyProgressData> dailyProgress = weeklyData.map((
        dynamic item,
      ) {
        final Map<String, dynamic> progress = item as Map<String, dynamic>;

        return _DailyProgressData(
          day: progress['day']?.toString() ?? '',
          hours: (progress['hours'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();

      double maxHours = 0;

      if (dailyProgress.isNotEmpty) {
        maxHours = dailyProgress
            .map((_DailyProgressData day) => day.hours)
            .reduce(
              (double first, double second) => first > second ? first : second,
            );
      }

      setState(() {
        _totalHours = (data['total_focus_hours'] as num?)?.toDouble() ?? 0.0;

        _averageHours =
            (data['daily_average_hours'] as num?)?.toDouble() ?? 0.0;

        _streak = (data['streak'] as num?)?.toInt() ?? 0;

        _dailyProgress = dailyProgress;
        _maxHours = maxHours;
        _hasLoadError = false;
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      debugPrint(
        'FocusProgressScreen: failed to load data: '
        '$error\n$stackTrace',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _hasLoadError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.dark
            : Brightness.light,
      ),
    );

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.getBackgroundColor(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            // Header
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
                      context.l10n.focusProgress,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.assignment_outlined,
                      size: 24,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppTheme.getPrimaryColor(context),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TaskBreakdownScreen(),
                        ),
                      );
                    },
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            // Summary Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final bool compact = constraints.maxWidth < 360;
                  final double gap = compact ? 8 : 12;

                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                          child: _StatCard(
                            icon: Icons.timer,
                            value:
                                '${_formatLocalizedHours(context, _totalHours)} '
                                '${context.l10n.hourShort}',
                            label: context.l10n.totalFocusTime,
                            color: AppTheme.getPrimaryColor(context),
                            compact: compact,
                          ),
                        ),
                        SizedBox(width: gap),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.trending_up,
                            value:
                                '${_formatLocalizedHours(context, _averageHours)} '
                                '${context.l10n.hourShort}',
                            label: context.l10n.dailyAverage,
                            color: AppTheme.softBlue800,
                            compact: compact,
                          ),
                        ),
                        SizedBox(width: gap),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.local_fire_department,
                            value: '$_streak',
                            label: context.l10n.dayStreak,
                            color: AppTheme.softOrange800,
                            compact: compact,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            // Weekly Chart Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final Text title = Text(
                    context.l10n.weeklyProgress,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                      fontFamily: 'Montserrat',
                    ),
                  );

                  final Text period = Text(
                    context.l10n.thisWeek,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: AppTheme.getTextColor(
                        context,
                      ).withValues(alpha: 0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat',
                    ),
                  );

                  if (constraints.maxWidth < 400) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        title,
                        const SizedBox(height: 4),
                        Align(alignment: Alignment.centerRight, child: period),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(child: title),
                      const SizedBox(width: 16),
                      Flexible(child: period),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Weekly Chart
            Expanded(
              child: _hasLoadError || _dailyProgress.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppTheme.getMint100(context),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedAnalytics01,
                                size: 36,
                                color: AppTheme.getAccentColor(context),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _hasLoadError
                                  ? context.l10n.failedLoadFocusProgress
                                  : context.l10n.noFocusData,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppTheme.getSecondaryTextColor(context),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (_hasLoadError) ...[
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _isLoading = true;
                                    _hasLoadError = false;
                                  });

                                  _loadData();
                                },
                                child: Text(context.l10n.retry),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppTheme.getCardColor(context),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 200,
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: _dailyProgress
                                            .map(
                                              (data) => Expanded(
                                                child: _BarChartItem(
                                                  day: _localizedWeekday(
                                                    context,
                                                    data.day,
                                                    abbreviated: true,
                                                  ),
                                                  hours: data.hours,
                                                  maxHours: _maxHours,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Legend
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: AppTheme.getPrimaryColor(
                                          context,
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      context.l10n.focusHours,
                                      style: TextStyle(
                                        color: AppTheme.getTextColor(
                                          context,
                                        ).withValues(alpha: 0.6),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Daily Details
                          Text(
                            context.l10n.dailyDetails,
                            style: TextStyle(
                              color: AppTheme.getTextColor(context),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          const SizedBox(height: 16),
                          ..._dailyProgress.map((data) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _DailyDetailCard(progress: data),
                            );
                          }),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyProgressData {
  const _DailyProgressData({required this.day, required this.hours});

  final String day;
  final double hours;
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.compact = false,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: compact ? 38 : 40,
            height: compact ? 38 : 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 20,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : color,
              ),
            ),
          ),
          SizedBox(height: compact ? 10 : 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: AppTheme.getTextColor(context),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
              fontSize: compact ? 9 : 10,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _BarChartItem extends StatelessWidget {
  const _BarChartItem({
    required this.day,
    required this.hours,
    required this.maxHours,
  });

  final String day;
  final double hours;
  final double maxHours;

  @override
  Widget build(BuildContext context) {
    final double height = maxHours > 0 ? (hours / maxHours) * 160 : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Flexible(
            child: Text(
              _formatLocalizedHours(context, hours),
              style: TextStyle(
                color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
                fontSize: 9,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            flex: 10,
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: height > 0 ? height : 4,
                maxHeight: 160,
              ),
              decoration: BoxDecoration(
                color: AppTheme.getPrimaryColor(context),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              day,
              style: TextStyle(
                color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyDetailCard extends StatelessWidget {
  const _DailyDetailCard({required this.progress});

  final _DailyProgressData progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.getMint100(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                _localizedWeekday(context, progress.day),
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : AppTheme.getPrimaryColor(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${_formatLocalizedHours(context, progress.hours)} '
                  '${context.l10n.hourShort}',
                  style: TextStyle(
                    color: AppTheme.getTextColor(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.focusTime,
                  style: TextStyle(
                    color: AppTheme.getTextColor(
                      context,
                    ).withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            size: 24,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : AppTheme.getPrimaryColor(context),
          ),
        ],
      ),
    );
  }
}
