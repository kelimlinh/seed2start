import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mam_illustration.dart';
import '../data/ai_launch_context.dart';
import '../data/ai_service.dart';
import 'ai_launch_scope.dart';

class AiPage extends StatefulWidget {
  const AiPage({super.key});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  final _service = AiService();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  AiCoachMode _mode = AiCoachMode.companion;
  AiLaunchContext? _launchContext;
  Stream<List<AiMessage>>? _messageStream;
  bool _streamInitialized = false;
  bool _sending = false;
  String? _pendingUserText;
  int _lastRenderedItemCount = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final nextContext = AiLaunchScope.maybeOf(context);
    if (!_streamInitialized || !identical(nextContext, _launchContext)) {
      _launchContext = nextContext;
      if (nextContext?.isContextual == true) {
        _mode = AiCoachMode.reflection;
      }
      _messageStream = _service.watchMessages(
        launchContext: _launchContext,
      );
      _streamInitialized = true;
      _lastRenderedItemCount = -1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _friendlyError(Object error, AppLocalizations strings) {
    final english = Localizations.localeOf(context).languageCode == 'en';

    if (error is FirebaseFunctionsException) {
      switch (error.code) {
        case 'unauthenticated':
          return english
              ? 'Your session has expired. Please sign in again.'
              : 'Phiên đăng nhập đã hết hạn. Hãy đăng nhập lại.';
        case 'unavailable':
          return english
              ? 'Mầm is temporarily unavailable. Your message was not lost — you can try sending it again.'
              : 'Mầm đang tạm thời chưa phản hồi được. Nội dung bạn vừa nhập vẫn được giữ để bạn thử gửi lại.';
        case 'not-found':
          return english
              ? 'Mầm backend was not found. Check the deployed aiCoach function.'
              : 'Không tìm thấy backend của Mầm. Hãy kiểm tra function aiCoach đã deploy.';
        default:
          return english
              ? 'Mầm encountered an error: ${error.code}'
              : 'Mầm gặp lỗi: ${error.code}';
      }
    }

    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return english
              ? 'Firestore blocked this request. Please try again after the rules are updated.'
              : 'Firestore đang chặn yêu cầu. Hãy kiểm tra lại rules rồi thử lại.';
        case 'unauthenticated':
          return english
              ? 'Your session has expired. Please sign in again.'
              : 'Phiên đăng nhập đã hết hạn. Hãy đăng nhập lại.';
        case 'unavailable':
          return english
              ? 'Mầm is temporarily unavailable. Please try again.'
              : 'Mầm đang tạm thời chưa phản hồi được. Bạn thử lại nhé.';
        case 'not-found':
          return english
              ? 'Mầm backend was not found. Check the deployed aiCoach function.'
              : 'Không tìm thấy backend của Mầm. Hãy kiểm tra function aiCoach đã deploy.';
      }
    }

