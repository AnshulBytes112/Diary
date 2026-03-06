import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; 

import 'src/features/auth/forgot_password_page.dart';
import 'src/features/auth/sign_in_page.dart';
import 'src/features/auth/sign_up_page.dart';
import 'src/features/dashboard/dashboard_page.dart';
import 'src/features/profile/profile_page.dart';
import 'src/features/search/search_entries_page.dart';
import 'src/state/app_state.dart';
import 'src/state/app_state_scope.dart';
import 'src/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Firestore Web can hit INTERNAL assertion issues with persistence + pending writes.
  // Disabling persistence keeps things stable for now (we can re-enable later).
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: false);
  runApp(const MindfulDiaryApp());
}

final AppState _appState = AppState();

class MindfulDiaryApp extends StatelessWidget {
  const MindfulDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      appState: _appState,
      child: MaterialApp(
        title: 'Mindful Diary',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        routes: {
          SignUpPage.routeName: (_) => const SignUpPage(),
          SignInPage.routeName: (_) => const SignInPage(),
          ForgotPasswordPage.routeName: (_) => const ForgotPasswordPage(),
          DashboardPage.routeName: (_) => const DashboardPage(),
          TimelinePage.routeName: (_) => const TimelinePage(),
          AnalyticsPage.routeName: (_) => const AnalyticsPage(),
          SearchEntriesPage.routeName: (_) => const SearchEntriesPage(),
          ProfilePage.routeName: (_) => const ProfilePage(),
        },
        home: const LandingPage(),
      ),
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  _buildSoulBadge(),
                  const SizedBox(height: 32),
                  _buildHeroSection(),
                  const SizedBox(height: 48),
                  _buildActionButtons(context),
                  const SizedBox(height: 64),
                  _buildDivider(),
                  const SizedBox(height: 64),
                  _buildFeaturesHeader(),
                  const SizedBox(height: 48),
                  const FeatureCard(
                    icon: Icons.book_outlined,
                    title: 'Daily Journal',
                    description:
                        'Capture your thoughts and experiences in a beautiful, timeless format.',
                  ),
                  const SizedBox(height: 24),
                  const FeatureCard(
                    icon: Icons.sentiment_satisfied_alt_outlined,
                    title: 'Mood Tracking',
                    description:
                        'Record your emotional journey with elegant ink-style mood indicators.',
                  ),
                  const SizedBox(height: 24),
                  const FeatureCard(
                    icon: Icons.mic_none_outlined,
                    title: 'Voice Entries',
                    description:
                        'Speak your mind freely with voice-to-text for when writing isn\'t convenient.',
                  ),
                  const SizedBox(height: 24),
                  const FeatureCard(
                    icon: Icons.lock_outline,
                    title: 'Private & Secure',
                    description:
                        'Keep your memories safe with password-protected private entries.',
                  ),
                  const SizedBox(height: 24),
                  const FeatureCard(
                    icon: Icons.analytics_outlined,
                    title: 'Insights & Analytics',
                    description:
                        'Discover patterns in your journaling with beautiful visual summaries.',
                  ),
                  const SizedBox(height: 80),
                  _buildStepsSection(),
                  const SizedBox(height: 80),
                  _buildTestimonialsSection(),
                  const SizedBox(height: 80),
                  _buildFinalCTA(context),
                  const SizedBox(height: 48),
                  _buildMoodDisplay(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      backgroundColor: const Color(0xFF4E342E),
      elevation: 0,
      centerTitle: false,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF8D6E63),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Mindful Diary',
            style: GoogleFonts.playfairDisplay(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: TextButton(
            onPressed: () {
              if (!context.mounted) return;
              Navigator.of(context).pushNamed(SignUpPage.routeName);
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF6D4C41),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
            ),
            child: const Text('Get Started'),
          ),
        ),
      ],
    );
  }

  Widget _buildSoulBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEBE9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD7CCC8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bookmark, color: Color(0xFF8D6E63), size: 16),
          const SizedBox(width: 8),
          Text(
            'A Digital Journal with Soul',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF5D4037),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        Text(
          'Your Personal\nTimeless Diary',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Capture your daily thoughts in a beautifully crafted digital journal that feels like your favorite leather-bound diary. Start your journey to mindful reflection today.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: const Color(0xFF6D4C41).withOpacity(0.8),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              if (!context.mounted) return;
              Navigator.of(context).pushNamed(SignUpPage.routeName);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5D4037),
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.edit_note),
                const SizedBox(width: 8),
                Text(
                  'Start Writing Free',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () {
              if (!context.mounted) return;
              Navigator.of(context).pushNamed(SignInPage.routeName);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF5D4037),
              side: const BorderSide(color: Color(0xFFD7CCC8), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.visibility_outlined),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'I already have an account',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Divider(color: Color(0xFFD7CCC8), thickness: 1),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: const Color(0xFFF5F0E1),
          child: const Icon(Icons.eco, color: Color(0xFF8D6E63), size: 24),
        ),
      ],
    );
  }

  Widget _buildFeaturesHeader() {
    return Column(
      children: [
        Text(
          'Everything You Need for\nMindful Journaling',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3E2723),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Designed with care to help you build a consistent journaling habit in a beautiful, timeless space.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: const Color(0xFF6D4C41).withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildStepsSection() {
    return Column(
      children: [
        Text(
          'Start Your Journey in 3\nSimple Steps',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3E2723),
          ),
        ),
        const SizedBox(height: 48),
        _buildStepItem('01', 'Create Your Diary',
            'Sign up and personalize your digital journal with a beautiful leather-bound cover.'),
        const SizedBox(height: 40),
        _buildStepItem('02', 'Write Daily',
            'Add entries with text or voice. Track your mood with elegant ink-style indicators.'),
        const SizedBox(height: 40),
        _buildStepItem('03', 'Grow Mindfully',
            'Review your journey with insightful analytics and reflect on your personal growth.'),
      ],
    );
  }

  Widget _buildStepItem(String number, String title, String description) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF795548),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            number,
            style: GoogleFonts.playfairDisplay(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3E2723),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          description,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: const Color(0xFF6D4C41).withOpacity(0.8),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTestimonialsSection() {
    return Column(
      children: [
        Text(
          'Cherished by Journal\nKeepers',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3E2723),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'See what our community says about their journaling journey.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: const Color(0xFF6D4C41).withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 48),
        const TestimonialCard(
          name: 'Sarah M.',
          role: 'Daily Writer',
          quote:
              '"This diary app feels like writing in my grandmother\'s leather journal. Absolutely beautiful and nostalgic."',
        ),
        const SizedBox(height: 24),
        const TestimonialCard(
          name: 'David L.',
          role: 'Mindfulness Coach',
          quote:
              '"The vintage aesthetic makes journaling feel special. My clients love the warm, personal touch."',
        ),
      ],
    );
  }

  Widget _buildFinalCTA(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 40,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF8D6E63),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 24),
            ],
          ),
          Text(
            'Ready to Begin Your\nTimeless Journey?',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF3E2723),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Join thousands who have discovered the joy of mindful journaling. Your first page is waiting to be written.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: const Color(0xFF6D4C41).withOpacity(0.7),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (!context.mounted) return;
                Navigator.of(context).pushNamed(SignUpPage.routeName);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D4037),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.edit_note),
                  const SizedBox(width: 8),
                  Text(
                    'Create Your Diary',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () {
                if (!context.mounted) return;
                Navigator.of(context).pushNamed(SignInPage.routeName);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF5D4037),
                side: const BorderSide(color: Color(0xFFD7CCC8), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Already have an account?',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No credit card required. Free forever plan available.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Entry",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "January 14, 2026",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text("😊", style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    "Happy",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6D4C41),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF3E2723),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: const Color(0xFF6D4C41).withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class TestimonialCard extends StatelessWidget {
  final String name;
  final String role;
  final String quote;

  const TestimonialCard({
    super.key,
    required this.name,
    required this.role,
    required this.quote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 20),
              Icon(Icons.star, color: Colors.amber, size: 20),
              Icon(Icons.star, color: Colors.amber, size: 20),
              Icon(Icons.star, color: Colors.amber, size: 20),
              Icon(Icons.star, color: Colors.amber, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            quote,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF4E342E),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF8D6E63),
                child: Text(
                  name[0],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3E2723),
                    ),
                  ),
            Text(
                    role,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF8D6E63),
                    ),
                  ),
                ],
            ),
          ],
        ),
        ],
      ),
    );
  }
}
