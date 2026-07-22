import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../services/profile_service.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _profileService = ProfileService();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _profileService.updatePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
          // Sending confirm password too as typically required by API validation
          newPasswordConfirmation: _confirmPasswordController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.l10n.profilePasswordUpdated,
                style: TextStyle(color: AppTheme.getTextColor(context)),
              ),
              backgroundColor: AppTheme.getCardColor(context),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.profileErrorWithDetails(e)),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
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
                      context.l10n.profileChangePasswordTitle,
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
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 16),
                      Text(
                        context.l10n.profileChangePasswordDescription,
                        style: TextStyle(
                          color: AppTheme.getTextColor(
                            context,
                          ).withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Current Password
                      TextFormField(
                        controller: _currentPasswordController,
                        obscureText: !_isCurrentPasswordVisible,
                        decoration: _passwordInputDecoration(
                          context,
                          label: context.l10n.profileCurrentPasswordLabel,
                          hint: context.l10n.profileCurrentPasswordHint,
                          isPasswordVisible: _isCurrentPasswordVisible,
                          onToggleVisibility: () {
                            setState(() {
                              _isCurrentPasswordVisible =
                                  !_isCurrentPasswordVisible;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.l10n.profileCurrentPasswordRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // New Password
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: !_isNewPasswordVisible,
                        decoration: _passwordInputDecoration(
                          context,
                          label: context.l10n.newPassword,
                          hint: context.l10n.profileNewPasswordHint,
                          isPasswordVisible: _isNewPasswordVisible,
                          onToggleVisibility: () {
                            setState(() {
                              _isNewPasswordVisible = !_isNewPasswordVisible;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.l10n.profileNewPasswordRequired;
                          }
                          if (value.length < 8) {
                            return context.l10n.profilePasswordMinLength;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Confirm Password
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: !_isConfirmPasswordVisible,
                        decoration: _passwordInputDecoration(
                          context,
                          label: context.l10n.confirmNewPassword,
                          hint: context.l10n.profileConfirmPasswordHint,
                          isPasswordVisible: _isConfirmPasswordVisible,
                          onToggleVisibility: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.l10n.profileConfirmPasswordRequired;
                          }
                          if (value != _newPasswordController.text) {
                            return context.l10n.profilePasswordsDoNotMatch;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      // Update Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updatePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.getPrimaryColor(context),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  context.l10n.updatePassword,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _passwordInputDecoration(
    BuildContext context, {
    required String label,
    required String hint,
    required bool isPasswordVisible,
    required VoidCallback onToggleVisibility,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.surfaceDark.withValues(alpha: 0.5)
          : Colors.grey[50],
      labelStyle: TextStyle(
        color: AppTheme.getTextColor(context),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: AppTheme.getTextColor(context).withValues(alpha: 0.5),
        fontSize: 16,
        letterSpacing: 2,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppTheme.getTextColor(context).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.getTextColor(context), width: 2),
      ),
      suffixIcon: IconButton(
        icon: Icon(
          isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
        ),
        onPressed: onToggleVisibility,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
