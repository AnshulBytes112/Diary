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
          content: Text(
            'Reset link sent to $email. Check your inbox and spam folder. '
            'Use the same email you used to sign up.',
          ),
          duration: const Duration(seconds: 5),
        ),
      );
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found for this email. Use the address you signed up with.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'invalid-credential':
          message = 'Invalid request. Check the email and try again.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;
        default:
          message = e.message ?? 'Failed to send reset email (${e.code}).';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 4)),
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
                'Use the exact email you used to sign up. We’ll send a reset link—check spam if you don’t see it.',
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
