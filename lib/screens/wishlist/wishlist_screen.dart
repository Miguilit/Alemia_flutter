import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

import '../../config/config.dart';
import '../../l10n/app_localizations.dart';
import '../../models/course.dart';
import '../../providers/settings_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../theme/app_theme.dart';
import '../course_detail/course_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  String _sortBy = 'recent';
  final Set<int> _updatingCourseIds = <int>{};

  List<Course> _sortedCourses(List<Course> source) {
    final List<Course> items = List<Course>.from(source);

    switch (_sortBy) {
      case 'price_asc':
        items.sort(
          (Course a, Course b) =>
              _effectivePrice(a).compareTo(_effectivePrice(b)),
        );
        break;

      case 'price_desc':
        items.sort(
          (Course a, Course b) =>
              _effectivePrice(b).compareTo(_effectivePrice(a)),
        );
        break;

      case 'rating':
        items.sort(
          (Course a, Course b) => (b.rating ?? 0).compareTo(a.rating ?? 0),
        );
        break;

      case 'recent':
      default:
        break;
    }

    return items;
  }

  double _effectivePrice(Course course) {
    final double regularPrice = course.price ?? 0;
    final double? discountedPrice = course.discountedPrice;

    if (discountedPrice != null && discountedPrice < regularPrice) {
      return discountedPrice;
    }

    return regularPrice;
  }

  Future<void> _removeFromWishlist({
    required Course course,
    required WishlistProvider provider,
  }) async {
    if (_updatingCourseIds.contains(course.id)) {
      return;
    }

    setState(() {
      _updatingCourseIds.add(course.id);
    });

    try {
      await provider.toggleWishlist(course);

      if (!mounted) {
        return;
      }

      _showSnackBar(context.l10n.removedFromWishlist);
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showSnackBar(context.l10n.failedUpdateWishlist);
    } finally {
      if (mounted) {
        setState(() {
          _updatingCourseIds.remove(course.id);
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<WishlistProvider, SettingsProvider>(
      builder:
          (
            BuildContext context,
            WishlistProvider wishlistProvider,
            SettingsProvider settingsProvider,
            Widget? child,
          ) {
            final List<Course> courses = _sortedCourses(wishlistProvider.items);

            return Scaffold(
              backgroundColor: AppTheme.getBackgroundColor(context),
              body: SafeArea(
                bottom: false,
                child: Column(
                  children: <Widget>[
                    _buildPremiumHeader(
                      context,
                      itemCount: wishlistProvider.itemCount,
                    ),
                    if (wishlistProvider.items.isNotEmpty)
                      _buildSortOptions(context),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _buildBody(
                        context,
                        provider: wishlistProvider,
                        settingsProvider: settingsProvider,
                        courses: courses,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
    );
  }

  Widget _buildPremiumHeader(BuildContext context, {required int itemCount}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[AppTheme.black, AppTheme.blackElevated],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppTheme.isDark(context)
              ? AppTheme.borderDark
              : AppTheme.black.withValues(alpha: 0.08),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(
              alpha: AppTheme.isDark(context) ? 0.30 : 0.14,
            ),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              _HeaderAction(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onTap: () => Navigator.of(context).pop(),
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppTheme.gold.withValues(alpha: 0.30),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedFavourite,
                      size: 15,
                      color: AppTheme.goldLight,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      context.l10n.savedForLater,
                      style: const TextStyle(
                        color: AppTheme.goldLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _HeaderAction(
                tooltip: context.l10n.browseCourses,
                onTap: () => Navigator.of(context).pop(),
                accent: true,
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedSearch01,
                  size: 20,
                  color: AppTheme.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      context.l10n.wishlist,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.wishlistCoursesCount(itemCount),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.66),
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 48),
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: itemCount > 0
                      ? AppTheme.goldLight
                      : Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$itemCount',
                  style: TextStyle(
                    color: itemCount > 0
                        ? AppTheme.black
                        : Colors.white.withValues(alpha: 0.65),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortOptions(BuildContext context) {
    final List<_SortItem> options = <_SortItem>[
      _SortItem(
        value: 'recent',
        label: context.l10n.recentlyAdded,
        icon: Icons.schedule_rounded,
      ),
      _SortItem(
        value: 'price_asc',
        label: context.l10n.priceLowToHigh,
        icon: Icons.south_rounded,
      ),
      _SortItem(
        value: 'price_desc',
        label: context.l10n.priceHighToLow,
        icon: Icons.north_rounded,
      ),
      _SortItem(
        value: 'rating',
        label: context.l10n.highestRated,
        icon: Icons.star_outline_rounded,
      ),
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: options.length,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(width: 9),
        itemBuilder: (BuildContext context, int index) {
          final _SortItem item = options[index];

          return _SortChip(
            label: item.label,
            icon: item.icon,
            selected: _sortBy == item.value,
            onTap: () {
              setState(() {
                _sortBy = item.value;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required WishlistProvider provider,
    required SettingsProvider settingsProvider,
    required List<Course> courses,
  }) {
    if (provider.isLoading && provider.items.isEmpty) {
      return const _WishlistLoadingState();
    }

    if (courses.isEmpty) {
      return _WishlistEmptyState(
        onBrowseCourses: () => Navigator.of(context).pop(),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.loadWishlist,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 44),
        itemCount: courses.length,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(height: 14),
        itemBuilder: (BuildContext context, int index) {
          final Course course = courses[index];

          return _WishlistCourseCard(
            course: course,
            settingsProvider: settingsProvider,
            isUpdating: _updatingCourseIds.contains(course.id),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) =>
                      CourseDetailScreen(courseId: course.id),
                ),
              );
            },
            onRemove: () =>
                _removeFromWishlist(course: course, provider: provider),
          );
        },
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.tooltip,
    required this.child,
    required this.onTap,
    this.accent = false,
  });

  final String tooltip;
  final Widget child;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: accent
            ? AppTheme.goldLight
            : Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: SizedBox(width: 46, height: 46, child: Center(child: child)),
        ),
      ),
    );
  }
}

class _SortItem {
  const _SortItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isDark = AppTheme.isDark(context);
    final Color selectedColor = isDark ? AppTheme.goldLight : AppTheme.black;
    final Color selectedTextColor = isDark ? AppTheme.black : Colors.white;

    return Material(
      color: selected ? selectedColor : AppTheme.getCardColor(context),
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selected
                  ? selectedColor
                  : AppTheme.getBorderColor(context),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: 16,
                color: selected
                    ? selectedTextColor
                    : AppTheme.getSecondaryTextColor(context),
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? selectedTextColor
                      : AppTheme.getTextColor(context),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WishlistCourseCard extends StatelessWidget {
  const _WishlistCourseCard({
    required this.course,
    required this.settingsProvider,
    required this.isUpdating,
    required this.onTap,
    required this.onRemove,
  });

  final Course course;
  final SettingsProvider settingsProvider;
  final bool isUpdating;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final String? thumbnail = course.thumbnail?.trim();

    final String instructorName =
        (course.instructor?.name ?? course.instructorName ?? '').trim();

    final double regularPrice = course.price ?? 0;
    final double? discountedPrice = course.discountedPrice;

    final bool hasDiscount =
        discountedPrice != null && discountedPrice < regularPrice;

    final double currentPrice = hasDiscount ? discountedPrice : regularPrice;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.getBorderColor(context)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: AppTheme.isDark(context) ? 0.16 : 0.05,
                ),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 112,
                      height: 122,
                      color: AppTheme.getSoftGray150(context),
                      child: thumbnail != null && thumbnail.isNotEmpty
                          ? Image.network(
                              AppConfig.getImageUrl(thumbnail),
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (
                                    BuildContext context,
                                    Object error,
                                    StackTrace? stackTrace,
                                  ) {
                                    return const _CourseImageFallback();
                                  },
                            )
                          : const _CourseImageFallback(),
                    ),
                  ),
                  if (course.isLiveCourse)
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.danger,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          context.l10n.liveClassLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 122,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              course.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppTheme.getTextColor(context),
                                fontSize: 15,
                                height: 1.28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Tooltip(
                            message: context.l10n.removeFromWishlist,
                            child: Material(
                              color: AppTheme.danger.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(13),
                              child: InkWell(
                                onTap: isUpdating ? null : onRemove,
                                borderRadius: BorderRadius.circular(13),
                                child: SizedBox(
                                  width: 38,
                                  height: 38,
                                  child: Center(
                                    child: isUpdating
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.favorite_rounded,
                                            size: 20,
                                            color: AppTheme.danger,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(
                        instructorName.isNotEmpty
                            ? instructorName
                            : context.l10n.instructor,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.getSecondaryTextColor(context),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.star_rounded,
                            color: AppTheme.warning,
                            size: 17,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            (course.rating ?? 0).toStringAsFixed(1),
                            style: TextStyle(
                              color: AppTheme.getTextColor(context),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${course.reviewsCount})',
                            style: TextStyle(
                              color: AppTheme.getSecondaryTextColor(context),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.play_lesson_outlined,
                            size: 15,
                            color: AppTheme.getSecondaryTextColor(context),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              context.l10n.wishlistLessonsCount(
                                course.lessonsCount,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppTheme.getSecondaryTextColor(context),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            currentPrice <= 0
                                ? context.l10n.freeCourse
                                : settingsProvider.formatPrice(currentPrice),
                            style: TextStyle(
                              color: AppTheme.getPrimaryColor(context),
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (hasDiscount) ...<Widget>[
                            const SizedBox(width: 7),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                settingsProvider.formatPrice(regularPrice),
                                style: TextStyle(
                                  color: AppTheme.getSecondaryTextColor(
                                    context,
                                  ),
                                  fontSize: 11,
                                  decoration: TextDecoration.lineThrough,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: AppTheme.getAccentColor(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseImageFallback extends StatelessWidget {
  const _CourseImageFallback();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: HugeIcon(
        icon: HugeIcons.strokeRoundedBookOpen01,
        size: 34,
        color: AppTheme.getSecondaryTextColor(context),
      ),
    );
  }
}

class _WishlistLoadingState extends StatelessWidget {
  const _WishlistLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      itemCount: 4,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 14),
      itemBuilder: (BuildContext context, int index) {
        return Container(
          height: 148,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.getBorderColor(context)),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 112,
                height: 122,
                decoration: BoxDecoration(
                  color: AppTheme.getSoftGray150(context),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppTheme.getSoftGray150(context),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 130,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppTheme.getSoftGray150(context),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 90,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppTheme.getSoftGray150(context),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WishlistEmptyState extends StatelessWidget {
  const _WishlistEmptyState({required this.onBrowseCourses});

  final VoidCallback onBrowseCourses;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: context.read<WishlistProvider>().loadWishlist,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.58,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 30, 30, 60),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: AppTheme.getMint100(context),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.getAccentColor(
                            context,
                          ).withValues(alpha: 0.24),
                        ),
                      ),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedFavourite,
                        size: 42,
                        color: AppTheme.getAccentColor(context),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      context.l10n.emptyWishlistTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 20,
                        height: 1.25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      context.l10n.emptyWishlistSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.getSecondaryTextColor(context),
                        fontSize: 13,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: onBrowseCourses,
                      icon: const Icon(Icons.explore_outlined),
                      label: Text(context.l10n.browseCourses),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.getPrimaryColor(context),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
