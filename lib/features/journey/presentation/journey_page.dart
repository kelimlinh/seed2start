import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/app_routes.dart';
import '../../workbook/data/workbook_models.dart';
import '../../workbook/data/workbook_service.dart';
import '../data/journey_service.dart';

class JourneyPage extends StatefulWidget {
  const JourneyPage({super.key});

  @override
  State<JourneyPage> createState() => _JourneyPageState();
}

class _JourneyPageState extends State<JourneyPage> {
  final JourneyService _journeyService = JourneyService();
  final WorkbookService _workbookService = WorkbookService();
  final Set<String> _updatingActivityIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final pillars = _buildPillars(strings);
    final languageCode = Localizations.localeOf(context).languageCode;

    return SafeArea(
      child: StreamBuilder<Set<String>>(
        stream: _workbookService.watchCompletedLessonIds(),
        builder: (context, workbookSnapshot) {
          final completedLessons = workbookSnapshot.data ?? <String>{};
          final currentLesson =
              WorkbookCatalog.firstIncomplete(completedLessons);

          return StreamBuilder<JourneyProgress>(
            stream: _journeyService.watchProgress(),
            builder: (context, journeySnapshot) {
              final progress = journeySnapshot.data ?? JourneyProgress.empty();

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.journeyTitle,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          strings.journeyPageSubtitle,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    height: 1.4,
                                  ),
                        ),
                        const SizedBox(height: 22),
                        _CurrentLessonCard(
                          lesson: currentLesson,
                          languageCode: languageCode,
                          completedCount: completedLessons.length,
                        ),
                        const SizedBox(height: 22),
                        Text(
                          strings.homeThreeChapters,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        for (var index = 0;
                            index < WorkbookCatalog.chapters.length;
                            index++) ...[
                          _ChapterProgressCard(
                            chapter: WorkbookCatalog.chapters[index],
                            completedLessonIds: completedLessons,
                            languageCode: languageCode,
                          ),
                          if (index != WorkbookCatalog.chapters.length - 1)
                            const SizedBox(height: 10),
                        ],
                        if (workbookSnapshot.hasError) ...[
                          const SizedBox(height: 12),
                          _InlineMessage(
                            icon: Icons.cloud_off_outlined,
                            message: strings.workbookLoadError,
                          ),
                        ],
                        const SizedBox(height: 28),
                        Text(
                          strings.heroTitle,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          strings.heroSubtitle,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                        const SizedBox(height: 14),
                        for (var index = 0;
                            index < pillars.length;
                            index++) ...[
                          _PillarCard(
                            pillar: pillars[index],
                            progress: progress,
                            updatingActivityIds: _updatingActivityIds,
                            onToggleActivity: _toggleActivity,
                            strings: strings,
                          ),
                          if (index != pillars.length - 1)
                            const SizedBox(height: 14),
                        ],
                        if (journeySnapshot.hasError) ...[
                          const SizedBox(height: 12),
                          _InlineMessage(
                            icon: Icons.cloud_off_outlined,
                            message: strings.journeyLoadError,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _toggleActivity(String activityId, bool completed) async {
    if (_updatingActivityIds.contains(activityId)) return;

    setState(() => _updatingActivityIds.add(activityId));
    try {
      await _journeyService.setActivityCompleted(
        activityId: activityId,
        completed: completed,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).somethingWrong)),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingActivityIds.remove(activityId));
      }
    }
  }

  List<_PillarData> _buildPillars(AppLocalizations strings) {
    return <_PillarData>[
      _PillarData(
        letter: 'H',
        title: strings.hope,
        subtitle: strings.hopeSubtitle,
        activities: <_ActivityData>[
          _ActivityData(
            id: 'hope_small_goal',
            title: strings.hopeActivityOneTitle,
            body: strings.hopeActivityOneBody,
          ),
          _ActivityData(
            id: 'hope_another_path',
            title: strings.hopeActivityTwoTitle,
            body: strings.hopeActivityTwoBody,
          ),
        ],
      ),
      _PillarData(
        letter: 'E',
        title: strings.selfEfficacy,
        subtitle: strings.selfEfficacySubtitle,
        activities: <_ActivityData>[
          _ActivityData(
            id: 'efficacy_evidence',
            title: strings.efficacyActivityOneTitle,
            body: strings.efficacyActivityOneBody,
          ),
          _ActivityData(
            id: 'efficacy_small_stretch',
            title: strings.efficacyActivityTwoTitle,
            body: strings.efficacyActivityTwoBody,
          ),
        ],
      ),
      _PillarData(
        letter: 'R',
        title: strings.resilience,
        subtitle: strings.resilienceSubtitle,
        activities: <_ActivityData>[
          _ActivityData(
            id: 'resilience_recovery_plan',
            title: strings.resilienceActivityOneTitle,
            body: strings.resilienceActivityOneBody,
          ),
          _ActivityData(
            id: 'resilience_try_again',
            title: strings.resilienceActivityTwoTitle,
            body: strings.resilienceActivityTwoBody,
          ),
        ],
      ),
      _PillarData(
        letter: 'O',
        title: strings.optimism,
        subtitle: strings.optimismSubtitle,
        activities: <_ActivityData>[
          _ActivityData(
            id: 'optimism_reframe',
            title: strings.optimismActivityOneTitle,
            body: strings.optimismActivityOneBody,
          ),
          _ActivityData(
            id: 'optimism_possibilities',
            title: strings.optimismActivityTwoTitle,
            body: strings.optimismActivityTwoBody,
          ),
        ],
      ),
    ];
  }
}

class _CurrentLessonCard extends StatelessWidget {
  const _CurrentLessonCard({
    required this.lesson,
    required this.languageCode,
    required this.completedCount,
  });

  final WorkbookLesson? lesson;
  final String languageCode;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
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
          Text(
            strings.homeContinueJourney,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colors.onPrimaryContainer,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          if (lesson != null) ...[
            Text(
              '${strings.workbookLessonNumber(lesson!.number)} · ${lesson!.shortTitle.resolve(languageCode)}',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colors.onPrimaryContainer,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              lesson!.objective.resolve(languageCode),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onPrimaryContainer,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.tonalIcon(
              onPressed: () => Navigator.of(context).pushNamed(
                AppRoutes.workbookLesson(lesson!.id),
              ),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(strings.continueJourney),
            ),
          ] else ...[
            Text(
              strings.homeJourneyComplete,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colors.onPrimaryContainer,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              strings.workbookProgressText(
                completedCount,
                WorkbookCatalog.lessons.length,
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onPrimaryContainer,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChapterProgressCard extends StatelessWidget {
  const _ChapterProgressCard({
    required this.chapter,
    required this.completedLessonIds,
    required this.languageCode,
  });

  final WorkbookChapter chapter;
  final Set<String> completedLessonIds;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final lessons = WorkbookCatalog.lessonsForChapter(chapter.id);
    final completed = WorkbookCatalog.completedCountForChapter(
      chapter.id,
      completedLessonIds,
    );
    final progress = lessons.isEmpty ? 0.0 : completed / lessons.length;

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.secondaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '${chapter.number}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onSecondaryContainer,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapter.title.resolve(languageCode),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 6,
                      value: progress,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    strings.workbookChapterProgressText(
                      completed,
                      lessons.length,
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
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

class _PillarCard extends StatelessWidget {
  const _PillarCard({
    required this.pillar,
    required this.progress,
    required this.updatingActivityIds,
    required this.onToggleActivity,
    required this.strings,
  });

  final _PillarData pillar;
  final JourneyProgress progress;
  final Set<String> updatingActivityIds;
  final Future<void> Function(String activityId, bool completed)
      onToggleActivity;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final completed = pillar.activities
        .where(
            (activity) => progress.completedActivityIds.contains(activity.id))
        .length;

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        leading: Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.secondaryContainer,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            pillar.letter,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colors.onSecondaryContainer,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        title: Text(
          pillar.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            pillar.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Text(
          '$completed/${pillar.activities.length}',
          style: theme.textTheme.labelLarge?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              strings.smallActivities,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          for (var index = 0; index < pillar.activities.length; index++) ...[
            _ActivityTile(
              activity: pillar.activities[index],
              completed: progress.completedActivityIds
                  .contains(pillar.activities[index].id),
              updating:
                  updatingActivityIds.contains(pillar.activities[index].id),
              onChanged: (value) => onToggleActivity(
                pillar.activities[index].id,
                value,
              ),
              strings: strings,
            ),
            if (index != pillar.activities.length - 1)
              const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.activity,
    required this.completed,
    required this.updating,
    required this.onChanged,
    required this.strings,
  });

  final _ActivityData activity;
  final bool completed;
  final bool updating;
  final ValueChanged<bool> onChanged;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          updating
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Tooltip(
                  message: completed
                      ? strings.markActivityIncomplete
                      : strings.markActivityComplete,
                  child: Checkbox(
                    value: completed,
                    onChanged: (value) {
                      if (value != null) onChanged(value);
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: colors.error),
        const SizedBox(width: 8),
        Expanded(child: Text(message)),
      ],
    );
  }
}

class _PillarData {
  const _PillarData({
    required this.letter,
    required this.title,
    required this.subtitle,
    required this.activities,
  });

  final String letter;
  final String title;
  final String subtitle;
  final List<_ActivityData> activities;
}

class _ActivityData {
  const _ActivityData({
    required this.id,
    required this.title,
    required this.body,
  });

  final String id;
  final String title;
  final String body;
}
