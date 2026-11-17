import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mam_illustration.dart';
import '../data/workbook_models.dart';

class WorkbookMediaEmbed extends StatelessWidget {
  const WorkbookMediaEmbed({
    super.key,
    required this.block,
  });

  final WorkbookResourceBlock block;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final title = block.title.resolve(locale).trim();
    final body = block.body.resolve(locale).trim();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MamIllustration(pose: MamPose.media, size: 56),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty)
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppTheme.ink,
                        ),
                  ),
                if (body.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    body,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.inkMuted,
                          height: 1.4,
                        ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  locale == 'en'
                      ? 'This media can be played directly on the Cùng Mầm web companion.'
                      : 'Nội dung media này có thể phát trực tiếp trên website đồng hành cùng Mầm.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
