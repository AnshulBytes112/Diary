import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'sign_in_page.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/gradient_button.dart';
import 'widgets/social_row.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  static const routeName = '/sign-up';

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bgController;

  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _acceptTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..repeat(reverse: true);
    _password.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _bgController.dispose();
    _fullName.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  double get _passwordStrength {
    final p = _password.text;
    if (p.isEmpty) return 0;
    double score = 0;
    if (p.length >= 8) score += 0.35;
    if (p.length >= 12) score += 0.15;
    if (RegExp(r'[A-Z]').hasMatch(p)) score += 0.15;
    if (RegExp(r'[0-9]').hasMatch(p)) score += 0.15;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) score += 0.2;
    return score.clamp(0, 1);
  }

  Color get _strengthColor {
    final s = _passwordStrength;
    if (s < 0.34) return AppColors.danger;
    if (s < 0.67) return AppColors.warning;
    return AppColors.success;
  }

  String get _strengthLabel {
    final s = _passwordStrength;
    if (s == 0) return '—';
    if (s < 0.34) return 'Weak';
    if (s < 0.67) return 'Okay';
    return 'Strong';
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms & Privacy Policy')),
      );
      return;
    }

    // Placeholder action. Replace with backend call.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account created (demo).')),
    );
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
                    'Create account',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppColors.ink,
                          height: 1.05,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Start your mindful journaling journey',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 22),
                  TextFormField(
                    controller: _fullName,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      labelText: 'Full name',
                      hintText: 'John Doe',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (value.isEmpty) return 'Please enter your name';
                      if (value.length < 2) return 'Name looks too short';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
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
                    textInputAction: TextInputAction.next,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Create a password',
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
                      if (value.isEmpty) return 'Please create a password';
                      if (value.length < 8) return 'Use at least 8 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  _StrengthRow(
                    strength: _passwordStrength,
                    color: _strengthColor,
                    label: _strengthLabel,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _confirmPassword,
                    textInputAction: TextInputAction.done,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirm password',
                      hintText: 'Confirm your password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        tooltip:
                            _obscureConfirm ? 'Show password' : 'Hide password',
                        onPressed: () => setState(() {
                          _obscureConfirm = !_obscureConfirm;
                        }),
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
                      if (value != _password.text) return 'Passwords do not match';
                      return null;
                    },
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 14),
                  _TermsRow(
                    value: _acceptTerms,
                    onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                  ),
                  const SizedBox(height: 16),
                  GradientButton(label: 'Create account', onPressed: _submit),
                  const SizedBox(height: 18),
                  const DividerLabel(label: 'or sign up with'),
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
                      onPressed: () =>
                          Navigator.of(context).pushNamed(SignInPage.routeName),
                      child: const Text('Already have an account? Sign in'),
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

class _StrengthRow extends StatelessWidget {
  const _StrengthRow({
    required this.strength,
    required this.color,
    required this.label,
  });

  final double strength;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: SizedBox(
              height: 7,
              child: LinearProgressIndicator(
                value: strength == 0 ? 0.02 : strength,
                color: color,
                backgroundColor: AppColors.border.withValues(alpha: 0.35),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.inkMuted,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _TermsRow extends StatelessWidget {
  const _TermsRow({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox.adaptive(value: value, onChanged: onChanged),
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'I agree to the ',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                'Terms',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      decoration: TextDecoration.underline,
                      color: AppColors.cocoa,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                ' & ',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                'Privacy Policy',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      decoration: TextDecoration.underline,
                      color: AppColors.cocoa,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
