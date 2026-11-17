import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mam_illustration.dart';
import '../data/workbook_models.dart';
import '../data/workbook_service.dart';

class WorkbookPage extends StatelessWidget {
  const WorkbookPage({super.key, this.service});

  final WorkbookService? service;

  @override
  Widget build(BuildContext context) {
    final workbookService = service ?? WorkbookService();
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;

    return ColoredBox(
      color: const Color(0xFFF8F3EA),
      child: SafeArea(
        child: StreamBuilder<Set<String>>(
          stream: workbookService.watchCompletedLessonIds(),
          builder: (context, snapshot) {
            final completed = snapshot.data ?? <String>{};
            final total = WorkbookCatalog.lessons.length;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _WorkbookHero(
                        completed: completed.length,
                        total: total,
                      ),
                      const SizedBox(height: 22),
                      for (var index = 0;
                          index < WorkbookCatalog.chapters.length;
                          index++) ...[
                        _ChapterSection(
                          chapter: WorkbookCatalog.chapters[index],
                          completedLessonIds: completed,
                          languageCode: languageCode,
                        ),
                        if (index != WorkbookCatalog.chapters.length - 1)
                          const SizedBox(height: 16),
                      ],
                      if (snapshot.hasError)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            strings.workbookLoadError,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
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

class _WorkbookHero extends StatelessWidget {
  const _WorkbookHero({
    required this.completed,
    required this.total,
  });

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final progress = total == 0 ? 0.0 : completed / total;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 620;

        final copy = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE6E1D8)),
                  ),
                  child: const Icon(
                    Icons.route_rounded,
                    color: AppTheme.leafDark,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    strings.workbook,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.ink,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              strings.workbookPageSubtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.inkMuted,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              strings.workbookYourProgress,
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppTheme.leafDark,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: progress,
                backgroundColor: AppTheme.surface.withValues(alpha: 0.68),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              strings.workbookProgressText(completed, total),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.inkMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );

        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            wide ? 22 : 18,
            wide ? 20 : 18,
            wide ? 18 : 14,
            wide ? 20 : 18,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFF4F6F1),
                Color(0xFFFAF6EF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE3DACD)),
          ),
          child: wide
              ? Row(
                  children: [
                    Expanded(child: copy),
                    const SizedBox(width: 20),
                    const MamIllustration(
                      pose: MamPose.journeyMap,
                      size: 126,
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: copy),
                    const SizedBox(width: 10),
                    const MamIllustration(
                      pose: MamPose.journeyMap,
                      size: 82,
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _ChapterSection extends StatelessWidget {
  const _ChapterSection({
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
    final lessons = WorkbookCatalog.lessonsForChapter(chapter.id);
    final completed = WorkbookCatalog.completedCountForChapter(
      chapter.id,
      completedLessonIds,
    );
    final progress = lessons.isEmpty ? 0.0 : completed / lessons.length;

    final palette = _chapterPalette(chapter.number);

    final pose = switch (chapter.number) {
      1 => MamPose.futureSeed,
      2 => MamPose.fourResources,
      _ => MamPose.idea,
    };

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: palette.body,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: palette.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.018),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(17, 15, 14, 14),
            decoration: BoxDecoration(
              color: palette.header,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: palette.outline),
                  ),
                  child: Text(
                    '${chapter.number}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.leafDark,
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
                        strings.workbookChapterNumber(chapter.number),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppTheme.leafDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        chapter.title.resolve(languageCode),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppTheme.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        chapter.description.resolve(languageCode),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.inkMuted,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                MamIllustration(
                  pose: pose,
                  size: 72,
                ),
              ],
            ),
          ),
          Container(
            color: palette.body,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 7,
                          value: progress,
                          backgroundColor: palette.progressTrack,
                          color: palette.accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$completed/${lessons.length}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppTheme.leafDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                for (var index = 0; index < lessons.length; index++) ...[
                  _LessonCard(
                    lesson: lessons[index],
                    completed: completedLessonIds.contains(lessons[index].id),
                    languageCode: languageCode,
                    palette: palette,
                  ),
                  if (index != lessons.length - 1) const SizedBox(height: 9),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterPalette {
  const _ChapterPalette({
    required this.header,
    required this.body,
    required this.lessonCard,
    required this.completedCard,
    required this.accent,
    required this.progressTrack,
    required this.outline,
  });

  final Color header;
  final Color body;
  final Color lessonCard;
  final Color completedCard;
  final Color accent;
  final Color progressTrack;
  final Color outline;
}

_ChapterPalette _chapterPalette(int chapterNumber) {
  return switch (chapterNumber) {
    1 => const _ChapterPalette(
        header: Color(0xFFF7ECE8),
        body: Color(0xFFFCF6F2),
        lessonCard: Color(0xFFF8EFEB),
        completedCard: Color(0xFFF2E5DF),
        accent: Color(0xFFE9CFC6),
        progressTrack: Color(0xFFF4E6E1),
        outline: Color(0xFFE7DDD8),
      ),
    2 => const _ChapterPalette(
        header: Color(0xFFEDF4EA),
        body: Color(0xFFF5F9F3),
        lessonCard: Color(0xFFEEF5EB),
        completedCard: Color(0xFFE6F0E2),
        accent: Color(0xFFD2E1CE),
        progressTrack: Color(0xFFE5EFE1),
        outline: Color(0xFFDCE6D9),
      ),
    _ => const _ChapterPalette(
        header: Color(0xFFF6F0E1),
        body: Color(0xFFFBF7ED),
        lessonCard: Color(0xFFF7F0E1),
        completedCard: Color(0xFFF0E7D2),
        accent: Color(0xFFE5D8B7),
        progressTrack: Color(0xFFF1E9D5),
        outline: Color(0xFFE8E0CC),
      ),
  };
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.lesson,
    required this.completed,
    required this.languageCode,
    required this.palette,
  });

  final WorkbookLesson lesson;
  final bool completed;
  final String languageCode;
  final _ChapterPalette palette;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Material(
      color: completed ? palette.completedCard : palette.lessonCard,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).pushNamed(
          AppRoutes.workbookLesson(lesson.id),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: completed ? AppTheme.leaf : palette.accent,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 20,
                backgroundColor: completed
                    ? AppTheme.sage
                    : AppTheme.surface.withValues(alpha: 0.88),
                foregroundColor: AppTheme.leafDark,
                child: completed
                    ? const Icon(Icons.check_rounded, size: 20)
                    : Text(
                        '${lesson.number}',
                        style: theme.textTheme.labelLarge?.copyWith(
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
                      lesson.shortTitle.resolve(languageCode),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      lesson.objective.resolve(languageCode),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.inkMuted,
                        height: 1.32,
                      ),
                    ),
                    if (completed) ...[
                      const SizedBox(height: 5),
                      Text(
                        strings.done,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppTheme.leafDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.inkMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
