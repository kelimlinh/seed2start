import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../gamification/data/gamification_service.dart';

enum MoodLevel {
  veryLow,
  low,
  okay,
  good,
  great,
}

class DailyMood {
  const DailyMood({
    required this.id,
    required this.mood,
    this.updatedAt,
  });

  final String id;
  final MoodLevel mood;
  final DateTime? updatedAt;

  factory DailyMood.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    final rawMood = data['mood'] as String?;

    return DailyMood(
      id: document.id,
      mood: MoodLevel.values.firstWhere(
        (value) => value.name == rawMood,
        orElse: () => MoodLevel.okay,
      ),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}

class ReflectionEntry {
  const ReflectionEntry({
    required this.id,
    required this.content,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String content;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ReflectionEntry.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    return ReflectionEntry(
      id: document.id,
      content: (data['content'] as String? ?? '').trim(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}

class ReflectionService {
  ReflectionService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GamificationService? gamificationService,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance {
    _gamificationService = gamificationService ??
        GamificationService(auth: _auth, firestore: _firestore);
  }

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  late final GamificationService _gamificationService;

  User _requireUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No authenticated user.');
    }
    return user;
  }

  CollectionReference<Map<String, dynamic>> _moodsFor(String uid) =>
      _firestore.collection('users').doc(uid).collection('moods');

  CollectionReference<Map<String, dynamic>> _reflectionsFor(String uid) =>
      _firestore.collection('users').doc(uid).collection('reflections');

  String _dateKey(DateTime date) {
    final local = date.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  Stream<DailyMood?> watchTodayMood() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream<DailyMood?>.value(null);
    }

    return _moodsFor(user.uid).doc(_dateKey(DateTime.now())).snapshots().map(
        (snapshot) =>
            snapshot.exists ? DailyMood.fromDocument(snapshot) : null);
  }

  Future<void> saveTodayMood(MoodLevel mood) async {
    final user = _requireUser();
    final now = DateTime.now();
    await _moodsFor(user.uid).doc(_dateKey(now)).set(
      <String, dynamic>{
        'mood': mood.name,
        'dateKey': _dateKey(now),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await _gamificationService.awardMoodCheckIn(now);
  }

  Stream<List<ReflectionEntry>> watchReflections() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream<List<ReflectionEntry>>.value(const <ReflectionEntry>[]);
    }

    return _reflectionsFor(user.uid).snapshots().map((snapshot) {
      final entries = snapshot.docs.map(ReflectionEntry.fromDocument).toList();
      entries.sort((a, b) {
        final aDate = a.updatedAt ?? a.createdAt;
        final bDate = b.updatedAt ?? b.createdAt;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });
      return entries;
    });
  }

  Future<void> createReflection(String content) async {
    final user = _requireUser();
    final cleanContent = content.trim();
    if (cleanContent.isEmpty) {
      throw ArgumentError.value(content, 'content');
    }

    final now = DateTime.now();
    await _reflectionsFor(user.uid).add(<String, dynamic>{
      'content': cleanContent,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _gamificationService.awardDailyReflection(now);
  }

  Future<void> createReflectionFromResource({
    required String content,
    required String chapterId,
    required String lessonId,
    required String resourceId,
    List<String> psycapDimensions = const <String>[],
  }) async {
    final user = _requireUser();
    final cleanContent = content.trim();
    if (cleanContent.isEmpty) {
      throw ArgumentError.value(content, 'content');
    }

    final now = DateTime.now();
    await _reflectionsFor(user.uid).add(<String, dynamic>{
      'content': cleanContent,
      'source': 'resource',
      'chapterId': chapterId,
      'lessonId': lessonId,
      'resourceId': resourceId,
      'psycapDimensions': psycapDimensions,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _gamificationService.awardDailyReflection(now);
  }

  Future<void> updateReflection({
    required String reflectionId,
    required String content,
  }) async {
    final user = _requireUser();
    final cleanContent = content.trim();
    if (cleanContent.isEmpty) {
      throw ArgumentError.value(content, 'content');
    }

    await _reflectionsFor(user.uid).doc(reflectionId).update(<String, dynamic>{
      'content': cleanContent,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteReflection(String reflectionId) async {
    final user = _requireUser();
    await _reflectionsFor(user.uid).doc(reflectionId).delete();
  }
}
