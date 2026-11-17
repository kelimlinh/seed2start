import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract final class GamificationReward {
  static const moodCheckIn = 5;
  static const dailyReflection = 10;
  static const journeyActivity = 15;
  static const workbookLesson = 20;
  static const goalCompleted = 30;
}

abstract final class GamificationBadgeId {
  static const firstStep = 'first_step';
  static const levelTwo = 'level_two';
  static const levelFour = 'level_four';
  static const streakThree = 'streak_three';
  static const streakSeven = 'streak_seven';
}

class GamificationState {
  const GamificationState({
    required this.xp,
    required this.level,
    required this.streak,
    required this.longestStreak,
    required this.badgeIds,
    this.lastActiveDate,
    this.updatedAt,
  });

  final int xp;
  final int level;
  final int streak;
  final int longestStreak;
  final Set<String> badgeIds;
  final String? lastActiveDate;
  final DateTime? updatedAt;

  int get xpIntoLevel => xp % 100;
  int get xpForNextLevel => 100;
  double get levelProgress => xpIntoLevel / xpForNextLevel;

  factory GamificationState.empty() => const GamificationState(
        xp: 0,
        level: 1,
        streak: 0,
        longestStreak: 0,
        badgeIds: <String>{},
      );

  factory GamificationState.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    if (data == null) return GamificationState.empty();

    int readInt(String key, int fallback) {
      final value = data[key];
      return value is num ? value.round() : fallback;
    }

    final xp = math.max(0, readInt('xp', 0));
    final storedLevel = math.max(1, readInt('level', 1));
    final derivedLevel = (xp ~/ 100) + 1;

    return GamificationState(
      xp: xp,
      level: math.max(storedLevel, derivedLevel),
      streak: math.max(0, readInt('streak', 0)),
      longestStreak: math.max(0, readInt('longestStreak', 0)),
      badgeIds: (data['badgeIds'] is List)
          ? (data['badgeIds'] as List).whereType<String>().toSet()
          : <String>{},
      lastActiveDate: data['lastActiveDate'] as String?,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}

class GamificationService {
  GamificationService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User _requireUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Gamification requires an authenticated user.');
    }
    return user;
  }

  DocumentReference<Map<String, dynamic>> _stateDocument(String uid) =>
      _firestore
          .collection('users')
          .doc(uid)
          .collection('gamification')
          .doc('state');

  CollectionReference<Map<String, dynamic>> _eventsCollection(String uid) =>
      _firestore.collection('users').doc(uid).collection('gamificationEvents');

  Stream<GamificationState> watchState() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream<GamificationState>.value(GamificationState.empty());
    }

    return _stateDocument(user.uid).snapshots().map(
          (snapshot) => snapshot.exists
              ? GamificationState.fromDocument(snapshot)
              : GamificationState.empty(),
        );
  }

  Future<void> awardGoalCompleted(String goalId) =>
      _awardSafely(() => _recordReward(
            eventId: 'goal_completed_$goalId',
            activityType: 'goalCompleted',
            xp: GamificationReward.goalCompleted,
          ));

  Future<void> awardJourneyActivity(String activityId) =>
      _awardSafely(() => _recordReward(
            eventId: 'journey_activity_$activityId',
            activityType: 'journeyActivity',
            xp: GamificationReward.journeyActivity,
          ));

  Future<void> awardWorkbookLesson(String lessonId) =>
      _awardSafely(() => _recordReward(
            eventId: 'workbook_lesson_$lessonId',
            activityType: 'workbookLesson',
            xp: GamificationReward.workbookLesson,
          ));

  Future<void> awardMoodCheckIn(DateTime date) =>
      _awardSafely(() => _recordReward(
            eventId: 'mood_${_dateKey(date)}',
            activityType: 'moodCheckIn',
            xp: GamificationReward.moodCheckIn,
            activityDate: date,
          ));

  Future<void> awardDailyReflection(DateTime date) =>
      _awardSafely(() => _recordReward(
            eventId: 'reflection_${_dateKey(date)}',
            activityType: 'dailyReflection',
            xp: GamificationReward.dailyReflection,
            activityDate: date,
          ));

  Future<void> _awardSafely(Future<bool> Function() action) async {
    try {
      await action();
    } catch (_) {
      // Gamification must never block the feature that produced the activity.
    }
  }

  Future<bool> _recordReward({
    required String eventId,
    required String activityType,
    required int xp,
    DateTime? activityDate,
  }) async {
    if (xp <= 0) return false;

    final user = _requireUser();
    final stateRef = _stateDocument(user.uid);
    final eventRef = _eventsCollection(user.uid).doc(eventId);
    final today = (activityDate ?? DateTime.now()).toLocal();
    final todayKey = _dateKey(today);

    return _firestore.runTransaction<bool>((transaction) async {
      final eventSnapshot = await transaction.get(eventRef);
      if (eventSnapshot.exists) return false;

      final stateSnapshot = await transaction.get(stateRef);
      final current = stateSnapshot.exists
          ? GamificationState.fromDocument(stateSnapshot)
          : GamificationState.empty();

      final nextXp = current.xp + xp;
      final nextLevel = (nextXp ~/ 100) + 1;
      final nextStreak = _nextStreak(
        current: current,
        today: today,
        todayKey: todayKey,
      );
      final nextLongestStreak = math.max(current.longestStreak, nextStreak);
      final badges = <String>{...current.badgeIds};

      badges.add(GamificationBadgeId.firstStep);
      if (nextLevel >= 2) badges.add(GamificationBadgeId.levelTwo);
      if (nextLevel >= 4) badges.add(GamificationBadgeId.levelFour);
      if (nextStreak >= 3) badges.add(GamificationBadgeId.streakThree);
      if (nextStreak >= 7) badges.add(GamificationBadgeId.streakSeven);

      transaction.set(
        eventRef,
        <String, dynamic>{
          'eventId': eventId,
          'activityType': activityType,
          'xp': xp,
          'dateKey': todayKey,
          'createdAt': FieldValue.serverTimestamp(),
        },
      );

      transaction.set(
        stateRef,
        <String, dynamic>{
          'xp': nextXp,
          'level': nextLevel,
          'streak': nextStreak,
          'longestStreak': nextLongestStreak,
          'lastActiveDate': todayKey,
          'badgeIds': badges.toList()..sort(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      return true;
    });
  }

  int _nextStreak({
    required GamificationState current,
    required DateTime today,
    required String todayKey,
  }) {
    if (current.lastActiveDate == todayKey) {
      return current.streak;
    }

    final yesterday = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: 1));
    if (current.lastActiveDate == _dateKey(yesterday)) {
      return math.max(1, current.streak) + 1;
    }

    return 1;
  }

  static String _dateKey(DateTime date) {
    final local = date.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }
}
