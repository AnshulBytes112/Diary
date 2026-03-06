import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

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
    final wobble = (math.sin(t * math.pi) * 0.5 + 0.5);

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

class AnimatedBackdrop extends StatelessWidget {
  const AnimatedBackdrop({super.key, required this.t});
  final double t;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final wobble = (math.sin(t * math.pi) * 0.5 + 0.5);
    final a = Alignment(-0.8 + wobble * 0.25, -0.9 + wobble * 0.2);
    final b = Alignment(0.9 - wobble * 0.25, 1.0 - wobble * 0.2);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: a,
          end: b,
          colors: const [
            AppColors.bg,
            AppColors.bg2,
            Color(0xFFF8EEE2),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -size.width * 0.25,
            top: -size.height * 0.16,
            child: _Blob(
              diameter: size.width * 0.95,
              color: AppColors.copper.withValues(alpha: 0.18),
              blurSigma: 38,
              dx: 18 * wobble,
              dy: 10 * (1 - wobble),
            ),
          ),
          Positioned(
            right: -size.width * 0.35,
            top: size.height * 0.18,
            child: _Blob(
              diameter: size.width * 0.9,
              color: AppColors.cocoa.withValues(alpha: 0.12),
              blurSigma: 42,
              dx: -16 * wobble,
              dy: 14 * wobble,
            ),
          ),
          Positioned(
            left: size.width * 0.12,
            bottom: -size.height * 0.18,
            child: _Blob(
              diameter: size.width * 0.85,
              color: AppColors.copper2.withValues(alpha: 0.10),
              blurSigma: 45,
              dx: 12 * (1 - wobble),
              dy: -10 * wobble,
            ),
          ),
          IgnorePointer(
            child: CustomPaint(
              size: Size.infinite,
              painter: _DotGridPainter(opacity: 0.06 + 0.02 * wobble),
            ),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({
    required this.diameter,
    required this.color,
    required this.blurSigma,
    required this.dx,
    required this.dy,
  });

  final double diameter;
  final Color color;
  final double blurSigma;
  final double dx;
  final double dy;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(dx, dy),
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: blurSigma,
              spreadRadius: blurSigma * 0.22,
            ),
          ],
        ),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  const _DotGridPainter({required this.opacity});
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final paint = Paint()
      ..color = AppColors.ink.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    const step = 18.0;
    const r = 1.05;
    for (double y = 12; y < size.height; y += step) {
      for (double x = 10; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), r, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}

