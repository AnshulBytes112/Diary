import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/diary_entry.dart';
import 'firestore_paths.dart';

class EntriesRepo {
  EntriesRepo({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _uid {
    final u = _auth.currentUser;
    if (u == null) throw StateError('Not signed in');
    return u.uid;
  }

  CollectionReference<Map<String, dynamic>> _entriesCol(String uid) =>
      _firestore.collection(FirestorePaths.userEntriesCollection(uid));

  Query<Map<String, dynamic>> _entriesQuery(String uid) =>
      _entriesCol(uid).orderBy('createdAt', descending: true);

  Future<void> addEntry({
    required Mood mood,
    required String text,
    required bool isPublic,
  }) async {
    final uid = _uid;
    await _entriesCol(uid).add({
      'mood': mood.name,
      'text': text,
      'isPublic': isPublic,
      // Use a client timestamp for stable ordering while serverTimestamp resolves.
      'createdAt': Timestamp.now(),
      'createdAtServer': FieldValue.serverTimestamp(),
      'updatedAt': Timestamp.now(),
      'updatedAtServer': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateEntry({
    required String entryId,
    required Mood mood,
    required String text,
    required bool isPublic,
  }) async {
    final uid = _uid;
    await _entriesCol(uid).doc(entryId).update({
      'mood': mood.name,
      'text': text,
      'isPublic': isPublic,
      'updatedAt': Timestamp.now(),
      'updatedAtServer': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<DiaryEntry>> watchEntries({int limit = 50}) {
    final uid = _uid;
    return _entriesQuery(uid).limit(limit).snapshots().map(
          (snap) => snap.docs
              .map((d) => DiaryEntry.fromFirestore(d.id, d.data()))
              .toList(),
        );
  }

  Stream<List<DiaryEntry>> watchEntriesForDate(DateTime date, {int limit = 50}) {
    final uid = _uid;
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return _entriesCol(uid)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThan: Timestamp.fromDate(end))
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => DiaryEntry.fromFirestore(d.id, d.data()))
              .toList(),
        );
  }

  Stream<List<DiaryEntry>> watchEntriesForMonth({
    required int year,
    required int month,
    int limit = 400,
  }) {
    final uid = _uid;
    final start = DateTime(year, month, 1);
    final end = (month == 12) ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);

    return _entriesCol(uid)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThan: Timestamp.fromDate(end))
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => DiaryEntry.fromFirestore(d.id, d.data()))
              .toList(),
        );
  }

  Stream<List<DiaryEntry>> watchEntriesByMood({
    required Mood mood,
    int limit = 200,
  }) {
    final uid = _uid;
    return _entriesCol(uid)
        .where('mood', isEqualTo: mood.name)
        .limit(limit)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => DiaryEntry.fromFirestore(d.id, d.data()))
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        );
  }
}

