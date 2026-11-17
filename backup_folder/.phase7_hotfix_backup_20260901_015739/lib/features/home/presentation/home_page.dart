import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mam_illustration.dart';
import '../../workbook/data/workbook_models.dart';
import '../../workbook/data/workbook_service.dart';
import '../../workbook/presentation/access_code_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, this.workbookService});

  final WorkbookService? workbookService;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final service = workbookService ?? WorkbookService();
    final languageCode = Localizations.localeOf(context).languageCode;
    final displayName = FirebaseAuth.instance.currentUser?.displayName?.trim();

    return SafeArea(
      child: StreamBuilder<Set<String>>(
        stream: service.watchCompletedLessonIds(),
        builder: (context, snapshot) {
          final completed = snapshot.data ?? <String>{};
          final currentLesson = WorkbookCatalog.firstIncomplete(completed);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 34),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WelcomeHero(
                      title: displayName != null && displayName.isNotEmpty
                          ? strings.helloName(displayName)
                          : strings.hello,
                      subtitle: strings.homeSubtitle,
                    ),
                    const SizedBox(height: 20),
                    _ContinueJourneyCard(
                      lesson: currentLesson,
                      languageCode: languageCode,
                      completedCount: completed.length,
                    ),
                    const SizedBox(height: 28),
                    const AccessCodeCard(),
                    const SizedBox(height: 28),
                    _SectionTitle(
                      title: strings.homeThreeChapters,
                      icon: Icons.route_outlined,
                    ),
                    const SizedBox(height: 12),
                    for (var index = 0;
                        index < WorkbookCatalog.chapters.length;
                        index++) ...[
                      _ChapterSnapshot(
                        chapter: WorkbookCatalog.chapters[index],
                        completedLessonIds: completed,
                        languageCode: languageCode,
                      ),
                      if (index != WorkbookCatalog.chapters.length - 1)
                        const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 28),
                    _MamCard(strings: strings),
                    const SizedBox(height: 18),
                    _DailyFocusCard(strings: strings),
                    if (snapshot.hasError) ...[
                      const SizedBox(height: 12),
                      Text(
                        strings.workbookLoadError,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    _GentleReminder(strings: strings),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 620;
        final copy = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppTheme.ink,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              subtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.inkMuted,
                height: 1.45,
              ),
            ),
          ],
        );

        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            wide ? 24 : 18,
            wide ? 18 : 16,
            wide ? 18 : 14,
            wide ? 18 : 16,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.sageSoft, AppTheme.surface],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppTheme.outline),
          ),
          child: wide
              ? Row(
                  children: [
                    Expanded(child: copy),
                    const SizedBox(width: 18),
                    const MamIllustration(
                      pose: MamPose.hello,
                      size: 112,
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: copy),
                    const SizedBox(width: 12),
                    const MamIllustration(
                      pose: MamPose.hello,
                      size: 76,
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _ContinueJourneyCard extends StatelessWidget {
  const _ContinueJourneyCard({
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
    final chapter = lesson == null
        ? null
        : WorkbookCatalog.chapterById(lesson!.chapterId);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.leafDark,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppTheme.leafDark.withValues(alpha: 0.12),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.route_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                strings.homeContinueJourney,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (lesson != null) ...[
            if (chapter != null)
              Text(
                '${strings.workbookChapterNumber(chapter.number)} Â· ${chapter.title.resolve(languageCode)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              '${strings.workbookLessonNumber(lesson!.number)} Â· ${lesson!.shortTitle.resolve(languageCode)}',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              lesson!.objective.resolve(languageCode),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.82),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 17),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.sunshine,
                foregroundColor: const Color(0xFF493A22),
              ),
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
                color: Colors.white,
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
                color: Colors.white.withValues(alpha: 0.82),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.sunshine,
                foregroundColor: const Color(0xFF493A22),
              ),
              onPressed: () => Navigator.of(context).pushNamed(
                AppRoutes.workbook,
              ),
              icon: const Icon(Icons.menu_book_outlined),
              label: Text(strings.openWorkbook),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 21, color: AppTheme.leaf),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppTheme.ink,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChapterSnapshot extends StatelessWidget {
  const _ChapterSnapshot({
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

    final accent = switch (chapter.number) {
      1 => AppTheme.blush,
      2 => AppTheme.sage,
      _ => AppTheme.sunshine,
    };

    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.workbook),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.outline),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  '${chapter.number}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.leafDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chapter.title.resolve(languageCode),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 7),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 6,
                        value: progress,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      strings.workbookChapterProgressText(
                        completed,
                        lessons.length,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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

class _MamCard extends StatelessWidget {
  const _MamCard({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: AppTheme.sand,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.ai),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              const MamIllustration(
                pose: MamPose.thinking,
                size: 78,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.homeMeetMam,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      strings.homeMamBody,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.inkMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppTheme.earth,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyFocusCard extends StatelessWidget {
  const _DailyFocusCard({required this.strings});

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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.sunshine,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.wb_sunny_outlined,
              color: AppTheme.earth,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.dailyFocusTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  strings.dailyFocusBody,
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

class _GentleReminder extends StatelessWidget {
  const _GentleReminder({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.favorite_border_rounded,
            color: AppTheme.leaf,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              strings.gentleReminder,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.inkMuted,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

