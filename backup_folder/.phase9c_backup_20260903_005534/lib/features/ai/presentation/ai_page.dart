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

  AiCoachMode _mode = AiCoachMode.companion;
  AiLaunchContext? _launchContext;
  Stream<List<AiMessage>>? _messageStream;
  bool _streamInitialized = false;
  bool _sending = false;

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
    }
  }

  @override
  void dispose() {
    _controller.dispose();
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
              ? 'Mầm is temporarily unavailable. Please try again.'
              : 'Mầm đang tạm thời chưa phản hồi được. Bạn thử lại nhé.';
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
    if (presetMode != null && presetMode != _mode) {
      setState(() => _mode = presetMode);
    }

    if (preset == null) {
      _controller.clear();
    }

    setState(() => _sending = true);

    try {
      await _service.send(
        text: text,
        locale: Localizations.localeOf(context).languageCode,
        mode: sendMode,
        launchContext: _launchContext,
      );
    } catch (error, stackTrace) {
      debugPrint('MẦM SEND ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        final strings = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_friendlyError(error, strings))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  Future<void> _clearConversation() async {
    try {
      await _service.clearConversation(
        launchContext: _launchContext,
      );
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
            onPressed: _sending ? null : _clearConversation,
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

                      if (messages.isEmpty) {
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

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          return _Bubble(message: messages[index]);
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
                            minLines: 1,
                            maxLines: 4,
                            textInputAction: TextInputAction.newline,
                            decoration: InputDecoration(
                              hintText: contextual
                                  ? _pick(
                                      locale,
                                      'Hỏi Mầm về hoạt động này...',
                                      'Ask Mầm about this activity...',
                                    )
                                  : strings.aiInputHint,
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
                        IconButton.filled(
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
                      'Mầm đã nhận ngữ cảnh của bài và phần phản tư hiện tại.',
                      'Mầm has received the context of this lesson and reflection.',
                    )
                  : '${_pick(locale, 'Trọng tâm', 'Focus')}: ${dimensions.join(' · ')}',
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
  const _Bubble({required this.message});

  final AiMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final theme = Theme.of(context);

    final bubble = Container(
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
