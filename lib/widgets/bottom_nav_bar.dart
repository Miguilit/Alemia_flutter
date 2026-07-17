import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../screens/home/home_screen.dart';
import '../screens/courses/courses_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/instructor/all_instructors_screen.dart';
import '../screens/events/events_screen.dart';

enum BottomNavTab {
  home,
  instructors,
  courses,
  events,
  profile,
}

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentTab,
  });

  final BottomNavTab currentTab;

  void _replaceWith(BuildContext context, Widget page) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            ) {
          return page;
        },
        transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
            ) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 180),
        reverseTransitionDuration: const Duration(milliseconds: 150),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Container(
        height: 78,
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: AppTheme.getBorderColor(context).withValues(
              alpha: isDark ? 0.90 : 0.75,
            ),
            width: 0.8,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(
                alpha: isDark ? 0.30 : 0.10,
              ),
              blurRadius: 26,
              spreadRadius: -5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 7,
            vertical: 7,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: _BottomNavItem(
                  label: context.l10n.home,
                  icon: HugeIcons.strokeRoundedHome01,
                  isActive: currentTab == BottomNavTab.home,
                  onTap: () {
                    if (currentTab != BottomNavTab.home) {
                      _replaceWith(
                        context,
                        const HomeScreen(),
                      );
                    }
                  },
                ),
              ),
              Expanded(
                child: _BottomNavItem(
                  // Le getter "instructor" existe déjà dans tes traductions.
                  label: context.l10n.instructor,
                  icon: HugeIcons.strokeRoundedUserGroup,
                  isActive: currentTab == BottomNavTab.instructors,
                  onTap: () {
                    if (currentTab != BottomNavTab.instructors) {
                      _replaceWith(
                        context,
                        const AllInstructorsScreen(),
                      );
                    }
                  },
                ),
              ),
              Expanded(
                child: _BottomNavItem(
                  label: context.l10n.courses,
                  icon: HugeIcons.strokeRoundedBook01,
                  isActive: currentTab == BottomNavTab.courses,
                  onTap: () {
                    if (currentTab != BottomNavTab.courses) {
                      _replaceWith(
                        context,
                        const CoursesScreen(),
                      );
                    }
                  },
                ),
              ),
              Expanded(
                child: _BottomNavItem(
                  label: context.l10n.events,
                  icon: HugeIcons.strokeRoundedCalendar01,
                  isActive: currentTab == BottomNavTab.events,
                  onTap: () {
                    if (currentTab != BottomNavTab.events) {
                      _replaceWith(
                        context,
                        const EventsScreen(),
                      );
                    }
                  },
                ),
              ),
              Expanded(
                child: _BottomNavItem(
                  label: context.l10n.profile,
                  icon: HugeIcons.strokeRoundedProfile,
                  isActive: currentTab == BottomNavTab.profile,
                  onTap: () {
                    // Comportement actuel conservé :
                    // le profil reste un écran secondaire.
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) {
                          return const ProfileScreen();
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final dynamic icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    final Color accentColor =
    AppTheme.getAccentColor(context);

    final Color inactiveColor =
    AppTheme.getSecondaryTextColor(context);

    final Color activeIconColor = AppTheme.black;

    final Color activeTextColor = isDark
        ? AppTheme.goldLight
        : AppTheme.black;

    return Semantics(
      button: true,
      selected: isActive,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 2,
              vertical: 2,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  width: 40,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isActive
                        ? accentColor.withValues(
                      alpha: isDark ? 0.95 : 0.18,
                    )
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: icon,
                      size: 21,
                      color: isActive
                          ? activeIconColor
                          : inactiveColor,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isActive
                        ? activeTextColor
                        : inactiveColor,
                    fontSize: 10,
                    height: 1.15,
                    fontWeight: isActive
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}