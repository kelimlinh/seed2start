import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mam_illustration.dart';
import '../data/workbook_models.dart';
import '../data/workbook_service.dart';
import 'workbook_resource_section.dart';

class WorkbookLessonPage extends StatelessWidget {
  const WorkbookLessonPage({
    super.key,
    required this.lessonId,
    this.service,
  });

  final String lessonId;
  final WorkbookService? service;

  @override
  Widget build(BuildContext context) {
    final lesson = WorkbookCatalog.byId(lessonId);
    final strings = AppLocalizations.of(context);

    if (lesson == null) {
      return Scaffold(
        appBar: AppBar(title: Text(strings.workbook)),
        body: Center(child: Text(strings.workbookLessonNotFound)),
      );
    }

    final chapter = WorkbookCatalog.chapterById(lesson.chapterId);
    final workbookService = service ?? WorkbookService();
    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(strings.workbook)),
      body: SafeArea(
        child: StreamBuilder<bool>(
          stream: workbookService.watchLessonCompleted(lesson.id),
          builder: (context, snapshot) {
            final completed = snapshot.data ?? false;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LessonHero(
                        lesson: lesson,
                        chapter: chapter,
                        languageCode: languageCode,
                      ),
                      if (lesson.psycapDimensions.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final dimension in lesson.psycapDimensions)
                              _DimensionChip(dimension: dimension),
                          ],
                        ),
                      ],
                      const SizedBox(height: 22),
                      _MamCompanionCard(
                        lesson: lesson,
                        languageCode: languageCode,
                      ),
                      const SizedBox(height: 24),
                      WorkbookResourceSection(
                        lesson: lesson,
                        workbookService: workbookService,
                      ),
                      const SizedBox(height: 20),
                      _ReturnToWorkbookCard(strings: strings),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => workbookService.setLessonCompleted(
                            lessonId: lesson.id,
                            completed: !completed,
                          ),
                          icon: Icon(
                            completed
                                ? Icons.undo_rounded
                                : Icons.check_circle_outline_rounded,
                          ),
                          label: Text(
                            completed
                                ? strings.workbookMarkIncomplete
                                : strings.workbookMarkComplete,
                          ),
                        ),
                      ),
                      if (snapshot.hasError) ...[
                        const SizedBox(height: 10),
                        Text(
                          strings.workbookLoadError,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
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

class _LessonHero extends StatelessWidget {
  const _LessonHero({
    required this.lesson,
    required this.chapter,
    required this.languageCode,
  });

  final WorkbookLesson lesson;
  final WorkbookChapter? chapter;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.sageSoft, AppTheme.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.outline),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 600;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (chapter != null)
                Text(
                  '${strings.workbookChapterNumber(chapter!.number)} · ${chapter!.title.resolve(languageCode)}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppTheme.leafDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              const SizedBox(height: 6),
              Text(
                strings.workbookLessonNumber(lesson.number),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.inkMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                lesson.title.resolve(languageCode),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppTheme.ink,
                  height: 1.18,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                lesson.objective.resolve(languageCode),
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.45,
                  color: AppTheme.inkMuted,
                ),
              ),
            ],
          );

          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: copy),
                const SizedBox(width: 22),
                MamIllustration(
                  pose: _lessonHeroPose(lesson.id),
                  size: 120,
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: copy),
              const SizedBox(width: 10),
              MamIllustration(
                pose: _lessonHeroPose(lesson.id),
                size: 74,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MamCompanionCard extends StatelessWidget {
  const _MamCompanionCard({
    required this.lesson,
    required this.languageCode,
  });

  final WorkbookLesson lesson;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.sand,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const MamIllustration(
                pose: MamPose.guiding,
                size: 58,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  strings.workbookDigitalCompanion,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            lesson.intro.resolve(languageCode),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.inkMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (lesson.linkedRoute != null)
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed(
                    lesson.linkedRoute!,
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(strings.workbookOpenLinkedActivity(lesson.id)),
                ),
              FilledButton.tonalIcon(
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.ai),
                icon: const Icon(Icons.eco_outlined),
                label: Text(strings.workbookAskMam),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReturnToWorkbookCard extends StatelessWidget {
  const _ReturnToWorkbookCard({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.blush,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              color: AppTheme.earth,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.workbookReturnToBook,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  strings.workbookReturnToBookBody,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.inkMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

MamPose _lessonHeroPose(String lessonId) {
  return switch (lessonId) {
    'lesson_01' => MamPose.selfDiscovery,
    'lesson_02' => MamPose.futureSeed,
    'lesson_03' => MamPose.fourResources,
    'lesson_04' => MamPose.planning,
    'lesson_05' => MamPose.confident,
    'lesson_06' => MamPose.keepGoing,
    'lesson_07' => MamPose.optimisticView,
    'lesson_08' => MamPose.connectingResources,
    'lesson_09' => MamPose.idea,
    'lesson_10' => MamPose.creativePaths,
    'lesson_11' => MamPose.problemSolving,
    'lesson_12' => MamPose.planning,
    'lesson_13' => MamPose.prototyping,
    'lesson_14' => MamPose.creatingValue,
    _ => MamPose.book,
  };
}

class _DimensionChip extends StatelessWidget {
  const _DimensionChip({required this.dimension});

  final PsycapDimension dimension;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    final label = switch (dimension) {
      PsycapDimension.hope => strings.hope,
      PsycapDimension.selfEfficacy => strings.selfEfficacy,
      PsycapDimension.resilience => strings.resilience,
      PsycapDimension.optimism => strings.optimism,
    };

    return Chip(
      avatar: const Icon(Icons.eco_outlined, size: 17),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}
