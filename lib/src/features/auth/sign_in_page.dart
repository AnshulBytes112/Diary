import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../theme/app_colors.dart';
import 'forgot_password_page.dart';
import '../dashboard/dashboard_page.dart';
import '../../firebase/auth_repo.dart';
import 'sign_up_page.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/gradient_button.dart';
import 'widgets/social_row.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  static const routeName = '/sign-in';

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bgController;

  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _obscurePassword = true;
  bool _loading = false;

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
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);
    try {
      await AuthRepo().signInWithEmail(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(DashboardPage.routeName);
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('FirebaseAuth signIn error: code=${e.code} message=${e.message}');
      }
      final msg = (e.message == null || e.message!.trim().isEmpty)
          ? 'Sign in failed (${e.code})'
          : '${e.message} (${e.code})';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, _) {
        return AuthScaffold(
          t: _bgController.value,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                BrandHeader(t: _bgController.value),
                const SizedBox(height: 18),
                Text(
                  'Welcome back',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: AppColors.ink,
                        height: 1.05,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sign in to continue your journaling.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _email,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    hintText: 'you@email.com',
                    prefixIcon: Icon(Icons.mail_outline),
                  ),
                  validator: (v) {
                    final value = (v ?? '').trim();
                    if (value.isEmpty) return 'Please enter your email';
                    final ok = RegExp(r'^\S+@\S+\.\S+$').hasMatch(value);
                    if (!ok) return 'Please enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _password,
                  textInputAction: TextInputAction.done,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      tooltip:
                          _obscurePassword ? 'Show password' : 'Hide password',
                      onPressed: () => setState(() {
                        _obscurePassword = !_obscurePassword;
                      }),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (v) {
                    final value = v ?? '';
                    if (value.isEmpty) return 'Please enter your password';
                    if (value.length < 6) return 'Password looks too short';
                    return null;
                  },
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context)
                        .pushNamed(ForgotPasswordPage.routeName),
                    child: const Text('Forgot password?'),
                  ),
                ),
                const SizedBox(height: 10),
                GradientButton(
                  label: _loading ? 'Signing in…' : 'Sign in',
                  onPressed: _loading ? () {} : _submit,
                ),
                const SizedBox(height: 18),
                const DividerLabel(label: 'or continue with'),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: SocialButton(
                        icon: Icons.g_mobiledata,
                        label: 'Google',
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SocialButton(
                        icon: Icons.apple,
                        label: 'Apple',
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context)
                        .pushNamed(SignUpPage.routeName),
                    child: const Text("Don't have an account? Sign up"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

