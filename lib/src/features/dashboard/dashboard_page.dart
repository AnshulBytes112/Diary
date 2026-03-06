import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/diary_entry.dart';
import '../../firebase/entries_repo.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animated_backdrop.dart';
import '../profile/profile_page.dart';
import '../search/search_entries_page.dart';
import '../auth/sign_in_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  static const routeName = '/dashboard';

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bgController;
  final _entryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..repeat(reverse: true);
    _entryController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _bgController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  int get _wordCount {
    final t = _entryController.text.trim();
    if (t.isEmpty) return 0;
    return t.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

  String _formatDate(DateTime d) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final weekday = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ][d.weekday - 1];
    return '$weekday, ${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  Future<void> _saveEntry() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final text = _entryController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write something first.')),
      );
      return;
    }

    final app = AppStateScope.of(context);
    try {
      await EntriesRepo().addEntry(
        mood: app.selectedMood,
        text: text,
        isPublic: app.isPublic,
      );
      _entryController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry saved.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final media = MediaQuery.of(context);
    final pad = media.size.width < 420 ? 18.0 : 24.0;
    final user = FirebaseAuth.instance.currentUser;

    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, _) {
        if (user == null) {
          return Scaffold(
            body: Stack(
              children: [
                AnimatedBackdrop(t: _bgController.value),
                SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Padding(
                        padding: EdgeInsets.all(pad),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Please sign in',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(color: AppColors.ink),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Your entries are tied to your account.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 18),
                            FilledButton(
                              onPressed: () => Navigator.of(context)
                                  .pushReplacementNamed(SignInPage.routeName),
                              child: const Text('Go to Sign In'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: Stack(
            children: [
              AnimatedBackdrop(t: _bgController.value),
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(pad),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _HeaderRow(
                            date: _formatDate(DateTime.now()),
                            onSearch: () => Navigator.of(context)
                                .pushNamed(SearchEntriesPage.routeName),
                            onProfile: () => Navigator.of(context)
                                .pushNamed(ProfilePage.routeName),
                          ),
                          const SizedBox(height: 18),
                          _SectionCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'How are you feeling today?',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: AppColors.ink,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 14),
                                GridView.count(
                                  crossAxisCount:
                                      media.size.width < 420 ? 4 : 4,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: 0.95,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: Mood.values.map((m) {
                                    final selected = app.selectedMood == m;
                                    return _MoodTile(
                                      mood: m,
                                      selected: selected,
                                      onTap: () => app.setMood(m),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _SectionCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Today's Entry",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: AppColors.ink,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    const Spacer(),
                                    _VisibilityChip(
                                      value: app.isPublic,
                                      onChanged: app.setPublic,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _LinedEditor(controller: _entryController),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _SquareIconButton(
                                      icon: Icons.image_outlined,
                                      onPressed: () {},
                                    ),
                                    const SizedBox(width: 10),
                                    _SquareIconButton(
                                      icon: Icons.emoji_emotions_outlined,
                                      onPressed: () {},
                                    ),
                                    const SizedBox(width: 10),
                                    _SquareIconButton(
                                      icon: Icons.tag_outlined,
                                      onPressed: () {},
                                    ),
                                    const Spacer(),
                                    _SaveEntryButton(
                                      onPressed: _saveEntry,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    '$_wordCount words',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: AppColors.inkMuted),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          StreamBuilder<List<DiaryEntry>>(
                            stream: EntriesRepo().watchEntries(limit: 2),
                            builder: (context, snap) {
                              final entries = snap.data ?? const <DiaryEntry>[];
                              if (entries.isEmpty) return const SizedBox.shrink();
                              return _RecentEntriesPreview(entries: entries);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.date,
    required this.onSearch,
    required this.onProfile,
  });

  final String date;
  final VoidCallback onSearch;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Dashboard',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.ink,
                      height: 1.05,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.inkMuted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _TopIconButton(
          icon: Icons.search_rounded,
          tooltip: 'Search entries',
          onPressed: onSearch,
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: onProfile,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 42,
            height: 42,
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
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.person_outline, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _TopIconButton extends StatelessWidget {
  const _TopIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            color: Colors.white.withValues(alpha: 0.35),
          ),
          child: Icon(icon, color: AppColors.inkMuted),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class _MoodTile extends StatelessWidget {
  const _MoodTile({
    required this.mood,
    required this.selected,
    required this.onTap,
  });

  final Mood mood;
  final bool selected;
  final VoidCallback onTap;

  static const _meta = <Mood, (String emoji, String label)>{
    Mood.happy: ('😊', 'Happy'),
    Mood.sad: ('😟', 'Sad'),
    Mood.angry: ('😡', 'Angry'),
    Mood.anxious: ('😰', 'Anxious'),
    Mood.calm: ('😌', 'Calm'),
    Mood.thoughtful: ('🤔', 'Thoughtful'),
    Mood.tired: ('😴', 'Tired'),
    Mood.excited: ('🥳', 'Excited'),
  };

  @override
  Widget build(BuildContext context) {
    final (emoji, label) = _meta[mood]!;
    final bg = selected
        ? AppColors.copper.withValues(alpha: 0.22)
        : Colors.white.withValues(alpha: 0.38);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.copper : AppColors.border,
            width: selected ? 1.4 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.copper.withValues(alpha: 0.22),
                    blurRadius: 16,
                    offset: const Offset(0, 10),
                  ),
                ]
              : const [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.inkMuted,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisibilityChip extends StatelessWidget {
  const _VisibilityChip({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final icon = value ? Icons.lock_open_rounded : Icons.lock_rounded;
    final label = value ? 'Public' : 'Private';

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.border),
          color: Colors.white.withValues(alpha: 0.40),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.inkMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.inkMuted,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinedEditor extends StatelessWidget {
  const _LinedEditor({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CustomPaint(
        painter: _LinesPainter(),
        child: TextField(
          controller: controller,
          maxLines: 7,
          decoration: const InputDecoration(
            hintText: 'Write your thoughts here…',
            border: InputBorder.none,
            filled: true,
            fillColor: Color(0x66FFFFFF),
            contentPadding: EdgeInsets.fromLTRB(16, 14, 16, 14),
          ),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.ink,
                height: 1.35,
              ),
        ),
      ),
    );
  }
}

class _LinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.70)
      ..strokeWidth = 1;

    const topPad = 14.0;
    const lineGap = 24.0;
    for (double y = topPad + lineGap; y < size.height; y += lineGap) {
      canvas.drawLine(Offset(14, y), Offset(size.width - 14, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          color: Colors.white.withValues(alpha: 0.38),
        ),
        child: Icon(icon, color: AppColors.inkMuted),
      ),
    );
  }
}

class _SaveEntryButton extends StatelessWidget {
  const _SaveEntryButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.copper, AppColors.cocoa],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.copper.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.save_outlined, size: 18, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Save\nEntry',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                height: 1.05,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentEntriesPreview extends StatelessWidget {
  const _RecentEntriesPreview({required this.entries});
  final List<DiaryEntry> entries;

  @override
  Widget build(BuildContext context) {
    final top = entries.take(2).toList();
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent entries',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          ...top.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _EntryRow(entry: e),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry});
  final DiaryEntry entry;

  static const _emoji = <Mood, String>{
    Mood.happy: '😊',
    Mood.sad: '😟',
    Mood.angry: '😡',
    Mood.anxious: '😰',
    Mood.calm: '😌',
    Mood.thoughtful: '🤔',
    Mood.tired: '😴',
    Mood.excited: '🥳',
  };

  @override
  Widget build(BuildContext context) {
    final snippet = entry.text.replaceAll('\n', ' ').trim();
    final short = snippet.length > 80 ? '${snippet.substring(0, 80)}…' : snippet;
    final minutes = entry.createdAt.minute.toString().padLeft(2, '0');
    final time = '${entry.createdAt.hour}:$minutes';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        color: Colors.white.withValues(alpha: 0.35),
      ),
      child: Row(
        children: [
          Text(_emoji[entry.mood]!, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  short,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.ink,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppColors.inkMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

