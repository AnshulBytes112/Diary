import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../widgets/animated_backdrop.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.t,
    required this.child,
  });

  final double t;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final pad = media.size.width < 420 ? 18.0 : 24.0;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedBackdrop(t: t),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(pad),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: AuthCard(child: child),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatelessWidget {
  const AuthCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 10),
        child: child,
      ),
    );
  }
}

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, required this.t});
  final double t;

  @override
  Widget build(BuildContext context) {
    final wobble = (t * 0.5 + 0.5);

    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 450),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.copper.withValues(alpha: 0.95),
                AppColors.cocoa.withValues(alpha: 0.85),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.copper.withValues(alpha: 0.30 + 0.05 * wobble),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'md',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
            ),
          ),
        ),
        const Spacer(),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(Icons.more_horiz, color: AppColors.inkMuted),
        ),
      ],
    );
  }
}
