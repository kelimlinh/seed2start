import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../gamification/data/gamification_service.dart';

class JourneyProgress {
  const JourneyProgress({
    required this.completedActivityIds,
    this.updatedAt,
  });

  final Set<String> completedActivityIds;
  final DateTime? updatedAt;

  int completedCount(Iterable<String> activityIds) {
    return activityIds.where(completedActivityIds.contains).length;
  }

  factory JourneyProgress.empty() => const JourneyProgress(
        completedActivityIds: <String>{},
      );

  factory JourneyProgress.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final rawIds = data?['completedActivityIds'];
    final timestamp = data?['updatedAt'];

    return JourneyProgress(
      completedActivityIds:
          rawIds is List ? rawIds.whereType<String>().toSet() : <String>{},
      updatedAt: timestamp is Timestamp ? timestamp.toDate() : null,
    );
  }
}

class JourneyService {
  JourneyService({
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

  User? get currentUser => _auth.currentUser;

  DocumentReference<Map<String, dynamic>>? get _progressDocument {
    final user = currentUser;
    if (user == null) return null;

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('journeyProgress')
        .doc('main');
  }

  Stream<JourneyProgress> watchProgress() {
    final document = _progressDocument;
    if (document == null) {
      return Stream<JourneyProgress>.value(JourneyProgress.empty());
    }

    return document.snapshots().map((snapshot) {
      if (!snapshot.exists) return JourneyProgress.empty();
      return JourneyProgress.fromDocument(snapshot);
    });
  }

  Future<void> setActivityCompleted({
    required String activityId,
    required bool completed,
  }) async {
    final document = _progressDocument;
    if (document == null) {
      throw StateError('User must be signed in to update journey progress.');
    }

    await document.set(
      <String, dynamic>{
        'completedActivityIds': completed
            ? FieldValue.arrayUnion(<String>[activityId])
            : FieldValue.arrayRemove(<String>[activityId]),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    if (completed) {
      await _gamificationService.awardJourneyActivity(activityId);
    }
  }
}
