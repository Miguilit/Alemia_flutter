import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/live_class.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class LiveClassBanner extends StatelessWidget {
  final LiveClass liveClass;
  final VoidCallback? onDismiss;
  final EdgeInsetsGeometry? margin;

  const LiveClassBanner({
    super.key,
    required this.liveClass,
    this.onDismiss,
    this.margin,
  });

  Future<void> _joinMeeting(BuildContext context) async {
    final uri = Uri.parse(liveClass.joinUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw StateError('meeting_link_unavailable');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.residualFailedToOpenMeetingLink),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLive = liveClass.status == 'live';
    final String locale = Localizations.localeOf(context).toLanguageTag();
    final String formattedTime = DateFormat.yMMMd(
      locale,
    ).add_jm().format(liveClass.scheduledAt.toLocal());

    return Container(
      margin:
          margin ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: isLive
              ? [const Color(0xFFEF4444), const Color(0xFFB91C1C)]
              : [const Color(0xFF6C5CE7), const Color(0xFF4834DF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isLive ? const Color(0xFFEF4444) : const Color(0xFF6C5CE7))
                .withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isLive) ...[
                            _PulsingDot(),
                            const SizedBox(width: 6),
                            Text(
                              context.l10n.residualLiveNow,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ] else ...[
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedCalendar03,
                              color: Colors.white,
                              size: 13,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              context.l10n.residualUpcomingLive,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      context.l10n.residualMinutesShort(
                        liveClass.durationMinutes,
                      ),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  liveClass.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.l10n.residualScheduledFor(formattedTime),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isLive) ...[
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.residualTapToJoinLive,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: isLive
                              ? const Color(0xFFB91C1C)
                              : const Color(0xFF4834DF),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => _joinMeeting(context),
                        icon: HugeIcon(
                          icon: isLive
                              ? HugeIcons.strokeRoundedPlay
                              : HugeIcons.strokeRoundedVideoReplay,
                          color: isLive
                              ? const Color(0xFFB91C1C)
                              : const Color(0xFF4834DF),
                          size: 18,
                        ),
                        label: Text(
                          isLive
                              ? context.l10n.residualJoinLiveClass
                              : context.l10n.residualMeetingDetailsJoin,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (onDismiss != null)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedCancel01,
                  color: Colors.white70,
                  size: 18,
                ),
                onPressed: onDismiss,
              ),
            ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
