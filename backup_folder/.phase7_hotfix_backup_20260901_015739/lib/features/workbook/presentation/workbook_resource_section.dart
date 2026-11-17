import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mam_illustration.dart';
import '../../reflection/data/reflection_service.dart';
import '../data/workbook_models.dart';
import '../data/workbook_resource_block_service.dart';
import '../data/workbook_service.dart';

class WorkbookResourceSection extends StatelessWidget {
  const WorkbookResourceSection({
    super.key,
    required this.lesson,
    required this.workbookService,
    this.blockService,
    this.reflectionService,
  });

  final WorkbookLesson lesson;
  final WorkbookService workbookService;
  final WorkbookResourceBlockService? blockService;
  final ReflectionService? reflectionService;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    return StreamBuilder<List<WorkbookResource>>(
      stream: workbookService.watchPublishedResourcesForLesson(lesson.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return _ResourceStateCard(
            pose: MamPose.search,
            title: _pick(locale, 'Máº§m Ä‘ang tÃ¬m tÃ i nguyÃªn cá»§a bÃ i nÃ y...',
                'Máº§m is finding this lessonâ€™s resources...'),
          );
        }

        if (snapshot.hasError) {
          return _ResourceStateCard(
            pose: MamPose.confused,
            title: strings.workbookLoadError,
          );
        }

        final resources = snapshot.data ?? const <WorkbookResource>[];
        if (resources.isEmpty) {
          return _ResourceStateCard(
            pose: MamPose.book,
            title: _pick(
              locale,
              'Pháº§n má»Ÿ rá»™ng sá»‘ cá»§a bÃ i nÃ y Ä‘ang Ä‘Æ°á»£c chuáº©n bá»‹.',
              'The digital companion for this lesson is being prepared.',
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_stories_outlined, color: AppTheme.leafDark),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _pick(locale, 'Tiáº¿p tá»¥c trÃªn website', 'Continue on the website'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppTheme.ink,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _pick(
                locale,
                'Chá»‰ nhá»¯ng ná»™i dung cáº§n tÆ°Æ¡ng tÃ¡c má»›i Ä‘Æ°á»£c má»Ÿ rá»™ng á»Ÿ Ä‘Ã¢y. Pháº§n viáº¿t tay váº«n thuá»™c vá» sá»• tay cá»§a báº¡n.',
                'Only interactive content is extended here. Handwritten work still belongs in your workbook.',
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.inkMuted,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 14),
            for (var i = 0; i < resources.length; i++) ...[
              _ResourceCard(
                resource: resources[i],
                lesson: lesson,
                blockService: blockService ?? WorkbookResourceBlockService(),
                reflectionService: reflectionService ?? ReflectionService(),
              ),
              if (i != resources.length - 1) const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class _ResourceCard extends StatefulWidget {
  const _ResourceCard({
    required this.resource,
    required this.lesson,
    required this.blockService,
    required this.reflectionService,
  });

  final WorkbookResource resource;
  final WorkbookLesson lesson;
  final WorkbookResourceBlockService blockService;
  final ReflectionService reflectionService;

  @override
  State<_ResourceCard> createState() => _ResourceCardState();
}

class _ResourceCardState extends State<_ResourceCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final resource = widget.resource;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ResourceIcon(type: resource.type),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resource.title.resolve(locale),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppTheme.ink,
                          ),
                        ),
                        if (resource.description.resolve(locale).trim().isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(
                            resource.description.resolve(locale),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.inkMuted,
                              height: 1.4,
                            ),
                          ),
                        ],
                        if (resource.durationMinutes != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.schedule_rounded, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${resource.durationMinutes} ${_pick(locale, 'phÃºt', 'min')}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.inkMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            WorkbookResourceBlocksView(
              resource: resource,
              lesson: widget.lesson,
              service: widget.blockService,
              reflectionService: widget.reflectionService,
            ),
          ],
        ],
      ),
    );
  }
}

