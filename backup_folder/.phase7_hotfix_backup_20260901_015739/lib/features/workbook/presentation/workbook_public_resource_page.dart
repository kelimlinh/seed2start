import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mam_illustration.dart';
import '../../reflection/data/reflection_service.dart';
import '../data/workbook_models.dart';
import '../data/workbook_resource_block_service.dart';
import '../data/workbook_service.dart';
import 'workbook_resource_section.dart';

class WorkbookPublicResourcePage extends StatelessWidget {
  const WorkbookPublicResourcePage({
    super.key,
    required this.resourceId,
    this.workbookService,
    this.blockService,
    this.reflectionService,
  });

  final String resourceId;
  final WorkbookService? workbookService;
  final WorkbookResourceBlockService? blockService;
  final ReflectionService? reflectionService;

  @override
  Widget build(BuildContext context) {
    final service = workbookService ?? WorkbookService();
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PsyCapNote'),
        actions: [
          IconButton(
            tooltip: _pick(locale, 'Trang chủ', 'Home'),
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
              FirebaseAuth.instance.currentUser == null
                  ? AppRoutes.root
                  : AppRoutes.home,
              (route) => false,
            ),
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: FutureBuilder<WorkbookResource?>(
        future: service.getPublishedResourceById(resourceId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _StateView(
              pose: MamPose.search,
              title: _pick(
                locale,
                'Mầm đang mở nội dung từ sổ tay...',
                'Mầm is opening your workbook content...',
              ),
              loading: true,
            );
          }

          if (snapshot.hasError || snapshot.data == null) {
            return _StateView(
              pose: MamPose.confused,
              title: _pick(
                locale,
                'Mầm chưa tìm thấy nội dung này. Bạn kiểm tra lại QR hoặc mã trong sổ tay nhé.',
                'Mầm could not find this content. Check the QR or workbook code and try again.',
              ),
              actionLabel: _pick(locale, 'Nhập mã khác', 'Enter another code'),
              onAction: () => Navigator.of(context).pushReplacementNamed(
                AppRoutes.access,
              ),
            );
          }

          final resource = snapshot.data!;
          final lesson = WorkbookCatalog.byId(resource.lessonId);
          if (lesson == null) {
            return _StateView(
              pose: MamPose.confused,
              title: _pick(
                locale,
                'Nội dung này chưa được gắn với một bài sổ tay hợp lệ.',
                'This content is not linked to a valid workbook lesson yet.',
              ),
            );
          }

          return _ResourceBody(
            resource: resource,
            lesson: lesson,
            blockService: blockService ?? WorkbookResourceBlockService(),
            reflectionService: reflectionService ?? ReflectionService(),
          );
        },
      ),
    );
  }
}

class _ResourceBody extends StatelessWidget {
  const _ResourceBody({
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
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final signedIn = FirebaseAuth.instance.currentUser != null;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 38),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.sageSoft, AppTheme.surface],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppTheme.outline),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _pick(locale, 'TỪ SỔ TAY · ${_lessonNumber(locale, lesson.number)}',
                                  'FROM WORKBOOK · ${_lessonNumber(locale, lesson.number)}'),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: AppTheme.leafDark,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              resource.title.resolve(locale),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: AppTheme.ink,
                                fontWeight: FontWeight.w900,
                                height: 1.18,
                              ),
                            ),
                            if (resource.description.resolve(locale).trim().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                resource.description.resolve(locale),
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: AppTheme.inkMuted,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const MamIllustration(
                        pose: MamPose.journey,
                        size: 86,
                      ),
                    ],
                  ),
                ),
                if (!signedIn) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppTheme.sand,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.outline),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_open_rounded, color: AppTheme.leafDark),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _pick(
                              locale,
                              'Bạn có thể xem nội dung này mà không cần đăng nhập. Đăng nhập chỉ khi muốn Mầm lưu nhật ký hoặc hành trình cho bạn.',
                              'You can view this content without signing in. Sign in only if you want Mầm to save your journal or journey.',
                            ),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.inkMuted,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                WorkbookResourceBlocksView(
                  resource: resource,
                  lesson: lesson,
                  service: blockService,
                  reflectionService: reflectionService,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.outline),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.menu_book_outlined, color: AppTheme.leafDark),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _pick(
                            locale,
                            'Xong phần số rồi? Bạn có thể quay lại bài trong sổ tay để tiếp tục phần viết tay.',
                            'Finished the digital part? Return to the workbook lesson to continue the handwritten activity.',
                          ),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.inkMuted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pushNamed(
                          AppRoutes.workbookLesson(lesson.id),
                        ),
                        child: Text(_pick(locale, 'Mở bài', 'Open lesson')),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StateView extends StatelessWidget {
  const _StateView({
    required this.pose,
    required this.title,
    this.loading = false,
    this.actionLabel,
    this.onAction,
  });

  final MamPose pose;
  final String title;
  final bool loading;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MamIllustration(pose: pose, size: 126, semanticLabel: title),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.ink,
                      ),
                ),
                if (loading) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(),
                ],
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: onAction,
                    child: Text(actionLabel!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _lessonNumber(String locale, int number) =>
    locale == 'en' ? 'Lesson $number' : 'Bài $number';

String _pick(String locale, String vi, String en) => locale == 'en' ? en : vi;
