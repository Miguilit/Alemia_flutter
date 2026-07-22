import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../config/config.dart';
import '../../l10n/app_localizations.dart';
import '../../models/notification.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/image_modal.dart';
import '../common/webview_screen.dart';
import '../course_detail/course_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  final ScrollController _scrollController = ScrollController();

  List<NotificationModel> _notifications = <NotificationModel>[];

  bool _isLoading = false;
  bool _isInitialLoading = true;
  bool _hasLoadError = false;
  bool _showUnreadOnly = false;
  bool _isMarkingAllRead = false;

  int _currentPage = 1;
  int _lastPage = 1;
  bool _hasMore = true;

  int get _unreadCount => _notifications
      .where((NotificationModel notification) => !notification.isRead)
      .length;

  List<NotificationModel> get _visibleNotifications {
    if (!_showUnreadOnly) {
      return _notifications;
    }

    return _notifications
        .where((NotificationModel notification) => !notification.isRead)
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients ||
        _showUnreadOnly ||
        _isLoading ||
        !_hasMore) {
      return;
    }

    final ScrollPosition position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 220) {
      _loadNotifications(loadMore: true);
    }
  }

  Future<void> _loadNotifications({bool loadMore = false}) async {
    if (_isLoading) {
      return;
    }

    if (!loadMore) {
      setState(() {
        _isInitialLoading = true;
        _hasLoadError = false;
        _currentPage = 1;
        _lastPage = 1;
        _hasMore = true;
      });
    }

    setState(() => _isLoading = true);

    try {
      final response = await _notificationService.fetchNotifications(
        page: loadMore ? _currentPage : 1,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        if (loadMore) {
          _notifications.addAll(response.notifications);
        } else {
          _notifications = response.notifications;
        }

        _lastPage = response.lastPage;
        _currentPage = (loadMore ? _currentPage : 1) + 1;
        _hasMore = _currentPage <= _lastPage;
        _isLoading = false;
        _isInitialLoading = false;
        _hasLoadError = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _isInitialLoading = false;
        _hasLoadError = !loadMore;
      });

      if (loadMore) {
        _showSnackBar(context.l10n.failedLoadMoreNotifications);
      }
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead) {
      return;
    }

    try {
      await _notificationService.markAsRead(notification.id);

      if (!mounted) {
        return;
      }

      setState(() {
        final int index = _notifications.indexWhere(
          (NotificationModel item) => item.id == notification.id,
        );

        if (index != -1) {
          _notifications[index] = _copyNotification(
            _notifications[index],
            readAt: DateTime.now(),
          );
        }
      });
    } catch (_) {
      if (mounted) {
        _showSnackBar(context.l10n.notificationActionFailed);
      }
    }
  }

  Future<void> _markAllAsRead() async {
    if (_unreadCount == 0 || _isMarkingAllRead) {
      return;
    }

    setState(() => _isMarkingAllRead = true);

    try {
      await _notificationService.markAllRead();

      if (!mounted) {
        return;
      }

      setState(() {
        _notifications = _notifications
            .map(
              (NotificationModel notification) =>
                  _copyNotification(notification, readAt: DateTime.now()),
            )
            .toList(growable: false);

        _isMarkingAllRead = false;
      });

      _showSnackBar(context.l10n.allNotificationsMarkedRead);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() => _isMarkingAllRead = false);
      _showSnackBar(context.l10n.notificationActionFailed);
    }
  }

  Future<bool> _requestDeleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      return true;
    } catch (_) {
      if (mounted) {
        _showSnackBar(context.l10n.notificationActionFailed);
      }
      return false;
    }
  }

  void _removeDeletedNotification(String notificationId) {
    setState(() {
      _notifications.removeWhere(
        (NotificationModel notification) => notification.id == notificationId,
      );
    });

    _showSnackBar(context.l10n.notificationDeleted);
  }

  NotificationModel _copyNotification(
    NotificationModel source, {
    required DateTime readAt,
  }) {
    return NotificationModel(
      id: source.id,
      title: source.title,
      message: source.message,
      type: source.type,
      image: source.image,
      url: source.url,
      readAt: readAt,
      createdAt: source.createdAt,
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleNotificationTap(NotificationModel notification) async {
    await _markAsRead(notification);

    if (!mounted) {
      return;
    }

    switch (notification.type) {
      case 'image':
        final String? rawImage = notification.image;
        if (rawImage == null || rawImage.isEmpty) {
          return;
        }

        showDialog<void>(
          context: context,
          builder: (BuildContext dialogContext) {
            return ImageModal(
              imageUrl: rawImage.startsWith('http')
                  ? rawImage
                  : '${AppConfig.baseUrl}/storage/$rawImage',
              title: notification.title,
            );
          },
        );
        break;

      case 'url':
        final String? url = notification.url;
        if (url == null || url.isEmpty) {
          return;
        }

        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                WebViewScreen(url: url, title: notification.title),
          ),
        );
        break;

      case 'course':
        final Uri? uri = Uri.tryParse(notification.url ?? '');
        final String? rawId = uri?.pathSegments.isNotEmpty == true
            ? uri!.pathSegments.last
            : null;
        final int? courseId = int.tryParse(rawId ?? '');

        if (courseId == null) {
          return;
        }

        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                CourseDetailScreen(courseId: courseId),
          ),
        );
        break;

      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<NotificationModel> visible = _visibleNotifications;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            _buildPremiumHeader(context),
            _buildFilters(context),
            const SizedBox(height: 8),
            Expanded(child: _buildBody(context, visibleNotifications: visible)),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(BuildContext context) {
    final int unreadCount = _unreadCount;
    final String subtitle = unreadCount > 0
        ? context.l10n.unreadNotificationsCount(unreadCount)
        : context.l10n.allNotificationsRead;

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
                      icon: HugeIcons.strokeRoundedNotification01,
                      size: 15,
                      color: AppTheme.goldLight,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      context.l10n.notificationCenter,
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
                tooltip: context.l10n.markAllAsRead,
                onTap: unreadCount > 0 && !_isMarkingAllRead
                    ? _markAllAsRead
                    : null,
                accent: unreadCount > 0,
                child: _isMarkingAllRead
                    ? SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: unreadCount > 0
                              ? AppTheme.black
                              : Colors.white,
                        ),
                      )
                    : Icon(
                        Icons.done_all_rounded,
                        size: 20,
                        color: unreadCount > 0
                            ? AppTheme.black
                            : Colors.white.withValues(alpha: 0.38),
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
                      context.l10n.notifications,
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
                      subtitle,
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
                  color: unreadCount > 0
                      ? AppTheme.goldLight
                      : Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$unreadCount',
                  style: TextStyle(
                    color: unreadCount > 0
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

  Widget _buildFilters(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.getBorderColor(context)),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _FilterButton(
                label: context.l10n.allNotifications,
                count: _notifications.length,
                selected: !_showUnreadOnly,
                onTap: () {
                  setState(() => _showUnreadOnly = false);
                },
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _FilterButton(
                label: context.l10n.unreadNotifications,
                count: _unreadCount,
                selected: _showUnreadOnly,
                onTap: () {
                  setState(() => _showUnreadOnly = true);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required List<NotificationModel> visibleNotifications,
  }) {
    if (_isInitialLoading) {
      return const _NotificationLoadingState();
    }

    if (_hasLoadError && _notifications.isEmpty) {
      return _NotificationStateList(
        icon: Icons.cloud_off_rounded,
        title: context.l10n.failedLoadNotifications,
        subtitle: context.l10n.notificationsLoadErrorSubtitle,
        actionLabel: context.l10n.retry,
        onAction: () => _loadNotifications(),
      );
    }

    if (visibleNotifications.isEmpty) {
      final bool hasNotifications = _notifications.isNotEmpty;

      return _NotificationStateList(
        icon: hasNotifications
            ? Icons.mark_email_read_outlined
            : Icons.notifications_none_rounded,
        title: hasNotifications
            ? context.l10n.noUnreadNotificationsTitle
            : context.l10n.noNotificationsTitle,
        subtitle: hasNotifications
            ? context.l10n.noUnreadNotificationsSubtitle
            : context.l10n.noNotificationsSubtitle,
        actionLabel: hasNotifications
            ? context.l10n.showAllNotifications
            : null,
        onAction: hasNotifications
            ? () {
                setState(() => _showUnreadOnly = false);
              }
            : null,
        onRefresh: () => _loadNotifications(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadNotifications(),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 44),
        itemCount:
            visibleNotifications.length +
            (_hasMore && !_showUnreadOnly ? 1 : 0),
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(height: 12),
        itemBuilder: (BuildContext context, int index) {
          if (index == visibleNotifications.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final NotificationModel notification = visibleNotifications[index];

          return _NotificationCard(
            notification: notification,
            onTap: () => _handleNotificationTap(notification),
            confirmDelete: () => _requestDeleteNotification(notification.id),
            onDeleted: () => _removeDeletedNotification(notification.id),
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
  final VoidCallback? onTap;
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

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isDark = AppTheme.isDark(context);
    final Color selectedColor = isDark ? AppTheme.goldLight : AppTheme.black;
    final Color selectedTextColor = isDark ? AppTheme.black : Colors.white;

    return Material(
      color: selected ? selectedColor : Colors.transparent,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected
                        ? selectedTextColor
                        : AppTheme.getSecondaryTextColor(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Container(
                constraints: const BoxConstraints(minWidth: 22),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: selected
                      ? selectedTextColor.withValues(alpha: 0.16)
                      : AppTheme.getMint100(context),
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: selected
                        ? selectedTextColor
                        : AppTheme.getTextColor(context),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
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

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.confirmDelete,
    required this.onDeleted,
  });

  final NotificationModel notification;
  final VoidCallback onTap;
  final Future<bool> Function() confirmDelete;
  final VoidCallback onDeleted;

  IconData get _icon {
    switch (notification.type) {
      case 'course':
        return Icons.school_outlined;
      case 'image':
        return Icons.image_outlined;
      case 'url':
        return Icons.link_rounded;
      case 'author':
        return Icons.person_outline_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color _iconColor(BuildContext context) {
    switch (notification.type) {
      case 'course':
        return AppTheme.getAccentColor(context);
      case 'image':
        return AppTheme.info;
      case 'url':
        return AppTheme.success;
      case 'author':
        return AppTheme.warning;
      default:
        return AppTheme.getSecondaryTextColor(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isUnread = !notification.isRead;
    final Color iconColor = _iconColor(context);

    return Dismissible(
      key: ValueKey<String>(notification.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (DismissDirection direction) => confirmDelete(),
      onDismissed: (DismissDirection direction) => onDeleted(),
      background: Container(
        decoration: BoxDecoration(
          color: AppTheme.danger,
          borderRadius: BorderRadius.circular(22),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.deleteNotification,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Ink(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isUnread
                  ? AppTheme.getMint100(context)
                  : AppTheme.getCardColor(context),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isUnread
                    ? AppTheme.getAccentColor(context).withValues(alpha: 0.52)
                    : AppTheme.getBorderColor(context),
                width: isUnread ? 1.2 : 0.8,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: AppTheme.isDark(context) ? 0.16 : 0.05,
                  ),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: iconColor.withValues(alpha: 0.20),
                    ),
                  ),
                  child: Icon(_icon, size: 23, color: iconColor),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              notification.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppTheme.getTextColor(context),
                                fontSize: 15,
                                height: 1.25,
                                fontWeight: isUnread
                                    ? FontWeight.w800
                                    : FontWeight.w700,
                              ),
                            ),
                          ),
                          if (isUnread) ...<Widget>[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.getPrimaryColor(context),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                context.l10n.newNotification,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(
                        notification.message,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.getSecondaryTextColor(context),
                          fontSize: 12.5,
                          height: 1.42,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: AppTheme.getSecondaryTextColor(context),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              _formatNotificationDate(
                                context,
                                notification.createdAt,
                              ),
                              style: TextStyle(
                                color: AppTheme.getSecondaryTextColor(context),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 19,
                            color: AppTheme.getSecondaryTextColor(
                              context,
                            ).withValues(alpha: 0.58),
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
    );
  }

  String _formatNotificationDate(BuildContext context, DateTime rawDate) {
    final DateTime date = rawDate.toLocal();
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime notificationDay = DateTime(date.year, date.month, date.day);
    final int difference = today.difference(notificationDay).inDays;
    final MaterialLocalizations material = MaterialLocalizations.of(context);
    final String time = material.formatTimeOfDay(
      TimeOfDay.fromDateTime(date),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );

    if (difference == 0) {
      return '${context.l10n.today} · $time';
    }

    if (difference == 1) {
      return '${context.l10n.yesterday} · $time';
    }

    return '${material.formatMediumDate(date)} · $time';
  }
}

class _NotificationLoadingState extends StatelessWidget {
  const _NotificationLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      itemCount: 5,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 12),
      itemBuilder: (BuildContext context, int index) {
        return Container(
          height: 112,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppTheme.getBorderColor(context)),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.getSoftGray150(context),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 150,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppTheme.getSoftGray150(context),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 11),
                    Container(
                      width: double.infinity,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppTheme.getSoftGray150(context),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 110,
                      height: 9,
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

class _NotificationStateList extends StatelessWidget {
  const _NotificationStateList({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.onRefresh,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final Widget state = Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 44, 30, 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 94,
              height: 94,
              decoration: BoxDecoration(
                color: AppTheme.getMint100(context),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.getAccentColor(
                    context,
                  ).withValues(alpha: 0.22),
                ),
              ),
              child: Icon(
                icon,
                size: 41,
                color: AppTheme.getAccentColor(context),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.getTextColor(context),
                fontSize: 19,
                height: 1.25,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.getSecondaryTextColor(context),
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.visibility_outlined),
                label: Text(actionLabel!),
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
          ],
        ),
      ),
    );

    final Widget list = ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: <Widget>[
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.58,
          child: state,
        ),
      ],
    );

    if (onRefresh == null) {
      return list;
    }

    return RefreshIndicator(onRefresh: onRefresh!, child: list);
  }
}
