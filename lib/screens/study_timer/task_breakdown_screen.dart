import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class TaskBreakdownScreen extends StatelessWidget {
  const TaskBreakdownScreen({super.key});

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

    final List<_TaskData> tasks = <_TaskData>[
      _TaskData(
        title: context.l10n.residualTaskMathematicsAssignment,
        description: context.l10n.residualTaskCompleteChapterExercises,
        duration: context.l10n.residualMinutesShort(25),
        status: context.l10n.residualTaskCompleted,
        color: AppTheme.getPrimaryColor(context),
      ),
      _TaskData(
        title: context.l10n.residualTaskPhysicsProblemSet,
        description: context.l10n.residualTaskSolveProblems,
        duration: context.l10n.residualMinutesShort(50),
        status: context.l10n.residualTaskInProgress,
        color: AppTheme.softOrange800,
      ),
      _TaskData(
        title: context.l10n.residualTaskChemistryLabReport,
        description: context.l10n.residualTaskWriteExperimentResults,
        duration: context.l10n.residualMinutesShort(30),
        status: context.l10n.residualTaskPending,
        color: AppTheme.softBlue800,
      ),
      _TaskData(
        title: context.l10n.residualTaskEnglishEssay,
        description: context.l10n.residualTaskDraftEssay,
        duration: context.l10n.residualMinutesShort(45),
        status: context.l10n.residualTaskPending,
        color: AppTheme.getTextColor(context).withValues(alpha: 0.3),
      ),
      _TaskData(
        title: context.l10n.residualTaskHistoryReading,
        description: context.l10n.residualTaskReadChapterNotes,
        duration: context.l10n.residualMinutesShort(40),
        status: context.l10n.residualTaskCompleted,
        color: AppTheme.getPrimaryColor(context),
      ),
    ];

    final int completedTasks = tasks
        .where((t) => t.status == context.l10n.residualTaskCompleted)
        .length;
    final int totalTasks = tasks.length;
    final double completionRate = completedTasks / totalTasks;

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
                      context.l10n.taskBreakdown,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            // Progress Overview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      AppTheme.getPrimaryColor(context),
                      AppTheme.getPrimaryColor(context).withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.assignment_turned_in,
                          size: 32,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '${(completionRate * 100).toInt()}%',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            Text(
                              context.l10n.completed,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Text(
                              '$completedTasks',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            Text(
                              context.l10n.completedTasks,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        Column(
                          children: <Widget>[
                            Text(
                              '${totalTasks - completedTasks}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            Text(
                              context.l10n.remaining,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Tasks List
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      context.l10n.allTasks,
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...tasks.map((task) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _TaskCard(task: task),
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

class _TaskData {
  const _TaskData({
    required this.title,
    required this.description,
    required this.duration,
    required this.status,
    required this.color,
  });

  final String title;
  final String description;
  final String duration;
  final String status;
  final Color color;
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});

  final _TaskData task;

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = task.status == context.l10n.residualTaskCompleted;
    final bool isInProgress =
        task.status == context.l10n.residualTaskInProgress;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? AppTheme.getPrimaryColor(context).withValues(alpha: 0.3)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: <Widget>[
          // Status Indicator
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppTheme.getPrimaryColor(context)
                  : isInProgress
                  ? AppTheme.softOrange800
                  : AppTheme.getTextColor(context).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          color: AppTheme.getTextColor(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Montserrat',
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                    if (isCompleted)
                      Icon(
                        Icons.check_circle,
                        size: 20,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : AppTheme.getPrimaryColor(context),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  task.description,
                  style: TextStyle(
                    color: AppTheme.getTextColor(
                      context,
                    ).withValues(alpha: 0.6),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.getMint100(context),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.timer_outlined,
                            size: 12,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : AppTheme.getPrimaryColor(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            task.duration,
                            style: TextStyle(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : AppTheme.getPrimaryColor(context),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppTheme.getPrimaryColor(
                                context,
                              ).withValues(alpha: 0.15)
                            : isInProgress
                            ? AppTheme.softOrange800.withValues(alpha: 0.15)
                            : AppTheme.getBackgroundColor(context),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        task.status,
                        style: TextStyle(
                          color: isCompleted
                              ? (Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : AppTheme.getPrimaryColor(context))
                              : isInProgress
                              ? AppTheme.softOrange800
                              : AppTheme.getTextColor(
                                  context,
                                ).withValues(alpha: 0.6),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
