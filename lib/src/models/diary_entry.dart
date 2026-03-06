enum Mood {
  happy,
  sad,
  angry,
  anxious,
  calm,
  thoughtful,
  tired,
  excited,
}

class DiaryEntry {
  DiaryEntry({
    required this.id,
    required this.createdAt,
    required this.mood,
    required this.text,
    required this.isPublic,
  });

  final String id;
  final DateTime createdAt;
  final Mood mood;
  final String text;
  final bool isPublic;

  static DiaryEntry fromFirestore(String id, Map<String, dynamic> data) {
    final moodStr = (data['mood'] ?? 'happy').toString();
    final mood = Mood.values.firstWhere(
      (m) => m.name == moodStr,
      orElse: () => Mood.happy,
    );
    final createdAt = data['createdAt'] ?? data['createdAtServer'];
    DateTime created;
    try {
      created = (createdAt as dynamic).toDate() as DateTime;
    } catch (_) {
      created = DateTime.now();
    }

    return DiaryEntry(
      id: id,
      createdAt: created,
      mood: mood,
      text: (data['text'] ?? '').toString(),
      isPublic: (data['isPublic'] ?? true) as bool,
    );
  }
}

