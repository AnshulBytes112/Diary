import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  final _email = TextEditingController();
  bool _sending = false;

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
    super.dispose();
  }

  bool _isValidEmail(String v) => RegExp(r'^\S+@\S+\.\S+$').hasMatch(v);

  Future<void> _sendResetEmail() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_emailKey.currentState?.validate() ?? false)) return;

    final email = _email.text.trim();
    setState(() => _sending = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset link sent to $email'),
        ),
      );
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message = 'Failed to send reset email.';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'invalid-email') {
        message = 'That email address is not valid.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
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
                'Enter your account email and we’ll send you a secure password reset link.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 22),
              Form(
                key: _emailKey,
                child: TextFormField(
                  controller: _email,
                  enabled: !_sending,
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
                  onFieldSubmitted: (_) => _sendResetEmail(),
                ),
              ),
              const SizedBox(height: 14),
              GradientButton(
                label: _sending ? 'Sending...' : 'Send reset link',
                icon: Icons.mark_email_unread_outlined,
                onPressed: () {
                  if (_sending) return;
                  _sendResetEmail();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