    return strings.aiError;
  }

  Future<void> _send([String? preset, AiCoachMode? presetMode]) async {
    final text = (preset ?? _controller.text).trim();
    if (text.isEmpty || _sending) return;

    final sendMode = presetMode ?? _mode;

    setState(() {
      _mode = sendMode;
      _sending = true;
      _pendingUserText = text;
      if (preset == null) {
        _controller.clear();
      }
    });
    _scheduleScrollToBottom(force: true);

    try {
      await _service.send(
        text: text,
        locale: Localizations.localeOf(context).languageCode,
        mode: sendMode,
        launchContext: _launchContext,
      );

      if (mounted) {
        setState(() {
          _pendingUserText = null;
        });
      }
    } catch (error, stackTrace) {
      debugPrint('MẦM SEND ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        // Phase 9C persists messages only after a successful provider reply,
        // therefore restoring the draft cannot create a duplicate history item.
        if (_controller.text.trim().isEmpty) {
          _controller.text = text;
          _controller.selection = TextSelection.collapsed(
            offset: _controller.text.length,
          );
        }

        setState(() {
          _pendingUserText = null;
        });

        final strings = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_friendlyError(error, strings))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _sending = false);
        _scheduleScrollToBottom(force: true);
      }
    }
  }

  Future<void> _confirmClearConversation() async {
    final locale = Localizations.localeOf(context).languageCode;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          _pick(
            locale,
            'Xóa cuộc trò chuyện này?',
            'Clear this conversation?',
          ),
        ),
        content: Text(
          _launchContext?.isContextual == true
              ? _pick(
                  locale,
                  'Chỉ cuộc trò chuyện Mầm của hoạt động này sẽ bị xóa. Nội dung trong sổ tay và nhật ký của bạn không bị ảnh hưởng.',
                  'Only Mầm’s conversation for this activity will be cleared. Your workbook and journal content will not be affected.',
                )
              : _pick(
                  locale,
                  'Lịch sử trò chuyện Mầm hiện tại sẽ bị xóa. Dữ liệu sổ tay, mục tiêu và nhật ký của bạn không bị ảnh hưởng.',
                  'Your current Mầm chat history will be cleared. Your workbook, goals, and journal data will not be affected.',
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(_pick(locale, 'Hủy', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(_pick(locale, 'Xóa', 'Clear')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _clearConversation();
    }
  }

  Future<void> _clearConversation() async {
    try {
      await _service.clearConversation(
        launchContext: _launchContext,
      );
      _lastRenderedItemCount = -1;
    } catch (error, stackTrace) {
      debugPrint('MẦM CLEAR ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        final strings = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_friendlyError(error, strings))),
        );
      }
    }
  }

  void _scheduleScrollToBottom({bool force = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      final target = _scrollController.position.maxScrollExtent;
      final distance = target - _scrollController.offset;

      if (!force && distance > 420) {
        return;
      }

      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final contextual = _launchContext?.isContextual == true;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.aiCoach),
        actions: [
          IconButton(
            tooltip: strings.aiClearConversation,
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: _sending ? null : _confirmClearConversation,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.sand,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.outline),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        MamIllustration(
                          pose: contextual
                              ? MamPose.reflection
                              : MamPose.thinking,
                          size: 76,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                contextual
                                    ? _pick(
                                        locale,
                                        'Mầm đang đồng hành với hoạt động này',
                                        'Mầm is with you in this activity',
                                      )
                                    : strings.aiGreeting,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.ink,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                contextual
                                    ? _contextSubtitle(locale, _launchContext!)
                                    : strings.aiSubtitle,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.inkMuted,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (contextual)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: _ContextCard(
                      contextData: _launchContext!,
                      locale: locale,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: contextual
                          ? [
                              _PromptChip(
                                label: _pick(
                                  locale,
                                  'Cùng mình nhìn lại phần vừa viết',
                                  'Help me reflect on what I wrote',
                                ),
                                enabled: !_sending,
                                onTap: () => _send(
                                  _pick(
                                    locale,
                                    'Cùng mình nhìn lại phần mình vừa viết nhé.',
                                    'Help me reflect on what I just wrote.',
                                  ),
                                  AiCoachMode.reflection,
                                ),
                              ),
                              _PromptChip(
                                label: _pick(
                                  locale,
                                  'Gợi ý một bước nhỏ tiếp theo',
                                  'Suggest one small next step',
                                ),
                                enabled: !_sending,
                                onTap: () => _send(
                                  _pick(
                                    locale,
                                    'Từ hoạt động này, gợi ý cho mình một bước nhỏ tiếp theo.',
                                    'From this activity, suggest one small next step for me.',
                                  ),
                                  AiCoachMode.reflection,
                                ),
                              ),
                            ]
                          : [
                              _PromptChip(
                                label: strings.aiPromptGoal,
                                enabled: !_sending,
                                onTap: () => _send(
                                  strings.aiPromptGoal,
                                  AiCoachMode.goal,
                                ),
                              ),
                              _PromptChip(
                                label: strings.aiPromptReflection,
                                enabled: !_sending,
                                onTap: () => _send(
                                  strings.aiPromptReflection,
                                  AiCoachMode.reflection,
                                ),
                              ),
                              _PromptChip(
                                label: strings.aiPromptDifficulty,
                                enabled: !_sending,
                                onTap: () => _send(
                                  strings.aiPromptDifficulty,
                                  AiCoachMode.hero,
                                ),
                              ),
                              _PromptChip(
                                label: strings.aiPromptStrengths,
                                enabled: !_sending,
                                onTap: () => _send(
                                  strings.aiPromptStrengths,
                                  AiCoachMode.hero,
                                ),
                              ),
                            ],
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: StreamBuilder<List<AiMessage>>(
                    stream: _messageStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        debugPrint('MẦM STREAM ERROR: ${snapshot.error}');
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const MamIllustration(
                                  pose: MamPose.confused,
                                  size: 82,
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  _friendlyError(snapshot.error!, strings),
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final messages = snapshot.data ?? const <AiMessage>[];

                      final pending = _pendingUserText;
                      final pendingAlreadyPersisted = pending != null &&
                          messages.reversed.take(2).any(
                                (message) =>
                                    message.role == 'user' &&
                                    message.content.trim() == pending.trim(),
                              );
                      final showPending =
                          pending != null && !pendingAlreadyPersisted;
                      final showThinking = _sending;

                      if (messages.isEmpty && !showPending && !showThinking) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                MamIllustration(
                                  pose: contextual
                                      ? MamPose.reflection
                                      : MamPose.hello,
                                  size: 92,
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  contextual
                                      ? _pick(
                                          locale,
                                          'Bạn có thể hỏi Mầm về chính hoạt động đang làm. Mầm sẽ dựa vào nội dung bài và phần bạn vừa viết để gợi mở, không viết thay bạn.',
                                          'You can ask Mầm about this activity. Mầm will use the lesson and your reflection as context, without writing it for you.',
                                        )
                                      : strings.aiEmpty,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: AppTheme.inkMuted,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final extraItems =
                          (showPending ? 1 : 0) + (showThinking ? 1 : 0);
                      final itemCount = messages.length + extraItems;

                      if (_lastRenderedItemCount != itemCount) {
                        _lastRenderedItemCount = itemCount;
                        _scheduleScrollToBottom();
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        itemCount: itemCount,
                        itemBuilder: (context, index) {
                          if (index < messages.length) {
                            return _Bubble(message: messages[index]);
                          }

                          var cursor = messages.length;

                          if (showPending) {
                            if (index == cursor) {
                              return _Bubble(
                                message: AiMessage(
                                  role: 'user',
                                  content: pending,
                                ),
                                pending: true,
                              );
                            }
                            cursor += 1;
                          }

                          if (showThinking && index == cursor) {
                            return _ThinkingBubble(locale: locale);
                          }

                          return const SizedBox.shrink();
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppTheme.outline),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.035),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            enabled: !_sending,
                            minLines: 1,
                            maxLines: 4,
                            maxLength: 2000,
                            textInputAction: TextInputAction.send,
                            onSubmitted: _sending ? null : (_) => _send(),
                            decoration: InputDecoration(
                              hintText: contextual
                                  ? _pick(
                                      locale,
                                      'Hỏi Mầm về hoạt động này...',
                                      'Ask Mầm about this activity...',
                                    )
                                  : strings.aiInputHint,
                              counterText: '',
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Tooltip(
                          message: _pick(locale, 'Gửi cho Mầm', 'Send to Mầm'),
                          child: IconButton.filled(
                            onPressed: _sending ? null : _send,
                            icon: _sending
                                ? const SizedBox.square(
                                    dimension: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.arrow_upward_rounded),
                          ),
                        ),
                      ],
                    ),
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

class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10, right: 28),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const MamIllustration(
              pose: MamPose.thinking,
              size: 38,
              semanticLabel: 'Mầm',
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.sand,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(19),
                    topRight: Radius.circular(19),
                    bottomLeft: Radius.circular(6),
                    bottomRight: Radius.circular(19),
                  ),
                  border: Border.all(color: AppTheme.outline),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox.square(
                      dimension: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 9),
                    Flexible(
                      child: Text(
                        _pick(
                          locale,
                          'Mầm đang suy nghĩ...',
                          'Mầm is thinking...',
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.inkMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContextCard extends StatelessWidget {
  const _ContextCard({
    required this.contextData,
    required this.locale,
  });

  final AiLaunchContext contextData;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dimensions = contextData.psycapDimensionIds
        .map((id) => _dimensionLabel(locale, id))
        .where((label) => label.isNotEmpty)
        .toList(growable: false);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppTheme.sageSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_stories_outlined,
            color: AppTheme.leafDark,
            size: 20,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              dimensions.isEmpty
                  ? _pick(
                      locale,
                      'Cuộc trò chuyện riêng cho hoạt động này · Mầm đã nhận ngữ cảnh của bài và phần phản tư hiện tại.',
                      'A separate conversation for this activity · Mầm has received the lesson and reflection context.',
                    )
                  : '${_pick(locale, 'Cuộc trò chuyện riêng cho hoạt động này · Trọng tâm', 'Separate activity conversation · Focus')}: ${dimensions.join(' · ')}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.leafDark,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromptChip extends StatelessWidget {
  const _PromptChip({
    required this.label,
    required this.onTap,
    required this.enabled,
  });

  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: const Icon(Icons.eco_outlined, size: 17),
      label: Text(label),
      onPressed: enabled ? onTap : null,
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.message,
    this.pending = false,
  });

  final AiMessage message;
  final bool pending;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final theme = Theme.of(context);

    final bubble = Opacity(
      opacity: pending ? 0.72 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 560),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.sage : AppTheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(19),
            topRight: const Radius.circular(19),
            bottomLeft: Radius.circular(isUser ? 19 : 6),
            bottomRight: Radius.circular(isUser ? 6 : 19),
          ),
          border: Border.all(
            color: isUser ? AppTheme.sage : AppTheme.outline,
          ),
        ),
        child: SelectableText(
          message.content,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.5,
            color: AppTheme.ink,
          ),
        ),
      ),
    );

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 42),
          child: bubble,
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10, right: 28),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const MamIllustration(
              pose: MamPose.hello,
              size: 34,
            ),
            const SizedBox(width: 8),
            Flexible(child: bubble),
          ],
        ),
      ),
    );
  }
}

