import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

import '../../config/config.dart';
import '../../l10n/app_localizations.dart';
import '../../models/conversation.dart';
import '../../providers/chat_provider.dart';
import '../../router/app_router.dart';
import '../../theme/app_theme.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(_handleTabChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ChatProvider provider = context.read<ChatProvider>();
      provider.fetchConversations();
      provider.fetchRequests();
    });
  }

  void _handleTabChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_handleTabChange)
      ..dispose();
    super.dispose();
  }

  Future<void> _refreshTab({
    required ChatProvider provider,
    required bool isInbox,
  }) async {
    if (isInbox) {
      await provider.fetchConversations();
    } else {
      await provider.fetchRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (BuildContext context, ChatProvider provider, Widget? child) {
        final int unreadCount = provider.conversations.fold<int>(
          0,
          (int total, Conversation conversation) =>
              total + conversation.unreadCount,
        );

        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: <Widget>[
                _buildPremiumHeader(context, unreadCount: unreadCount),
                _buildSegmentedTabs(
                  context,
                  inboxCount: unreadCount,
                  requestCount: provider.requests.length,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: <Widget>[
                      _buildConversationList(provider: provider, isInbox: true),
                      _buildConversationList(
                        provider: provider,
                        isInbox: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumHeader(BuildContext context, {required int unreadCount}) {
    final bool isDark = AppTheme.isDark(context);
    final String subtitle = unreadCount > 0
        ? context.l10n.unreadMessagesCount(unreadCount)
        : context.l10n.allCaughtUp;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[AppTheme.black, AppTheme.blackElevated],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark
                ? AppTheme.borderDark
                : AppTheme.black.withValues(alpha: 0.08),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.14),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                _HeaderActionButton(
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  onTap: () => Navigator.of(context).pop(),
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
                      const Icon(
                        Icons.lock_outline_rounded,
                        size: 14,
                        color: AppTheme.goldLight,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        context.l10n.privateConversations,
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
                _HeaderActionButton(
                  tooltip: context.l10n.newMessage,
                  icon: HugeIcons.strokeRoundedEdit02,
                  accent: true,
                  onTap: _showNewMessageSheet,
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
                        context.l10n.messages,
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
                if (unreadCount > 0)
                  Container(
                    constraints: const BoxConstraints(minWidth: 46),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.goldLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        color: AppTheme.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedTabs(
    BuildContext context, {
    required int inboxCount,
    required int requestCount,
  }) {
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
              child: _SegmentButton(
                label: context.l10n.inbox,
                count: inboxCount,
                selected: _tabController.index == 0,
                onTap: () => _tabController.animateTo(0),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _SegmentButton(
                label: context.l10n.sentRequests,
                count: requestCount,
                selected: _tabController.index == 1,
                onTap: () => _tabController.animateTo(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationList({
    required ChatProvider provider,
    required bool isInbox,
  }) {
    final List<Conversation> conversations = isInbox
        ? provider.conversations
        : provider.requests;

    if (provider.isLoading && conversations.isEmpty) {
      return const _ConversationLoadingState();
    }

    if (provider.error != null && conversations.isEmpty) {
      return _ConversationStateList(
        icon: Icons.cloud_off_rounded,
        title: context.l10n.failedLoadConversations,
        subtitle: context.l10n.checkConnectionAndRetry,
        actionLabel: context.l10n.retry,
        onAction: () => _refreshTab(provider: provider, isInbox: isInbox),
      );
    }

    if (conversations.isEmpty) {
      return _ConversationStateList(
        icon: isInbox ? Icons.forum_outlined : Icons.outgoing_mail,
        title: isInbox
            ? context.l10n.noConversationsTitle
            : context.l10n.noPendingRequestsTitle,
        subtitle: isInbox
            ? context.l10n.noConversationsSubtitle
            : context.l10n.noPendingRequestsSubtitle,
        actionLabel: isInbox ? context.l10n.newMessage : null,
        onAction: isInbox ? _showNewMessageSheet : null,
        onRefresh: () => _refreshTab(provider: provider, isInbox: isInbox),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _refreshTab(provider: provider, isInbox: isInbox),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        itemCount: conversations.length,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(height: 12),
        itemBuilder: (BuildContext context, int index) {
          final Conversation conversation = conversations[index];

          return _ConversationCard(
            conversation: conversation,
            isInbox: isInbox,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRouter.chatScreen,
                arguments: <String, dynamic>{'conversationId': conversation.id},
              );
            },
          );
        },
      ),
    );
  }

  void _showNewMessageSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: _NewMessageSheet(
            onConversationStarted: (int conversationId) {
              Navigator.pop(sheetContext);
              Navigator.pushNamed(
                context,
                AppRouter.chatScreen,
                arguments: <String, dynamic>{'conversationId': conversationId},
              );
            },
          ),
        );
      },
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.accent = false,
  });

  final String tooltip;
  final List<List<dynamic>> icon;
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
          child: SizedBox(
            width: 46,
            height: 46,
            child: Center(
              child: HugeIcon(
                icon: icon,
                size: 21,
                color: accent ? AppTheme.black : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
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
    final Color activeColor = isDark ? AppTheme.goldLight : AppTheme.black;
    final Color activeTextColor = isDark ? AppTheme.black : Colors.white;

    return Material(
      color: selected ? activeColor : Colors.transparent,
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
                        ? activeTextColor
                        : AppTheme.getSecondaryTextColor(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (count > 0) ...<Widget>[
                const SizedBox(width: 7),
                Container(
                  constraints: const BoxConstraints(minWidth: 22),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? activeTextColor.withValues(alpha: 0.16)
                        : AppTheme.getMint100(context),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: selected
                          ? activeTextColor
                          : AppTheme.getTextColor(context),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ConversationCard extends StatelessWidget {
  const _ConversationCard({
    required this.conversation,
    required this.isInbox,
    required this.onTap,
  });

  final Conversation conversation;
  final bool isInbox;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ChatUser? instructor = conversation.instructor;
    final bool hasUnread = conversation.unreadCount > 0;

    final String normalizedInstructorName =
        instructor?.name.trim() ?? '';

    final String instructorName =
        normalizedInstructorName.isNotEmpty
            ? normalizedInstructorName
            : context.l10n.instructor;

    final String normalizedLastMessage =
        conversation.latestMessage?.body?.trim() ?? '';

    final String preview = normalizedLastMessage.isNotEmpty
        ? normalizedLastMessage
        : isInbox
            ? context.l10n.startConversation
            : context.l10n.awaitingResponse;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: hasUnread
                ? AppTheme.getMint100(context)
                : AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: hasUnread
                  ? AppTheme.getAccentColor(context).withValues(alpha: 0.55)
                  : AppTheme.getBorderColor(context),
              width: hasUnread ? 1.2 : 0.8,
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
            children: <Widget>[
              _InstructorAvatar(
                instructor: instructor,
                name: instructorName,
                highlighted: hasUnread,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            instructorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppTheme.getTextColor(context),
                              fontSize: 15,
                              fontWeight: hasUnread
                                  ? FontWeight.w800
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                        if (conversation.lastMessageAt != null)
                          Text(
                            _formatConversationDate(
                              context,
                              conversation.lastMessageAt!,
                            ),
                            style: TextStyle(
                              color: AppTheme.getSecondaryTextColor(context),
                              fontSize: 10.5,
                              fontWeight: hasUnread
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppTheme.getSecondaryTextColor(context),
                              fontSize: 12.5,
                              height: 1.3,
                              fontWeight: hasUnread
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (hasUnread)
                          _UnreadBadge(count: conversation.unreadCount)
                        else if (!isInbox)
                          _StatusBadge(label: context.l10n.pending)
                        else
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: AppTheme.getSecondaryTextColor(
                              context,
                            ).withValues(alpha: 0.55),
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
    );
  }

  String _formatConversationDate(BuildContext context, String rawDate) {
    try {
      final DateTime date = DateTime.parse(rawDate).toLocal();
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      final DateTime messageDay = DateTime(date.year, date.month, date.day);
      final int dayDifference = today.difference(messageDay).inDays;
      final MaterialLocalizations material = MaterialLocalizations.of(context);

      if (dayDifference == 0) {
        return material.formatTimeOfDay(
          TimeOfDay.fromDateTime(date),
          alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
        );
      }

      if (dayDifference == 1) {
        return context.l10n.yesterday;
      }

      if (dayDifference < 7) {
        return material.formatMediumDate(date);
      }

      return material.formatShortDate(date);
    } catch (_) {
      return '';
    }
  }
}

class _InstructorAvatar extends StatelessWidget {
  const _InstructorAvatar({
    required this.instructor,
    required this.name,
    required this.highlighted,
  });

  final ChatUser? instructor;
  final String name;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final String initial = name.trim().isEmpty
        ? '?'
        : name.trim()[0].toUpperCase();

    return Container(
      width: 54,
      height: 54,
      padding: EdgeInsets.all(highlighted ? 2.5 : 1),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: highlighted
              ? AppTheme.getAccentColor(context)
              : AppTheme.getBorderColor(context),
          width: highlighted ? 2 : 1,
        ),
      ),
      child: CircleAvatar(
        backgroundColor: AppTheme.getMint200(context),
        backgroundImage: instructor?.profilePhoto != null
            ? NetworkImage(AppConfig.getImageUrl(instructor!.profilePhoto))
            : null,
        child: instructor?.profilePhoto == null
            ? Text(
                initial,
                style: TextStyle(
                  color: AppTheme.getTextColor(context),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              )
            : null,
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 26),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.getPrimaryColor(context),
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.warning.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.warning.withValues(alpha: 0.26)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.warning,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ConversationLoadingState extends StatelessWidget {
  const _ConversationLoadingState();

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
          height: 88,
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppTheme.getBorderColor(context)),
          ),
          padding: const EdgeInsets.all(15),
          child: Row(
            children: <Widget>[
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppTheme.getSoftGray150(context),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 132,
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

class _ConversationStateList extends StatelessWidget {
  const _ConversationStateList({
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
    final Widget content = Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 44, 28, 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 92,
              height: 92,
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
                size: 40,
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
                icon: const Icon(Icons.add_comment_outlined),
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

    if (onRefresh == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.58,
            child: content,
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh!,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.58,
            child: content,
          ),
        ],
      ),
    );
  }
}

class _NewMessageSheet extends StatefulWidget {
  const _NewMessageSheet({required this.onConversationStarted});

  final ValueChanged<int> onConversationStarted;

  @override
  State<_NewMessageSheet> createState() => _NewMessageSheetState();
}

class _NewMessageSheetState extends State<_NewMessageSheet> {
  final TextEditingController _searchController = TextEditingController();

  List<ChatUser> _results = <ChatUser>[];
  bool _isSearching = false;
  int? _startingInstructorId;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String rawQuery) {
    final String query = rawQuery.trim();

    _debounce?.cancel();

    if (query.length < 2) {
      setState(() {
        _results = <ChatUser>[];
        _isSearching = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (!mounted) {
        return;
      }

      setState(() => _isSearching = true);

      final List<ChatUser> results = await context
          .read<ChatProvider>()
          .searchInstructors(query);

      if (!mounted) {
        return;
      }

      setState(() {
        _results = results;
        _isSearching = false;
      });
    });
  }

  Future<void> _startConversation(ChatUser instructor) async {
    if (_startingInstructorId != null) {
      return;
    }

    setState(() => _startingInstructorId = instructor.id);

    final Conversation? conversation = await context
        .read<ChatProvider>()
        .startConversation(instructor.id);

    if (!mounted) {
      return;
    }

    setState(() => _startingInstructorId = null);

    if (conversation != null) {
      widget.onConversationStarted(conversation.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double sheetHeight = MediaQuery.sizeOf(context).height * 0.76;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border(
          top: BorderSide(color: AppTheme.getBorderColor(context)),
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 46,
            height: 5,
            margin: const EdgeInsets.only(top: 11),
            decoration: BoxDecoration(
              color: AppTheme.getBorderColor(context),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Row(
              children: <Widget>[
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppTheme.getMint100(context),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.edit_note_rounded,
                    color: AppTheme.getAccentColor(context),
                    size: 25,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        context.l10n.newMessage,
                        style: TextStyle(
                          color: AppTheme.getTextColor(context),
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        context.l10n.chooseInstructorToStart,
                        style: TextStyle(
                          color: AppTheme.getSecondaryTextColor(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              style: TextStyle(
                color: AppTheme.getTextColor(context),
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: context.l10n.searchInstructors,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppTheme.getSecondaryTextColor(context),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        tooltip: context.l10n.clear,
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                        icon: const Icon(Icons.close_rounded),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(child: _buildSearchContent(context)),
        ],
      ),
    );
  }

  Widget _buildSearchContent(BuildContext context) {
    if (_isSearching) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const CircularProgressIndicator(),
            const SizedBox(height: 14),
            Text(
              context.l10n.searchingInstructors,
              style: TextStyle(
                color: AppTheme.getSecondaryTextColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (_results.isEmpty) {
      final bool hasEnoughCharacters =
          _searchController.text.trim().length >= 2;

      return _SearchState(
        icon: hasEnoughCharacters
            ? Icons.person_search_outlined
            : Icons.search_rounded,
        title: hasEnoughCharacters
            ? context.l10n.noInstructorsFound
            : context.l10n.searchInstructorTitle,
        subtitle: hasEnoughCharacters
            ? context.l10n.tryAnotherSearch
            : context.l10n.typeToSearchInstructors,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      itemCount: _results.length,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 10),
      itemBuilder: (BuildContext context, int index) {
        final ChatUser instructor = _results[index];
        final bool isStarting = _startingInstructorId == instructor.id;
        final String name = instructor.name.trim();
        final String initial = name.isEmpty ? '?' : name[0].toUpperCase();

        return Material(
          color: AppTheme.getBackgroundColor(context),
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: _startingInstructorId == null
                ? () => _startConversation(instructor)
                : null,
            borderRadius: BorderRadius.circular(18),
            child: Ink(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.getBorderColor(context)),
              ),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.getMint200(context),
                    backgroundImage: instructor.profilePhoto != null
                        ? NetworkImage(
                            AppConfig.getImageUrl(instructor.profilePhoto),
                          )
                        : null,
                    child: instructor.profilePhoto == null
                        ? Text(
                            initial,
                            style: TextStyle(
                              color: AppTheme.getTextColor(context),
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          name.isEmpty ? context.l10n.instructor : name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppTheme.getTextColor(context),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (instructor.specialization?.trim().isNotEmpty ==
                            true) ...<Widget>[
                          const SizedBox(height: 4),
                          Text(
                            instructor.specialization!.trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppTheme.getSecondaryTextColor(context),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (isStarting)
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    )
                  else
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.getMint100(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: AppTheme.getAccentColor(context),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SearchState extends StatelessWidget {
  const _SearchState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 16, 30, 54),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: AppTheme.getMint100(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppTheme.getAccentColor(context),
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.getTextColor(context),
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.getSecondaryTextColor(context),
                fontSize: 12.5,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
