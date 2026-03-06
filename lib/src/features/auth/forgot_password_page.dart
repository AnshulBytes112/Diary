import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/gradient_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  static const routeName = '/forgot-password';

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bgController;

  final _emailKey = GlobalKey<FormState>();
  final _resetKey = GlobalKey<FormState>();

  final _email = TextEditingController();
  final _otp = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirm = TextEditingController();

  bool _otpSent = false;
  String? _demoOtp;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _email.dispose();
    _otp.dispose();
    _newPassword.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool _isValidEmail(String v) => RegExp(r'^\S+@\S+\.\S+$').hasMatch(v);

  Future<void> _requestOtp() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_emailKey.currentState?.validate() ?? false)) return;

    final rng = math.Random();
    final code = (rng.nextInt(900000) + 100000).toString();

    setState(() {
      _otpSent = true;
      _demoOtp = code;
      _otp.text = '';
      _newPassword.text = '';
      _confirm.text = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'OTP sent to ${_email.text.trim()} (demo code: $code)',
        ),
      ),
    );
  }

  Future<void> _resetPassword() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_resetKey.currentState?.validate() ?? false)) return;

    if (_otp.text.trim() != (_demoOtp ?? '')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP (demo).')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset (demo). Please sign in.')),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, _) {
        return AuthScaffold(
          t: _bgController.value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              BrandHeader(t: _bgController.value),
              const SizedBox(height: 18),
              Text(
                'Forgot password',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.ink,
                      height: 1.05,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'We’ll send a one-time code to your Gmail to verify it (UI demo only).',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 22),
              Form(
                key: _emailKey,
                child: TextFormField(
                  controller: _email,
                  enabled: !_otpSent,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    hintText: 'you@gmail.com',
                    prefixIcon: Icon(Icons.mail_outline),
                  ),
                  validator: (v) {
                    final value = (v ?? '').trim();
                    if (value.isEmpty) return 'Please enter your email';
                    if (!_isValidEmail(value)) return 'Please enter a valid email';
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 14),
              if (!_otpSent)
                GradientButton(
                  label: 'Request OTP',
                  icon: Icons.mark_email_unread_outlined,
                  onPressed: _requestOtp,
                )
              else ...[
                _OtpSentBanner(email: _email.text.trim()),
                const SizedBox(height: 14),
                Form(
                  key: _resetKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _otp,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'OTP code',
                          hintText: '6-digit code',
                          prefixIcon: Icon(Icons.verified_outlined),
                        ),
                        validator: (v) {
                          final value = (v ?? '').trim();
                          if (value.isEmpty) return 'Enter the OTP code';
                          if (value.length != 6) return 'OTP must be 6 digits';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _newPassword,
                        obscureText: _obscureNew,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'New password',
                          hintText: 'Create a new password',
                          prefixIcon: const Icon(Icons.lock_reset_outlined),
                          suffixIcon: IconButton(
                            tooltip: _obscureNew ? 'Show password' : 'Hide password',
                            onPressed: () =>
                                setState(() => _obscureNew = !_obscureNew),
                            icon: Icon(
                              _obscureNew
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (v) {
                          final value = v ?? '';
                          if (value.isEmpty) return 'Enter a new password';
                          if (value.length < 8) return 'Use at least 8 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _confirm,
                        obscureText: _obscureConfirm,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'Confirm new password',
                          hintText: 'Repeat the new password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip:
                                _obscureConfirm ? 'Show password' : 'Hide password',
                            onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (v) {
                          final value = v ?? '';
                          if (value.isEmpty) return 'Please confirm your password';
                          if (value != _newPassword.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _resetPassword(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GradientButton(
                  label: 'Reset password',
                  icon: Icons.check_circle_outline,
                  onPressed: _resetPassword,
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _otpSent = false;
                      _demoOtp = null;
                    });
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Send a new code'),
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _OtpSentBanner extends StatelessWidget {
  const _OtpSentBanner({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        color: Colors.white.withValues(alpha: 0.45),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: AppColors.copper.withValues(alpha: 0.14),
              ),
              child: const Icon(
                Icons.mark_email_read_outlined,
                color: AppColors.cocoa,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OTP sent',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Check $email',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

