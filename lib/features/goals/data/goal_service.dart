import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../gamification/data/gamification_service.dart';

enum GoalTimeframe {
  shortTerm,
  longTerm,
}

class GoalItem {
  const GoalItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timeframe,
    required this.progress,
    required this.completed,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final GoalTimeframe timeframe;
  final int progress;
  final bool completed;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory GoalItem.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final rawProgress = data['progress'];
    final progress =
        rawProgress is num ? rawProgress.round().clamp(0, 100).toInt() : 0;

    return GoalItem(
      id: document.id,
      title: (data['title'] as String? ?? '').trim(),
      description: (data['description'] as String? ?? '').trim(),
      timeframe: data['timeframe'] == 'longTerm'
          ? GoalTimeframe.longTerm
          : GoalTimeframe.shortTerm,
      progress: progress,
      completed: data['completed'] == true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}

class GoalService {
  GoalService({
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

  CollectionReference<Map<String, dynamic>> _goalsFor(String uid) =>
      _firestore.collection('users').doc(uid).collection('goals');

  Stream<List<GoalItem>> watchGoals() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream<List<GoalItem>>.value(const []);
    }

    return _goalsFor(user.uid).snapshots().map((snapshot) {
      final goals = snapshot.docs.map(GoalItem.fromDocument).toList();
      goals.sort((a, b) {
        if (a.completed != b.completed) {
          return a.completed ? 1 : -1;
        }
        final aDate = a.updatedAt ?? a.createdAt;
        final bDate = b.updatedAt ?? b.createdAt;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });
      return goals;
    });
  }

  Future<void> createGoal({
    required String title,
    required String description,
    required GoalTimeframe timeframe,
  }) async {
    final user = _requireUser();
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) {
      throw ArgumentError.value(title, 'title');
    }

    await _goalsFor(user.uid).add({
      'title': cleanTitle,
      'description': description.trim(),
      'timeframe': timeframe.name,
      'progress': 0,
      'completed': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'completedAt': null,
    });
  }

  Future<void> updateGoal({
    required String goalId,
    required String title,
    required String description,
    required GoalTimeframe timeframe,
    required int progress,
  }) async {
    final user = _requireUser();
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) {
      throw ArgumentError.value(title, 'title');
    }

    final normalizedProgress = progress.clamp(0, 100).toInt();
    final completed = normalizedProgress == 100;

    await _goalsFor(user.uid).doc(goalId).update({
      'title': cleanTitle,
      'description': description.trim(),
      'timeframe': timeframe.name,
      'progress': normalizedProgress,
      'completed': completed,
      'updatedAt': FieldValue.serverTimestamp(),
      'completedAt': completed ? FieldValue.serverTimestamp() : null,
    });

    if (completed) {
      await _gamificationService.awardGoalCompleted(goalId);
    }
  }

  Future<void> completeGoal(String goalId) async {
    final user = _requireUser();

    await _goalsFor(user.uid).doc(goalId).update({
      'completed': true,
      'progress': 100,
      'updatedAt': FieldValue.serverTimestamp(),
      'completedAt': FieldValue.serverTimestamp(),
    });

    await _gamificationService.awardGoalCompleted(goalId);
  }

  Future<void> deleteGoal(String goalId) async {
    final user = _requireUser();
    await _goalsFor(user.uid).doc(goalId).delete();
  }
}
