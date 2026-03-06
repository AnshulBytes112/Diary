import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../theme/app_colors.dart';
import '../auth/sign_in_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 86,
              height: 86,
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
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 20,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: const Icon(Icons.person_outline, color: Colors.white, size: 34),
            ),
            const SizedBox(height: 14),
            Text(
              user?.displayName ?? 'User',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '—',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.inkMuted),
            ),
            const SizedBox(height: 18),
            _Tile(
              icon: Icons.manage_accounts_outlined,
              title: 'Edit profile',
              onTap: () {},
            ),
            _Tile(
              icon: Icons.lock_outline,
              title: 'Security',
              onTap: () {},
            ),
            _Tile(
              icon: Icons.palette_outlined,
              title: 'Appearance',
              onTap: () {},
            ),
            _Tile(
              icon: Icons.logout_rounded,
              title: 'Sign out',
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (!context.mounted) return;
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(SignInPage.routeName, (_) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            color: Colors.white.withValues(alpha: 0.45),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.inkMuted),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.inkMuted),
            ],
          ),
        ),
      ),
    );
  }
}

