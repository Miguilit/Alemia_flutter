import 'dart:convert';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/bundle.dart';
import '../../services/course_service.dart';
import '../../providers/settings_provider.dart';
import 'package:provider/provider.dart';

class BundleCheckoutScreen extends StatefulWidget {
  final Bundle bundle;
  const BundleCheckoutScreen({super.key, required this.bundle});

  @override
  State<BundleCheckoutScreen> createState() => _BundleCheckoutScreenState();
}

class _BundleCheckoutScreenState extends State<BundleCheckoutScreen> {
  bool _isProcessing = false;

  void _enrollOffline() async {
    setState(() {
      _isProcessing = true;
    });
    try {
      final courseService = CourseService();
      final response = await courseService.enrollBundle(
        widget.bundle.id,
        'offline',
        transactionId: 'TEST-TX-${DateTime.now().millisecondsSinceEpoch}',
      );

      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      final nav = Navigator.of(context);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (data['is_duplicate_warning'] == true) {
          bool? proceed = await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(ctx.l10n.checkoutDuplicateCoursesTitle),
              content: Text(data['message']),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(ctx.l10n.checkoutCancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(ctx.l10n.checkoutProceedAnyway),
                ),
              ],
            ),
          );
          if (!mounted) return;
          if (proceed == true) {
            final confirmResponse = await courseService.enrollBundle(
              widget.bundle.id,
              'offline',
              transactionId: 'TEST-TX-${DateTime.now().millisecondsSinceEpoch}',
              confirmDuplicate: true,
            );

            if (!mounted) return;
            final finalData = jsonDecode(confirmResponse.body);
            if (confirmResponse.statusCode == 200) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    finalData['message'] ?? context.l10n.checkoutEnrolled,
                  ),
                ),
              );
              nav.pop();
            } else {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    finalData['message'] ?? context.l10n.checkoutFailed,
                  ),
                ),
              );
            }
          }
        } else {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                data['message'] ?? context.l10n.checkoutEnrollmentRequested,
              ),
            ),
          );
          nav.pop();
        }
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? context.l10n.checkoutFailed),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.checkoutError('$e'))));
    } finally {
      if (mounted)
        setState(() {
          _isProcessing = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.checkoutBundleTitle)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(context.l10n.checkoutForBundle(widget.bundle.title)),
            const SizedBox(height: 20),
            Text(
              context.l10n.checkoutTotalAmount(
                Provider.of<SettingsProvider>(
                  context,
                  listen: false,
                ).formatPrice(widget.bundle.price),
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            _isProcessing
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _enrollOffline,
                    child: Text(context.l10n.checkoutPayOffline),
                  ),
          ],
        ),
      ),
    );
  }
}
