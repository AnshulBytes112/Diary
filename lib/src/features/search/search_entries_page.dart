import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/diary_entry.dart';
import '../../firebase/entries_repo.dart';
import '../../theme/app_colors.dart';
import '../auth/sign_in_page.dart';

const kMoodEmoji = <Mood, String>{
  Mood.happy: '😊',
  Mood.sad: '😟',
  Mood.angry: '😡',
  Mood.anxious: '😰',
  Mood.calm: '😌',
  Mood.thoughtful: '🤔',
  Mood.tired: '😴',
  Mood.excited: '🥳',
};

const kMoodLabel = <Mood, String>{
  Mood.happy: 'Happy',
  Mood.sad: 'Sad',
  Mood.angry: 'Angry',
  Mood.anxious: 'Anxious',
  Mood.calm: 'Calm',
  Mood.thoughtful: 'Thoughtful',
  Mood.tired: 'Tired',
  Mood.excited: 'Excited',
};

const kMonthsShort = <int, String>{
  1: 'Jan',
  2: 'Feb',
  3: 'Mar',
  4: 'Apr',
  5: 'May',
  6: 'Jun',
  7: 'Jul',
  8: 'Aug',
  9: 'Sep',
  10: 'Oct',
  11: 'Nov',
  12: 'Dec',
};

String formatShortDate(DateTime d) => '${kMonthsShort[d.month]} ${d.day}, ${d.year}';

class SearchEntriesPage extends StatefulWidget {
  const SearchEntriesPage({super.key});

  static const routeName = '/search';

  @override
  State<SearchEntriesPage> createState() => _SearchEntriesPageState();
}

class _SearchEntriesPageState extends State<SearchEntriesPage> {
  final _yearController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  Mood _selectedMood = Mood.happy;

  @override
  void initState() {
    super.initState();
    _yearController.text = _selectedYear.toString();
    _yearController.addListener(() {
      final v = int.tryParse(_yearController.text.trim());
      if (v == null) return;
      if (v < 1970 || v > 2100) return;
      if (v == _selectedYear) return;
      setState(() => _selectedYear = v);
    });
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1970, 1, 1),
      lastDate: DateTime(2100, 12, 31),
    );
    if (picked == null) return;
    setState(() => _selectedDate = picked);
  }

  Future<void> _showEntryDetails(DiaryEntry entry) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${kMoodEmoji[entry.mood]}  ${formatShortDate(entry.createdAt)}'),
        content: Text(entry.text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
                    'Edit entry (${formatShortDate(entry.createdAt)})',
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
                            DropdownMenuItem(
                                value: false, child: Text('Private')),
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Search'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Date', icon: Icon(Icons.event_outlined)),
              Tab(text: 'Month', icon: Icon(Icons.calendar_month_outlined)),
              Tab(text: 'Mood', icon: Icon(Icons.emoji_emotions_outlined)),
            ],
          ),
        ),
        body: user == null
            ? Center(
                child: FilledButton(
                  onPressed: () => Navigator.of(context)
                      .pushReplacementNamed(SignInPage.routeName),
                  child: const Text('Sign in to search entries'),
                ),
              )
            : TabBarView(
                children: [
                  _buildDateTab(),
                  _buildMonthTab(),
                  _buildMoodTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildDateTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.event_outlined),
                  label: Text('Selected: ${formatShortDate(_selectedDate)}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<List<DiaryEntry>>(
              stream: EntriesRepo().watchEntriesForDate(_selectedDate, limit: 50),
              builder: (context, snap) {
                final entries = snap.data ?? const <DiaryEntry>[];
                if (entries.isEmpty) {
                  return Center(
                    child: Text(
                      'No notes for this date.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.inkMuted),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _EntryTile(
                    entry: entries[i],
                    onTap: _showEntryDetails,
                    trailing: IconButton(
                      tooltip: 'Edit',
                      onPressed: () => _showEditEntrySheet(entries[i]),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _selectedMonth,
                  items: List.generate(
                    12,
                    (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text(kMonthsShort[i + 1]!),
                    ),
                  ),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _selectedMonth = v);
                  },
                  decoration: const InputDecoration(labelText: 'Month'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _yearController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Year',
                    hintText: 'e.g. 2026',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<List<DiaryEntry>>(
              stream: EntriesRepo().watchEntriesForMonth(
                year: _selectedYear,
                month: _selectedMonth,
                limit: 400,
              ),
              builder: (context, snap) {
                final entries = snap.data ?? const <DiaryEntry>[];
                if (entries.isEmpty) {
                  return Center(
                    child: Text(
                      'No notes for ${kMonthsShort[_selectedMonth]} $_selectedYear.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.inkMuted),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _EntryTile(
                    entry: entries[i],
                    onTap: _showEntryDetails,
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: AppColors.inkMuted),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<Mood>(
            value: _selectedMood,
            items: Mood.values
                .map(
                  (m) => DropdownMenuItem(
                    value: m,
                    child: Text('${kMoodEmoji[m]}  ${kMoodLabel[m]}'),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v == null) return;
              setState(() => _selectedMood = v);
            },
            decoration: const InputDecoration(
              labelText: 'Mood',
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<List<DiaryEntry>>(
              stream: EntriesRepo().watchEntriesByMood(
                mood: _selectedMood,
                limit: 200,
              ),
              builder: (context, snap) {
                final entries = snap.data ?? const <DiaryEntry>[];
                if (entries.isEmpty) {
                  return Center(
                    child: Text(
                      'No notes with this mood.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.inkMuted),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _EntryTile(
                    entry: entries[i],
                    onTap: _showEntryDetails,
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: AppColors.inkMuted),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.entry,
    required this.onTap,
    this.trailing,
  });

  final DiaryEntry entry;
  final ValueChanged<DiaryEntry> onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final snippet = entry.text.replaceAll('\n', ' ').trim();
    final short = snippet.length > 120 ? '${snippet.substring(0, 120)}…' : snippet;

    return InkWell(
      onTap: () => onTap(entry),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
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
                Text(kMoodEmoji[entry.mood]!, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Text(
                  formatShortDate(entry.createdAt),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const Spacer(),
                Icon(
                  entry.isPublic ? Icons.lock_open_rounded : Icons.lock_rounded,
                  size: 16,
                  color: AppColors.inkMuted,
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 4),
                  trailing!,
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              short,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.inkMuted,
                    height: 1.35,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