String _contextSubtitle(String locale, AiLaunchContext context) {
  final dimensions = context.psycapDimensionIds
      .map((id) => _dimensionLabel(locale, id))
      .where((label) => label.isNotEmpty)
      .toList(growable: false);

  if (dimensions.isNotEmpty) {
    return _pick(
      locale,
      'Mầm sẽ bám vào nội dung bài và trọng tâm ${dimensions.join(', ')} để gợi mở đúng vấn đề bạn đang làm.',
      'Mầm will stay anchored to the lesson and ${dimensions.join(', ')} while helping you think through this activity.',
    );
  }

  return _pick(
    locale,
    'Mầm sẽ dùng nội dung bài và phần phản tư hiện tại làm ngữ cảnh cho cuộc trò chuyện này.',
    'Mầm will use the lesson and your current reflection as context for this conversation.',
  );
}

String _dimensionLabel(String locale, String id) {
  return switch (id) {
    'hope' => _pick(locale, 'Hy vọng', 'Hope'),
    'selfEfficacy' => _pick(locale, 'Niềm tin vào năng lực', 'Self-efficacy'),
    'resilience' => _pick(locale, 'Khả năng phục hồi', 'Resilience'),
    'optimism' => _pick(locale, 'Lạc quan', 'Optimism'),
    _ => '',
  };
}

String _pick(String locale, String vi, String en) => locale == 'en' ? en : vi;
