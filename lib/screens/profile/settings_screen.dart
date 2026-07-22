import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/custom_page_service.dart';
import '../../models/custom_page.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'privacy_terms_screen.dart';
import 'rate_app_sheet.dart';
import 'share_app_sheet.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/profile_service.dart';
import '../../config/config.dart';
import '../common/webview_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final CustomPageService _customPageService = CustomPageService();
  List<CustomPage> _customPages = [];
  bool _isLoadingPages = true;

  @override
  void initState() {
    super.initState();
    _loadCustomPages();
  }

  Future<void> _loadCustomPages() async {
    try {
      final pages = await _customPageService.getPages();
      if (mounted) {
        setState(() {
          _customPages = pages;
          _isLoadingPages = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPages = false;
        });
      }
      debugPrint('Error loading pages: $e');
    }
  }

  String _localizedCustomPageTitle(BuildContext context, CustomPage page) {
    final String slug = page.slug.trim().toLowerCase().replaceAll('_', '-');

    final String title = page.title.trim().toLowerCase();

    if (slug.contains('privacy') || title.contains('privacy')) {
      return context.l10n.profilePrivacyPolicyTitle;
    }

    if (slug.contains('terms') ||
        title.contains('terms') ||
        title.contains('conditions')) {
      return context.l10n.profileTermsConditionsTitle;
    }

    if (slug.contains('gdpr') ||
        title.contains('gdpr') ||
        title.contains('rgpd')) {
      return context.l10n.profileGdprComplianceTitle;
    }

    return page.title;
  }

  Future<void> _showDeleteAccountDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.profileDeleteAccountTitle),
        content: Text(context.l10n.profileDeleteAccountConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              context.l10n.profileCancel,
              style: TextStyle(color: AppTheme.getTextColor(context)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              context.l10n.profileDelete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        await ProfileService().submitDeleteRequest();
        if (mounted) {
          Navigator.pop(context); // Close loading
          // Refresh status
          await Provider.of<AuthProvider>(
            context,
            listen: false,
          ).checkDeletionRequestStatus();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.l10n.profileDeletionRequestSubmitted,
                  style: TextStyle(color: AppTheme.getTextColor(context)),
                ),
                backgroundColor: AppTheme.getCardColor(context),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.profileErrorWithDetails(e))),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Header with back button
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
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
                        context.l10n.settings,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.getTextColor(context),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              // Account Settings Section
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  context.l10n.profileAccountSection,
                  style: TextStyle(
                    color: AppTheme.getTextColor(
                      context,
                    ).withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.getCardColor(context),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: <Widget>[
                    _MenuItemWithCustomIcon(
                      icon: Icons.person_outline,
                      title: context.l10n.profileEditTitle,
                      subtitle: context.l10n.profileEditSubtitle,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                      },
                    ),
                    _MenuItemWithCustomIcon(
                      icon: Icons.lock_outline,
                      title: context.l10n.profileChangePasswordTitle,
                      subtitle: context.l10n.profileChangePasswordSubtitle,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ChangePasswordScreen(),
                          ),
                        );
                      },
                    ),
                    Builder(
                      builder: (context) {
                        final deletionStatus = Provider.of<AuthProvider>(
                          context,
                        ).deletionRequestStatus;
                        final isPending =
                            deletionStatus != null &&
                            deletionStatus['status'] == 'pending';

                        return _MenuItemWithCustomIcon(
                          icon: isPending
                              ? Icons.access_time_rounded
                              : Icons.delete_outline,
                          title: isPending
                              ? context.l10n.profileDeletionPendingTitle
                              : context.l10n.profileDeleteAccountTitle,
                          subtitle: isPending
                              ? context.l10n.profileAwaitingAdminApproval
                              : context.l10n.profileDeleteAccountSubtitle,
                          isDestructive: !isPending,
                          onTap: isPending
                              ? () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        context
                                            .l10n
                                            .profileDeletionPendingMessage,
                                      ),
                                    ),
                                  );
                                }
                              : () => _showDeleteAccountDialog(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Privacy & Security Section
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  context.l10n.profilePrivacySecuritySection,
                  style: TextStyle(
                    color: AppTheme.getTextColor(
                      context,
                    ).withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.getCardColor(context),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: <Widget>[
                    if (_isLoadingPages)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_customPages.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          context.l10n.profileNoPagesAvailable,
                          style: TextStyle(
                            color: AppTheme.getTextColor(
                              context,
                            ).withValues(alpha: 0.6),
                          ),
                        ),
                      )
                    else
                      ..._customPages.map((page) {
                        final String localizedTitle = _localizedCustomPageTitle(
                          context,
                          page,
                        );

                        return _MenuItem(
                          icon: HugeIcons.strokeRoundedFile01,
                          title: localizedTitle,
                          subtitle: context.l10n.profileViewPage(
                            localizedTitle,
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PrivacyTermsScreen(
                                  title: localizedTitle,
                                  slug: page.slug,
                                ),
                              ),
                            );
                          },
                        );
                      }),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Support & Info Section
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  context.l10n.supportInfo,
                  style: TextStyle(
                    color: AppTheme.getTextColor(
                      context,
                    ).withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.getCardColor(context),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: <Widget>[
                    _MenuItemWithCustomIcon(
                      icon: Icons.info_outline,
                      title: context.l10n.about,
                      subtitle: context.l10n.aboutSubtitle,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => WebViewScreen(
                              url: '${AppConfig.baseUrl}/about',
                              title: context.l10n.about,
                            ),
                          ),
                        );
                      },
                    ),
                    _MenuItemWithCustomIcon(
                      icon: Icons.help_outline,
                      title: context.l10n.helpSupport,
                      subtitle: context.l10n.helpSupportSubtitle,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => WebViewScreen(
                              url: '${AppConfig.baseUrl}/contact',
                              title: context.l10n.helpSupport,
                            ),
                          ),
                        );
                      },
                    ),
                    _MenuItem(
                      icon: HugeIcons.strokeRoundedStar,
                      title: context.l10n.profileRateAppTitle,
                      subtitle: context.l10n.profileRateAppSubtitle,
                      onTap: () {
                        showRateAppSheet(context);
                      },
                    ),
                    _MenuItem(
                      icon: HugeIcons.strokeRoundedShare01,
                      title: context.l10n.profileShareAppTitle,
                      subtitle: context.l10n.profileShareAppSubtitle,
                      onTap: () {
                        showShareAppSheet(context);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final dynamic icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.getMint100(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: HugeIcon(
                  icon: icon,
                  size: 20,
                  color: AppTheme.getTextColor(context),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppTheme.getTextColor(
                        context,
                      ).withValues(alpha: 0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              size: 20,
              color: AppTheme.getTextColor(context).withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItemWithCustomIcon extends StatelessWidget {
  const _MenuItemWithCustomIcon({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.getMint100(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 20,
                  color: isDestructive
                      ? Colors.red
                      : AppTheme.getTextColor(context),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      color: isDestructive
                          ? Colors.red
                          : AppTheme.getTextColor(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppTheme.getTextColor(
                        context,
                      ).withValues(alpha: 0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              size: 20,
              color: AppTheme.getTextColor(context).withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}
