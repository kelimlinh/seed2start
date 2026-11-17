import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../data/gamification_service.dart';

class GamificationPage extends StatelessWidget {
  const GamificationPage({
    super.key,
    this.service,
  });

  final GamificationService? service;

  @override
  Widget build(BuildContext context) {
    final gamificationService = service ?? GamificationService();
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(strings.progressSpace)),
      body: SafeArea(
        child: StreamBuilder<GamificationState>(
          stream: gamificationService.watchState(),
          builder: (context, snapshot) {
            final state = snapshot.data ?? GamificationState.empty();

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.progressPageSubtitle,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 22),
                      _LevelCard(state: state, strings: strings),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.local_fire_department_outlined,
                              value: '${state.streak}',
                              label: strings.currentStreak,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.emoji_events_outlined,
                              value: '${state.badgeIds.length}',
                              label: strings.badgesEarned,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Text(
                        strings.yourBadges,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _BadgesSection(state: state, strings: strings),
                      const SizedBox(height: 28),
                      Text(
                        strings.howXpWorks,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _RewardGuide(strings: strings),
                      if (snapshot.hasError) ...[
                        const SizedBox(height: 14),
                        Text(
                          strings.gamificationLoadError,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.state,
    required this.strings,
  });

  final GamificationState state;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  '${state.level}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.levelNumber(state.level),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      strings.totalXp(state.xp),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: state.levelProgress,
              minHeight: 10,
              backgroundColor: colors.surface.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.xpToNextLevel(100 - state.xpIntoLevel),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.primary),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgesSection extends StatelessWidget {
  const _BadgesSection({
    required this.state,
    required this.strings,
  });

  final GamificationState state;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final badges = <_BadgeData>[
      _BadgeData(
        id: GamificationBadgeId.firstStep,
        icon: Icons.directions_walk,
        title: strings.badgeFirstStep,
        body: strings.badgeFirstStepBody,
      ),
      _BadgeData(
        id: GamificationBadgeId.levelTwo,
        icon: Icons.eco_outlined,
        title: strings.badgeLevelTwo,
        body: strings.badgeLevelTwoBody,
      ),
      _BadgeData(
        id: GamificationBadgeId.levelFour,
        icon: Icons.park_outlined,
        title: strings.badgeLevelFour,
        body: strings.badgeLevelFourBody,
      ),
      _BadgeData(
        id: GamificationBadgeId.streakThree,
        icon: Icons.local_fire_department_outlined,
        title: strings.badgeStreakThree,
        body: strings.badgeStreakThreeBody,
      ),
      _BadgeData(
        id: GamificationBadgeId.streakSeven,
        icon: Icons.auto_awesome_outlined,
        title: strings.badgeStreakSeven,
        body: strings.badgeStreakSevenBody,
      ),
    ];

    return Column(
      children: [
        for (var index = 0; index < badges.length; index++) ...[
          _BadgeTile(
            badge: badges[index],
            earned: state.badgeIds.contains(badges[index].id),
            earnedLabel: strings.earned,
            lockedLabel: strings.notYet,
          ),
          if (index != badges.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _BadgeData {
  const _BadgeData({
    required this.id,
    required this.icon,
    required this.title,
    required this.body,
  });

  final String id;
  final IconData icon;
  final String title;
  final String body;
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({
    required this.badge,
    required this.earned,
    required this.earnedLabel,
    required this.lockedLabel,
  });

  final _BadgeData badge;
  final bool earned;
  final String earnedLabel;
  final String lockedLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: earned ? colors.secondaryContainer : colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: earned ? colors.secondaryContainer : colors.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: earned
                  ? colors.surface.withValues(alpha: 0.72)
                  : colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              badge.icon,
              color: earned ? colors.primary : colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badge.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  badge.body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            earned ? earnedLabel : lockedLabel,
            style: theme.textTheme.labelMedium?.copyWith(
              color: earned ? colors.primary : colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardGuide extends StatelessWidget {
  const _RewardGuide({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final rows = <(IconData, String, int)>[
      (Icons.mood_outlined, strings.rewardMood, GamificationReward.moodCheckIn),
      (
        Icons.edit_note_rounded,
        strings.rewardReflection,
        GamificationReward.dailyReflection
      ),
      (
        Icons.route_outlined,
        strings.rewardJourney,
        GamificationReward.journeyActivity
      ),
      (
        Icons.menu_book_outlined,
        strings.rewardWorkbook,
        GamificationReward.workbookLesson
      ),
      (
        Icons.flag_outlined,
        strings.rewardGoal,
        GamificationReward.goalCompleted
      ),
    ];

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(rows[index].$1, color: colors.primary),
                  const SizedBox(width: 12),
                  Expanded(child: Text(rows[index].$2)),
                  Text(
                    '+${rows[index].$3} XP',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
            if (index != rows.length - 1)
              Divider(height: 1, color: colors.outlineVariant),
          ],
        ],
      ),
    );
  }
}