class WorkbookResourceBlocksView extends StatelessWidget {
  const WorkbookResourceBlocksView({
    super.key,
    required this.resource,
    required this.lesson,
    required this.service,
    required this.reflectionService,
  });

  final WorkbookResource resource;
  final WorkbookLesson lesson;
  final WorkbookResourceBlockService service;
  final ReflectionService reflectionService;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    return StreamBuilder<List<WorkbookResourceBlock>>(
      stream: service.watchBlocks(resource.resourceId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(22),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(18),
            child: Text(AppLocalizations.of(context).workbookLoadError),
          );
        }

        final blocks = snapshot.data ?? const <WorkbookResourceBlock>[];
        if (blocks.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(18),
            child: Text(
              _pick(
                locale,
                'Ná»™i dung nÃ y chÆ°a cÃ³ block Ä‘Æ°á»£c xuáº¥t báº£n.',
                'This resource does not have published blocks yet.',
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.inkMuted,
                  ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < blocks.length; i++) ...[
                _BlockRenderer(
                  block: blocks[i],
                  resource: resource,
                  lesson: lesson,
                  reflectionService: reflectionService,
                ),
                if (i != blocks.length - 1) const SizedBox(height: 14),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _BlockRenderer extends StatelessWidget {
  const _BlockRenderer({
    required this.block,
    required this.resource,
    required this.lesson,
    required this.reflectionService,
  });

  final WorkbookResourceBlock block;
  final WorkbookResource resource;
  final WorkbookLesson lesson;
  final ReflectionService reflectionService;

  @override
  Widget build(BuildContext context) {
    return switch (block.type) {
      WorkbookResourceBlockType.simulation => _StoryBlock(
          block: block,
          icon: Icons.theater_comedy_outlined,
          background: AppTheme.sageSoft,
        ),
      WorkbookResourceBlockType.optionalResponse =>
        _OptionalResponseBlock(block: block),
      WorkbookResourceBlockType.realCase => _StoryBlock(
          block: block,
          icon: Icons.article_outlined,
          background: AppTheme.sand,
          showSource: true,
        ),
      WorkbookResourceBlockType.takeaway => _StoryBlock(
          block: block,
          icon: Icons.lightbulb_outline_rounded,
          background: AppTheme.sunshine,
        ),
      WorkbookResourceBlockType.reflection => _ReflectionBlock(
          block: block,
          resource: resource,
          lesson: lesson,
          reflectionService: reflectionService,
        ),
      WorkbookResourceBlockType.youtube ||
      WorkbookResourceBlockType.video ||
      WorkbookResourceBlockType.podcast ||
      WorkbookResourceBlockType.image => _MediaPlaceholder(block: block),
      WorkbookResourceBlockType.text => _StoryBlock(
          block: block,
          icon: Icons.notes_rounded,
          background: AppTheme.surface,
        ),
    };
  }
}

class _StoryBlock extends StatelessWidget {
  const _StoryBlock({
    required this.block,
    required this.icon,
    required this.background,
    this.showSource = false,
  });

  final WorkbookResourceBlock block;
  final IconData icon;
  final Color background;
  final bool showSource;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final title = block.title.resolve(locale).trim();
    final body = block.body.resolve(locale).trim();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: AppTheme.leafDark),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.ink,
                    ),
                  ),
                ),
              ],
            ),
          if (title.isNotEmpty && body.isNotEmpty) const SizedBox(height: 10),
          if (body.isNotEmpty)
            SelectableText(
              body,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.inkMuted,
                height: 1.55,
              ),
            ),
          if (showSource && block.sourceTitle?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Text(
              '${_pick(locale, 'Nguá»“n', 'Source')}: ${block.sourceTitle}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.inkMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (block.sourceUrl?.trim().isNotEmpty == true)
              SelectableText(
                block.sourceUrl!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.leafDark,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _OptionalResponseBlock extends StatefulWidget {
  const _OptionalResponseBlock({required this.block});

  final WorkbookResourceBlock block;

  @override
  State<_OptionalResponseBlock> createState() => _OptionalResponseBlockState();
}

class _OptionalResponseBlockState extends State<_OptionalResponseBlock> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final block = widget.block;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const MamIllustration(pose: MamPose.thinking, size: 48),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  block.prompt.resolve(locale).trim().isNotEmpty
                      ? block.prompt.resolve(locale)
                      : _pick(locale, 'Náº¿u lÃ  báº¡n, báº¡n sáº½ lÃ m gÃ¬?',
                          'What would you do in this situation?'),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            minLines: 3,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: block.placeholder.resolve(locale).trim().isNotEmpty
                  ? block.placeholder.resolve(locale)
                  : _pick(
                      locale,
                      'Báº¡n cÃ³ thá»ƒ ghi láº¡i suy nghÄ©, hoáº·c Ä‘á»ƒ trá»‘ng vÃ  tiáº¿p tá»¥c Ä‘á»c.',
                      'You can write a thought here, or leave it blank and continue.',
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _pick(
              locale,
              'Pháº§n nÃ y khÃ´ng cháº¥m Ä‘Ãºng/sai vÃ  khÃ´ng báº¯t buá»™c lÆ°u.',
              'There is no right/wrong answer here, and saving is optional.',
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReflectionBlock extends StatefulWidget {
  const _ReflectionBlock({
    required this.block,
    required this.resource,
    required this.lesson,
    required this.reflectionService,
  });

  final WorkbookResourceBlock block;
  final WorkbookResource resource;
  final WorkbookLesson lesson;
  final ReflectionService reflectionService;

  @override
  State<_ReflectionBlock> createState() => _ReflectionBlockState();
}

class _ReflectionBlockState extends State<_ReflectionBlock> {
  late final TextEditingController _controller;
  bool _saving = false;
  bool _writtenInWorkbook = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final block = widget.block;
    final signedIn = FirebaseAuth.instance.currentUser != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.blush,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const MamIllustration(pose: MamPose.reflection, size: 52),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  block.title.resolve(locale).trim().isNotEmpty
                      ? block.title.resolve(locale)
                      : strings.reflection,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppTheme.ink,
                  ),
                ),
              ),
            ],
          ),
          if (block.prompt.resolve(locale).trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              block.prompt.resolve(locale),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.inkMuted,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            enabled: !_writtenInWorkbook,
            minLines: 3,
            maxLines: 7,
            decoration: InputDecoration(
              hintText: block.placeholder.resolve(locale).trim().isNotEmpty
                  ? block.placeholder.resolve(locale)
                  : _pick(
                      locale,
                      'Viáº¿t vÃ i dÃ²ng náº¿u báº¡n muá»‘n lÆ°u láº¡i suy nghÄ© nÃ y.',
                      'Write a few lines if you want to save this reflection.',
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: _saving || _writtenInWorkbook
                    ? null
                    : signedIn
                        ? _save
                        : () => Navigator.of(context).pushNamed(
                              AppRoutes.login,
                              arguments: ModalRoute.of(context)?.settings.name ??
                                  AppRoutes.home,
                            ),
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.bookmark_add_outlined),
                label: Text(
                  signedIn
                      ? _pick(locale, 'LÆ°u vÃ o nháº­t kÃ½', 'Save to journal')
                      : _pick(locale, 'ÄÄƒng nháº­p Ä‘á»ƒ lÆ°u', 'Sign in to save'),
                ),
              ),
              if (block.aiEnabled)
                OutlinedButton.icon(
                  onPressed: signedIn
                      ? () => Navigator.of(context).pushNamed(AppRoutes.ai)
                      : () => Navigator.of(context).pushNamed(
                            AppRoutes.login,
                            arguments: ModalRoute.of(context)?.settings.name ??
                                AppRoutes.home,
                          ),
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  label: Text(strings.workbookAskMam),
                ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _writtenInWorkbook = !_writtenInWorkbook;
                    if (_writtenInWorkbook) _controller.clear();
                  });
                },
                icon: Icon(
                  _writtenInWorkbook
                      ? Icons.check_circle_rounded
                      : Icons.edit_outlined,
                ),
                label: Text(
                  _writtenInWorkbook
                      ? _pick(locale, 'ÄÃ£ viáº¿t trong sá»•', 'Written in workbook')
                      : _pick(locale, 'MÃ¬nh sáº½ viáº¿t trong sá»•', 'Iâ€™ll write in my workbook'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final locale = Localizations.localeOf(context).languageCode;
    final content = _controller.text.trim();
    if (content.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_pick(locale, 'Báº¡n viáº¿t vÃ i dÃ²ng trÆ°á»›c khi lÆ°u nhÃ©.', 'Write a few words before saving.'))),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await widget.reflectionService.createReflectionFromResource(
        content: content,
        chapterId: widget.resource.chapterId,
        lessonId: widget.lesson.id,
        resourceId: widget.resource.resourceId,
        psycapDimensions: widget.resource.psycapDimensions
            .map(_dimensionId)
            .toList(growable: false),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_pick(locale, 'Máº§m Ä‘Ã£ lÆ°u pháº§n nhÃ¬n láº¡i nÃ y vÃ o nháº­t kÃ½ cá»§a báº¡n.', 'This reflection has been saved to your journal.'))),
      );
      _controller.clear();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).somethingWrong)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _MediaPlaceholder extends StatelessWidget {
  const _MediaPlaceholder({required this.block});

  final WorkbookResourceBlock block;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);

    final label = switch (block.type) {
      WorkbookResourceBlockType.youtube => 'YouTube',
      WorkbookResourceBlockType.video => _pick(locale, 'Video', 'Video'),
      WorkbookResourceBlockType.podcast => 'Podcast',
      WorkbookResourceBlockType.image => _pick(locale, 'HÃ¬nh áº£nh', 'Image'),
      _ => _pick(locale, 'Media', 'Media'),
    };

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Row(
        children: [
          const Icon(Icons.play_circle_outline_rounded, color: AppTheme.leafDark),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  block.title.resolve(locale).trim().isNotEmpty
                      ? block.title.resolve(locale)
                      : label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _pick(
                    locale,
                    'Ná»™i dung $label nÃ y Ä‘ang Ä‘Æ°á»£c chuáº©n bá»‹ Ä‘á»ƒ hiá»ƒn thá»‹ trá»±c tiáº¿p trÃªn website.',
                    'This $label content is being prepared for direct playback on the website.',
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.inkMuted,
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

class _ResourceStateCard extends StatelessWidget {
  const _ResourceStateCard({
    required this.pose,
    required this.title,
  });

  final MamPose pose;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Row(
        children: [
          MamIllustration(pose: pose, size: 54),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

class _ResourceIcon extends StatelessWidget {
  const _ResourceIcon({required this.type});

  final WorkbookResourceType type;

  @override
  Widget build(BuildContext context) {
    final icon = switch (type) {
      WorkbookResourceType.scenario => Icons.auto_stories_outlined,
      WorkbookResourceType.podcast => Icons.headphones_outlined,
      WorkbookResourceType.youtube || WorkbookResourceType.video =>
        Icons.play_circle_outline_rounded,
      WorkbookResourceType.activity => Icons.extension_outlined,
      WorkbookResourceType.reflection => Icons.edit_note_rounded,
      WorkbookResourceType.challenge => Icons.flag_outlined,
      WorkbookResourceType.caseStudy => Icons.article_outlined,
      WorkbookResourceType.comic => Icons.collections_bookmark_outlined,
      WorkbookResourceType.interview => Icons.mic_none_rounded,
      WorkbookResourceType.quiz => Icons.quiz_outlined,
    };

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.sageSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: AppTheme.leafDark),
    );
  }
}

String _dimensionId(PsycapDimension dimension) {
  return switch (dimension) {
    PsycapDimension.hope => 'hope',
    PsycapDimension.selfEfficacy => 'selfEfficacy',
    PsycapDimension.resilience => 'resilience',
    PsycapDimension.optimism => 'optimism',
  };
}

String _pick(String locale, String vi, String en) => locale == 'en' ? en : vi;


