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
  late DateTime _timelineMonth;
  late DateTime _selectedTimelineDate;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..repeat(reverse: true);
    _entryController.addListener(() => setState(() {}));
    final now = DateTime.now();
    _timelineMonth = DateTime(now.year, now.month, 1);
    _selectedTimelineDate = DateTime(now.year, now.month, now.day);
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

  Future<void> _showEditEntrySheet(DiaryEntry entry) async {
    final controller = TextEditingController(text: entry.text);
    Mood mood = entry.mood;
    bool isPublic = entry.isPublic;
    bool saving = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final viewInsets = MediaQuery.of(context).viewInsets;
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> save() async {
              final text = controller.text.trim();
              if (text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Entry can’t be empty.')),
                );
                return;
              }
              setModalState(() => saving = true);
              try {
                await EntriesRepo().updateEntry(
                  entryId: entry.id,
                  mood: mood,
                  text: text,
                  isPublic: isPublic,
                );
                if (!context.mounted) return;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text('Entry updated.')),
                );
              } catch (e) {
                setModalState(() => saving = false);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Update failed: $e')),
                );
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: 16 + viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Edit entry',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<Mood>(
                          value: mood,
                          items: Mood.values
                              .map(
                                (m) => DropdownMenuItem(
                                  value: m,
                                  child: Text('${kMoodEmoji[m]}  ${kMoodLabel[m]}'),
                                ),
                              )
                              .toList(),
                          onChanged: saving
                              ? null
                              : (v) {
                                  if (v == null) return;
                                  setModalState(() => mood = v);
                                },
                          decoration: const InputDecoration(
                            labelText: 'Mood',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<bool>(
                          value: isPublic,
                          items: const [
                            DropdownMenuItem(value: true, child: Text('Public')),
                            DropdownMenuItem(value: false, child: Text('Private')),
                          ],
                          onChanged: saving
                              ? null
                              : (v) {
                                  if (v == null) return;
                                  setModalState(() => isPublic = v);
                                },
                          decoration: const InputDecoration(
                            labelText: 'Visibility',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    maxLines: 8,
                    textInputAction: TextInputAction.newline,
                    decoration: const InputDecoration(
                      labelText: 'Text',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: saving ? null : save,
                    icon: saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(saving ? 'Saving…' : 'Save changes'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    controller.dispose();
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
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => Navigator.of(context)
                                      .pushNamed(TimelinePage.routeName),
                                  icon: const Icon(Icons.timeline_outlined),
                                  label: const Text('Timeline'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => Navigator.of(context)
                                      .pushNamed(AnalyticsPage.routeName),
                                  icon: const Icon(Icons.analytics_outlined),
                                  label: const Text('Analytics'),
                                ),
                              ),
                            ],
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
                              return _RecentEntriesPreview(
                                entries: entries,
                                onTapEntry: _showEditEntrySheet,
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          StreamBuilder<List<DiaryEntry>>(
                            stream: EntriesRepo().watchEntriesForMonth(
                              year: _timelineMonth.year,
                              month: _timelineMonth.month,
                              limit: 400,
                            ),
                            builder: (context, snap) {
                              final monthEntries =
                                  snap.data ?? const <DiaryEntry>[];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _MemoryTimelineSection(
                                    month: _timelineMonth,
                                    selectedDate: _selectedTimelineDate,
                                    entries: monthEntries,
                                    onPreviousMonth: () {
                                      setState(() {
                                        _timelineMonth = DateTime(
                                          _timelineMonth.year,
                                          _timelineMonth.month - 1,
                                          1,
                                        );
                                      });
                                    },
                                    onNextMonth: () {
                                      setState(() {
                                        _timelineMonth = DateTime(
                                          _timelineMonth.year,
                                          _timelineMonth.month + 1,
                                          1,
                                        );
                                      });
                                    },
                                    onSelectDate: (d) {
                                      setState(() {
                                        _selectedTimelineDate = d;
                                      });
                                    },
                                    onEditEntry: _showEditEntrySheet,
                                  ),
                                  const SizedBox(height: 16),
                                  _AnalyticsSection(entries: monthEntries),
                                ],
                              );
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
  const _RecentEntriesPreview({
    required this.entries,
    required this.onTapEntry,
  });
  final List<DiaryEntry> entries;
  final ValueChanged<DiaryEntry> onTapEntry;

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
              child: _EntryRow(
                entry: e,
                onTap: () => onTapEntry(e),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({
    required this.entry,
    required this.onTap,
  });
  final DiaryEntry entry;
  final VoidCallback onTap;

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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
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
      ),
    );
  }
}

class _MemoryTimelineSection extends StatelessWidget {
  const _MemoryTimelineSection({
    required this.month,
    required this.selectedDate,
    required this.entries,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectDate,
    required this.onEditEntry,
  });

  final DateTime month;
  final DateTime selectedDate;
  final List<DiaryEntry> entries;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onSelectDate;
  final ValueChanged<DiaryEntry> onEditEntry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthName = [
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
    ][month.month - 1];

    final monthLabel = '$monthName ${month.year}';

    final selectedDayEntries = entries.where((e) {
      final d = e.createdAt;
      return d.year == selectedDate.year &&
          d.month == selectedDate.month &&
          d.day == selectedDate.day;
    }).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Memory Timeline',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Previous month',
                onPressed: onPreviousMonth,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Text(
                monthLabel,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.inkMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                tooltip: 'Next month',
                onPressed: onNextMonth,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _CalendarGrid(
            month: month,
            selectedDate: selectedDate,
            entries: entries,
            onSelectDate: onSelectDate,
          ),
          const SizedBox(height: 12),
          if (selectedDayEntries.isEmpty)
            Text(
              'No memories on this day yet. Write something and it will appear here.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.inkMuted,
              ),
            )
          else ...[
            Text(
              'Timeline for ${selectedDate.day} $monthName',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            _TimelineList(
              entries: selectedDayEntries,
              onEdit: onEditEntry,
            ),
          ],
        ],
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.month,
    required this.selectedDate,
    required this.entries,
    required this.onSelectDate,
  });

  final DateTime month;
  final DateTime selectedDate;
  final List<DiaryEntry> entries;
  final ValueChanged<DateTime> onSelectDate;

  bool _hasEntriesForDay(int day) {
    return entries.any((e) {
      final d = e.createdAt;
      return d.year == month.year && d.month == month.month && d.day == day;
    });
  }

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstWeekdayIndex = firstDayOfMonth.weekday % 7; // 0 = Sunday

    final theme = Theme.of(context);
    final dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: dayLabels
              .map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.inkMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: daysInMonth + firstWeekdayIndex,
          itemBuilder: (context, index) {
            if (index < firstWeekdayIndex) {
              return const SizedBox.shrink();
            }
            final day = index - firstWeekdayIndex + 1;
            final hasEntries = _hasEntriesForDay(day);
            final isSelected = selectedDate.year == month.year &&
                selectedDate.month == month.month &&
                selectedDate.day == day;

            final date = DateTime(month.year, month.month, day);

            Color bg;
            Color border;
            Color textColor = AppColors.ink;

            if (isSelected) {
              bg = AppColors.copper.withValues(alpha: 0.25);
              border = AppColors.copper;
              textColor = AppColors.ink;
            } else if (hasEntries) {
              bg = AppColors.copper.withValues(alpha: 0.12);
              border = AppColors.copper.withValues(alpha: 0.7);
            } else {
              bg = Colors.white.withValues(alpha: 0.35);
              border = AppColors.border;
              textColor = AppColors.inkMuted;
            }

            return InkWell(
              onTap: () => onSelectDate(date),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: bg,
                  border: Border.all(color: border),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$day',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _TimelineList extends StatelessWidget {
  const _TimelineList({
    required this.entries,
    required this.onEdit,
  });

  final List<DiaryEntry> entries;
  final ValueChanged<DiaryEntry> onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: entries.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final e = entries[index];
          final snippet = e.text.replaceAll('\n', ' ').trim();
          final short =
              snippet.length > 90 ? '${snippet.substring(0, 90)}…' : snippet;
          final minutes = e.createdAt.minute.toString().padLeft(2, '0');
          final time = '${e.createdAt.hour}:$minutes';

          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              final d = e.createdAt;
              final dateLabel = '${d.day}/${d.month}/${d.year}';
              showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    '${_EntryRow._emoji[e.mood] ?? '📝'}  $dateLabel • $time',
                  ),
                  content: SingleChildScrollView(
                    child: Text(e.text),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onEdit(e);
                      },
                      child: const Text('Edit'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              width: 210,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                color: Colors.white.withValues(alpha: 0.45),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _EntryRow._emoji[e.mood] ?? '📝',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.inkMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      short,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.ink,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AnalyticsSection extends StatelessWidget {
  const _AnalyticsSection({required this.entries});

  final List<DiaryEntry> entries;

  Map<Mood, int> _moodCounts() {
    final counts = <Mood, int>{};
    for (final e in entries) {
      counts[e.mood] = (counts[e.mood] ?? 0) + 1;
    }
    return counts;
  }

  Set<DateTime> _uniqueDays() {
    return entries
        .map(
          (e) => DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day),
        )
        .toSet();
  }

  (int currentStreak, int bestStreak) _computeStreaks() {
    final days = _uniqueDays().toList()..sort();
    if (days.isEmpty) return (0, 0);

    int best = 1;
    int run = 1;
    for (var i = 1; i < days.length; i++) {
      final prev = days[i - 1];
      final curr = days[i];
      if (curr.difference(prev).inDays == 1) {
        run += 1;
      } else {
        if (run > best) best = run;
        run = 1;
      }
    }
    if (run > best) best = run;

    // Current streak up to today.
    final daySet = _uniqueDays();
    int current = 0;
    var cursor = DateTime.now();
    while (daySet.contains(DateTime(cursor.year, cursor.month, cursor.day))) {
      current += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return (current, best);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final moodCounts = _moodCounts();
    final totalEntries = entries.length;
    final totalDays = _uniqueDays().length;
    final avgPerDay = totalDays == 0 ? 0 : totalEntries / totalDays;

    Mood? mostCommonMood;
    if (moodCounts.isNotEmpty) {
      mostCommonMood = moodCounts.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
    }

    final (currentStreak, bestStreak) = _computeStreaks();

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _MoodGraph(counts: moodCounts),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatChip(
                label: 'Current streak',
                value: currentStreak == 0 ? '–' : '$currentStreak days',
                icon: Icons.local_fire_department_outlined,
              ),
              const SizedBox(width: 8),
              _StatChip(
                label: 'Best streak',
                value: bestStreak == 0 ? '–' : '$bestStreak days',
                icon: Icons.emoji_events_outlined,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _StatChip(
                label: 'Entries this month',
                value: '$totalEntries',
                icon: Icons.book_outlined,
              ),
              const SizedBox(width: 8),
              _StatChip(
                label: 'Avg per day',
                value: avgPerDay.toStringAsFixed(1),
                icon: Icons.bar_chart_outlined,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (mostCommonMood != null)
            _StatChip(
              label: 'Most common mood',
              value: kMoodLabel[mostCommonMood] ?? mostCommonMood.name,
              icon: Icons.sentiment_satisfied_alt_outlined,
            ),
        ],
      ),
    );
  }
}

class _MoodGraph extends StatelessWidget {
  const _MoodGraph({required this.counts});

  final Map<Mood, int> counts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (counts.isEmpty) {
      return Text(
        'Mood graph will appear once you start writing this month.',
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.inkMuted,
        ),
      );
    }

    final moodsInData = Mood.values.where((m) => counts[m] != null).toList();
    final maxCount =
        moodsInData.map((m) => counts[m] ?? 0).fold<int>(0, (a, b) => a > b ? a : b);

    return SizedBox(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final mood in moodsInData) ...[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final count = counts[mood] ?? 0;
                          final ratio = maxCount == 0
                              ? 0.0
                              : (count / maxCount).clamp(0.1, 1.0);
                          final barHeight = constraints.maxHeight * ratio;
                          return Container(
                            height: barHeight,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [AppColors.copper, AppColors.cocoa],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    kMoodEmoji[mood] ?? '',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${counts[mood] ?? 0}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          color: Colors.white.withValues(alpha: 0.45),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.inkMuted),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
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

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  static const routeName = '/timeline';

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  late DateTime _timelineMonth;
  late DateTime _selectedTimelineDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _timelineMonth = DateTime(now.year, now.month, 1);
    _selectedTimelineDate = DateTime(now.year, now.month, now.day);
  }

  Future<void> _editEntry(DiaryEntry entry) async {
    if (!mounted) return;
    await (_DashboardPageState()._showEditEntrySheet(entry));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Timeline'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StreamBuilder<List<DiaryEntry>>(
            stream: EntriesRepo().watchEntriesForMonth(
              year: _timelineMonth.year,
              month: _timelineMonth.month,
              limit: 400,
            ),
            builder: (context, snap) {
              final monthEntries = snap.data ?? const <DiaryEntry>[];
              return SingleChildScrollView(
                child: _MemoryTimelineSection(
                  month: _timelineMonth,
                  selectedDate: _selectedTimelineDate,
                  entries: monthEntries,
                  onPreviousMonth: () {
                    setState(() {
                      _timelineMonth = DateTime(
                        _timelineMonth.year,
                        _timelineMonth.month - 1,
                        1,
                      );
                    });
                  },
                  onNextMonth: () {
                    setState(() {
                      _timelineMonth = DateTime(
                        _timelineMonth.year,
                        _timelineMonth.month + 1,
                        1,
                      );
                    });
                  },
                  onSelectDate: (d) {
                    setState(() {
                      _selectedTimelineDate = d;
                    });
                  },
                  onEditEntry: (e) async {
                    // Reuse dashboard edit sheet behavior by pushing Search edit flow.
                    await showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Edit from timeline'),
                        content: const Text(
                            'For now, you can edit this entry from the main dashboard or search screen.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  static const routeName = '/analytics';

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StreamBuilder<List<DiaryEntry>>(
            stream: EntriesRepo().watchEntries(limit: 800),
            builder: (context, snap) {
              final entries = snap.data ?? const <DiaryEntry>[];
              return _FullAnalyticsView(entries: entries);
            },
          ),
        ),
      ),
    );
  }
}

enum AnalyticsRange { week, month, year }

class _FullAnalyticsView extends StatefulWidget {
  const _FullAnalyticsView({required this.entries});

  final List<DiaryEntry> entries;

  @override
  State<_FullAnalyticsView> createState() => _FullAnalyticsViewState();
}

class _FullAnalyticsViewState extends State<_FullAnalyticsView> {
  AnalyticsRange _range = AnalyticsRange.week;

  List<DiaryEntry> get _filtered {
    final now = DateTime.now();
    DateTime start;
    switch (_range) {
      case AnalyticsRange.week:
        start = now.subtract(const Duration(days: 6));
        break;
      case AnalyticsRange.month:
        start = DateTime(now.year, now.month, 1);
        break;
      case AnalyticsRange.year:
        start = DateTime(now.year, 1, 1);
        break;
    }
    return widget.entries.where((e) => e.createdAt.isAfter(start.subtract(const Duration(seconds: 1))) && e.createdAt.isBefore(now.add(const Duration(days: 1)))).toList();
  }

  int _wordCount(String text) {
    final t = text.trim();
    if (t.isEmpty) return 0;
    return t.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

  double _moodScore(Mood mood) {
    switch (mood) {
      case Mood.happy:
        return 8;
      case Mood.excited:
        return 9;
      case Mood.calm:
        return 7;
      case Mood.thoughtful:
        return 6;
      case Mood.tired:
        return 4;
      case Mood.sad:
        return 3;
      case Mood.anxious:
        return 2.5;
      case Mood.angry:
        return 2;
    }
  }

  int get _totalEntries => _filtered.length;

  int get _totalWords =>
      _filtered.fold<int>(0, (sum, e) => sum + _wordCount(e.text));

  double get _avgMood {
    if (_filtered.isEmpty) return 0;
    final total = _filtered.fold<double>(
      0,
      (sum, e) => sum + _moodScore(e.mood),
    );
    return total / _filtered.length;
  }

  int _currentStreakDays() {
    if (widget.entries.isEmpty) return 0;
    final days = widget.entries
        .map((e) => DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day))
        .toSet()
        .toList()
      ..sort();
    if (days.isEmpty) return 0;
    final daySet = days.toSet();
    int current = 0;
    var cursor = DateTime.now();
    while (daySet.contains(
      DateTime(cursor.year, cursor.month, cursor.day),
    )) {
      current += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return current;
  }

  Map<int, double> _moodTrendByWeekday() {
    final map = <int, (double sum, int count)>{};
    for (final e in _filtered) {
      final wd = e.createdAt.weekday; // 1=Mon
      final s = _moodScore(e.mood);
      final prev = map[wd] ?? (0, 0);
      map[wd] = (prev.$1 + s, prev.$2 + 1);
    }
    final result = <int, double>{};
    for (final entry in map.entries) {
      result[entry.key] = entry.value.$1 / entry.value.$2;
    }
    return result;
  }

  Map<int, int> _wordsByWeekday() {
    final map = <int, int>{};
    for (final e in _filtered) {
      final wd = e.createdAt.weekday;
      map[wd] = (map[wd] ?? 0) + _wordCount(e.text);
    }
    return map;
  }

  DateTime? _bestDayByMood() {
    if (_filtered.isEmpty) return null;
    final byDay = <DateTime, (double sum, int count)>{};
    for (final e in _filtered) {
      final day = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
      final s = _moodScore(e.mood);
      final prev = byDay[day] ?? (0, 0);
      byDay[day] = (prev.$1 + s, prev.$2 + 1);
    }
    DateTime? bestDay;
    double bestScore = -1;
    for (final entry in byDay.entries) {
      final avg = entry.value.$1 / entry.value.$2;
      if (avg > bestScore) {
        bestScore = avg;
        bestDay = entry.key;
      }
    }
    return bestDay;
  }

  String _peakWritingTimeLabel() {
    if (_filtered.isEmpty) return '—';
    final buckets = <String, int>{
      'Morning': 0, // 5–12
      'Afternoon': 0, // 12–17
      'Evening': 0, // 17–22
      'Night': 0, // 22–5
    };
    for (final e in _filtered) {
      final h = e.createdAt.hour;
      final w = _wordCount(e.text);
      if (h >= 5 && h < 12) {
        buckets['Morning'] = (buckets['Morning'] ?? 0) + w;
      } else if (h >= 12 && h < 17) {
        buckets['Afternoon'] = (buckets['Afternoon'] ?? 0) + w;
      } else if (h >= 17 && h < 22) {
        buckets['Evening'] = (buckets['Evening'] ?? 0) + w;
      } else {
        buckets['Night'] = (buckets['Night'] ?? 0) + w;
      }
    }
    String best = 'Morning';
    int bestVal = -1;
    buckets.forEach((k, v) {
      if (v > bestVal) {
        bestVal = v;
        best = k;
      }
    });
    return bestVal <= 0 ? '—' : best;
  }

  String _mostUsedTag() {
    final counts = <String, int>{};
    final tagReg = RegExp(r'#(\w+)');
    for (final e in _filtered) {
      for (final match in tagReg.allMatches(e.text)) {
        final tag = match.group(0)!; // includes #
        counts[tag] = (counts[tag] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) return '—';
    String best = '';
    int bestCount = 0;
    counts.forEach((k, v) {
      if (v > bestCount) {
        bestCount = v;
        best = k;
      }
    });
    return '$best   ·   $bestCount×';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final moodTrends = _moodTrendByWeekday();
    final wordsByDay = _wordsByWeekday();
    final avgMood = _avgMood;
    final streak = _currentStreakDays();
    final bestDay = _bestDayByMood();
    final totalWords = _totalWords;

    String bestDayLabel = '—';
    if (bestDay != null) {
      bestDayLabel =
          '${bestDay.day}/${bestDay.month}/${bestDay.year}';
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _rangeChip('Week', AnalyticsRange.week),
              const SizedBox(width: 8),
              _rangeChip('Month', AnalyticsRange.month),
              const SizedBox(width: 8),
              _rangeChip('Year', AnalyticsRange.year),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatChip(
                label: 'Total entries',
                value: '$_totalEntries',
                icon: Icons.book_outlined,
              ),
              const SizedBox(width: 8),
              _StatChip(
                label: 'Words written',
                value: _formatCompactNumber(totalWords),
                icon: Icons.edit_outlined,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _StatChip(
                label: 'Day streak',
                value: streak == 0 ? '–' : '$streak',
                icon: Icons.local_fire_department_outlined,
              ),
              const SizedBox(width: 8),
              _StatChip(
                label: 'Avg mood',
                value: avgMood == 0 ? '–' : avgMood.toStringAsFixed(1),
                icon: Icons.sentiment_satisfied_alt_outlined,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Mood trends',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          _weekdayBarChart(
            context: context,
            values: moodTrends,
            maxValue: 10,
            labelBuilder: (v) => v.toStringAsFixed(1),
          ),
          const SizedBox(height: 24),
          Text(
            'Writing activity',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _range == AnalyticsRange.week
                ? 'This week · ${_totalWords == 0 ? '0' : (_totalWords ~/ 7)} words/day'
                : 'Average per day over selected period',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.inkMuted,
            ),
          ),
          const SizedBox(height: 8),
          _weekdayBarChart(
            context: context,
            values: wordsByDay.map((k, v) => MapEntry(k, v.toDouble())),
            maxValue: wordsByDay.values.isEmpty
                ? 0
                : wordsByDay.values.reduce((a, b) => a > b ? a : b).toDouble(),
            labelBuilder: (v) => v.toStringAsFixed(0),
          ),
          const SizedBox(height: 24),
          Text(
            'Summary',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _summaryRow(
            context,
            icon: Icons.emoji_emotions_outlined,
            title: 'Best day',
            subtitle: bestDayLabel,
          ),
          const SizedBox(height: 8),
          _summaryRow(
            context,
            icon: Icons.access_time,
            title: 'Peak writing time',
            subtitle: _peakWritingTimeLabel(),
          ),
          const SizedBox(height: 8),
          _summaryRow(
            context,
            icon: Icons.tag_outlined,
            title: 'Most used tag',
            subtitle: _mostUsedTag(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _rangeChip(String label, AnalyticsRange range) {
    final selected = _range == range;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_range == range) return;
          setState(() => _range = range);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: selected
                ? AppColors.copper
                : Colors.white.withValues(alpha: 0.7),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _weekdayBarChart({
    required BuildContext context,
    required Map<int, double> values,
    required double maxValue,
    required String Function(double) labelBuilder,
  }) {
    final theme = Theme.of(context);
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (maxValue <= 0) {
      return Text(
        'Data will appear once you write in this period.',
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.inkMuted,
        ),
      );
    }
    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final weekday = i + 1; // 1=Mon
          final v = values[weekday] ?? 0;
          final ratio = (v / maxValue).clamp(0.08, 1.0);
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  v == 0 ? '' : labelBuilder(v),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 16,
                      height: 120 * ratio,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xFF2962FF),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  labels[i],
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _summaryRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        color: Colors.white.withValues(alpha: 0.45),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.inkMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCompactNumber(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toString();
  }
}



