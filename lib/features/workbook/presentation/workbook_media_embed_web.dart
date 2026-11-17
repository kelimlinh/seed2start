import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mam_illustration.dart';
import '../data/workbook_media_utils.dart';
import '../data/workbook_models.dart';

class WorkbookMediaEmbed extends StatefulWidget {
  const WorkbookMediaEmbed({
    super.key,
    required this.block,
  });

  final WorkbookResourceBlock block;

  @override
  State<WorkbookMediaEmbed> createState() => _WorkbookMediaEmbedState();
}

class _WorkbookMediaEmbedState extends State<WorkbookMediaEmbed> {
  static int _nextViewId = 0;

  String? _viewType;

  @override
  void initState() {
    super.initState();
    _preparePlatformView();
  }

  @override
  void didUpdateWidget(covariant WorkbookMediaEmbed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.block.youtubeId != widget.block.youtubeId ||
        oldWidget.block.mediaUrl != widget.block.mediaUrl ||
        oldWidget.block.type != widget.block.type) {
      _viewType = null;
      _preparePlatformView();
    }
  }

  void _preparePlatformView() {
    final element = _createHtmlElement(widget.block);
    if (element == null) return;

    final viewType =
        'psycapnote-media-${widget.block.blockId}-${_nextViewId++}';
    ui_web.platformViewRegistry.registerViewFactory(
      viewType,
      (int _) => element,
    );
    _viewType = viewType;
  }

  web.HTMLElement? _createHtmlElement(WorkbookResourceBlock block) {
    switch (block.type) {
      case WorkbookResourceBlockType.youtube:
        final videoId = extractYouTubeVideoId(
          youtubeId: block.youtubeId,
          mediaUrl: block.mediaUrl,
        );
        if (videoId == null) return null;

        final iframe =
            web.document.createElement('iframe') as web.HTMLIFrameElement
              ..src = 'https://www.youtube-nocookie.com/embed/$videoId?rel=0'
              ..style.border = '0'
              ..style.width = '100%'
              ..style.height = '100%';
        iframe.setAttribute(
          'allow',
          'accelerometer; clipboard-write; encrypted-media; '
              'gyroscope; picture-in-picture; web-share',
        );
        iframe.setAttribute('allowfullscreen', 'true');
        iframe.setAttribute(
          'title',
          block.title.vi.trim().isNotEmpty
              ? block.title.vi.trim()
              : 'YouTube video',
        );
        return iframe;

      case WorkbookResourceBlockType.video:
        final uri = parseSafeHttpsMediaUri(block.mediaUrl);
        if (uri == null) return null;

        return (web.document.createElement('video') as web.HTMLVideoElement)
          ..src = uri.toString()
          ..controls = true
          ..preload = 'metadata'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.backgroundColor = '#000000';

      case WorkbookResourceBlockType.podcast:
        final uri = parseSafeHttpsMediaUri(block.mediaUrl);
        if (uri == null) return null;

        return (web.document.createElement('audio') as web.HTMLAudioElement)
          ..src = uri.toString()
          ..controls = true
          ..preload = 'metadata'
          ..style.width = '100%';

      case WorkbookResourceBlockType.image:
      case WorkbookResourceBlockType.text:
      case WorkbookResourceBlockType.simulation:
      case WorkbookResourceBlockType.optionalResponse:
      case WorkbookResourceBlockType.realCase:
      case WorkbookResourceBlockType.takeaway:
      case WorkbookResourceBlockType.reflection:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final block = widget.block;
    final title = block.title.resolve(locale).trim();
    final body = block.body.resolve(locale).trim();
    final sourceUri = parseSafeHttpsMediaUri(block.sourceUrl);

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
          if (title.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_iconFor(block.type), color: AppTheme.leafDark),
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
          if (body.isNotEmpty) ...[
            if (title.isNotEmpty) const SizedBox(height: 8),
            Text(
              body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.inkMuted,
                height: 1.45,
              ),
            ),
          ],
          if (title.isNotEmpty || body.isNotEmpty) const SizedBox(height: 12),
          _player(context),
          if (block.sourceTitle?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 10),
            Text(
              '${locale == 'en' ? 'Source' : 'Nguồn'}: ${block.sourceTitle}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.inkMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (sourceUri != null)
              SelectableText(
                sourceUri.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.leafDark,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _player(BuildContext context) {
    final block = widget.block;

    if (block.type == WorkbookResourceBlockType.image) {
      final uri = parseSafeHttpsMediaUri(block.mediaUrl);
      if (uri == null) return _invalidMedia(context);

      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          uri.toString(),
          width: double.infinity,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const AspectRatio(
              aspectRatio: 16 / 9,
              child: Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (_, __, ___) => _invalidMedia(context),
        ),
      );
    }

    if (_viewType == null) {
      return _invalidMedia(context);
    }

    if (block.type == WorkbookResourceBlockType.podcast) {
      return SizedBox(
        height: 64,
        child: HtmlElementView(viewType: _viewType!),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: HtmlElementView(viewType: _viewType!),
      ),
    );
  }

  Widget _invalidMedia(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.sand,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const MamIllustration(pose: MamPose.media, size: 54),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              locale == 'en'
                  ? 'This media does not have a valid link yet.'
                  : 'Nội dung này chưa có đường dẫn media hợp lệ.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.inkMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

IconData _iconFor(WorkbookResourceBlockType type) {
  return switch (type) {
    WorkbookResourceBlockType.youtube => Icons.play_circle_outline_rounded,
    WorkbookResourceBlockType.video => Icons.ondemand_video_outlined,
    WorkbookResourceBlockType.podcast => Icons.headphones_outlined,
    WorkbookResourceBlockType.image => Icons.image_outlined,
    _ => Icons.perm_media_outlined,
  };
}
