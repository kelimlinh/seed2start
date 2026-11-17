import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mam_illustration.dart';
import '../data/ai_service.dart';

class AiPage extends StatefulWidget {
  const AiPage({super.key});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  final _service = AiService();
  final _controller = TextEditingController();

  AiCoachMode _mode = AiCoachMode.companion;
  bool _sending = false;

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

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _controller.text).trim();
    if (text.isEmpty || _sending) return;

    if (preset == null) {
      _controller.clear();
    }

    setState(() => _sending = true);

    try {
      await _service.send(
        text: text,
        locale: Localizations.localeOf(context).languageCode,
        mode: _mode,
      );
    } catch (error, stackTrace) {
      debugPrint('AI SEND ERROR: $error');
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
      await _service.clearConversation();
    } catch (error, stackTrace) {
      debugPrint('AI CLEAR ERROR: $error');
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
                        const MamIllustration(
                          pose: MamPose.thinking,
                          size: 76,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.aiGreeting,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.ink,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                strings.aiSubtitle,
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
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _PromptChip(
                          label: strings.aiPromptGoal,
                          enabled: !_sending,
                          onTap: () {
                            _mode = AiCoachMode.goal;
                            _send(strings.aiPromptGoal);
                          },
                        ),
                        _PromptChip(
                          label: strings.aiPromptReflection,
                          enabled: !_sending,
                          onTap: () {
                            _mode = AiCoachMode.reflection;
                            _send(strings.aiPromptReflection);
                          },
                        ),
                        _PromptChip(
                          label: strings.aiPromptDifficulty,
                          enabled: !_sending,
                          onTap: () {
                            _mode = AiCoachMode.hero;
                            _send(strings.aiPromptDifficulty);
                          },
                        ),
                        _PromptChip(
                          label: strings.aiPromptStrengths,
                          enabled: !_sending,
                          onTap: () {
                            _mode = AiCoachMode.hero;
                            _send(strings.aiPromptStrengths);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: StreamBuilder<List<AiMessage>>(
                    stream: _service.watchMessages(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        debugPrint('AI STREAM ERROR: ${snapshot.error}');
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
                                const MamIllustration(
                                  pose: MamPose.hello,
                                  size: 92,
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  strings.aiEmpty,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: AppTheme.inkMuted,
                                    height: 1.4,
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
                              hintText: strings.aiInputHint,
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
      child: Text(
        message.content,
        style: theme.textTheme.bodyMedium?.copyWith(
          height: 1.45,
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
