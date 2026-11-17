import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mam_illustration.dart';
import '../data/access_code_service.dart';

enum _AccessState { idle, searching, success, invalid, error }

class AccessCodePage extends StatefulWidget {
  const AccessCodePage({
    super.key,
    this.initialCode,
    this.service,
  });

  final String? initialCode;
  final AccessCodeService? service;

  @override
  State<AccessCodePage> createState() => _AccessCodePageState();
}

class _AccessCodePageState extends State<AccessCodePage> {
  late final AccessCodeService _service;
  late final TextEditingController _controller;
  _AccessState _state = _AccessState.idle;
  String? _resolvedResourceId;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? AccessCodeService();
    _controller = TextEditingController(
      text: AccessCodeService.normalize(widget.initialCode ?? ''),
    );

    if (AccessCodeService.isValid(widget.initialCode ?? '')) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _search());
    }
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
    final busy = _state == _AccessState.searching ||
        _state == _AccessState.success;

    final pose = switch (_state) {
      _AccessState.success => MamPose.happy,
      _AccessState.invalid || _AccessState.error => MamPose.confused,
      _ => MamPose.search,
    };

    final status = switch (_state) {
      _AccessState.searching => _pick(
          locale,
          'Mầm đang tìm nội dung của bạn...',
          'Mầm is finding your content...',
        ),
      _AccessState.success => _pick(
          locale,
          'Mầm tìm thấy rồi!',
          'Mầm found it!',
        ),
      _AccessState.invalid => _pick(
          locale,
          'Hình như mã này chưa đúng. Bạn kiểm tra lại 6 chữ số trong sổ tay nhé.',
          'This code does not seem to match. Check the 6 digits in your workbook and try again.',
        ),
      _AccessState.error => _pick(
          locale,
          'Mầm chưa thể tìm nội dung lúc này. Bạn thử lại sau nhé.',
          'Mầm cannot look up the content right now. Please try again later.',
        ),
      _ => _pick(
          locale,
          'Nhập mã 6 số được in cạnh QR hoặc hoạt động trong sổ tay.',
          'Enter the 6-digit code printed beside a QR or activity in your workbook.',
        ),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('PsyCapNote'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 36),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppTheme.outline),
                ),
                child: Column(
                  children: [
                    MamIllustration(
                      pose: pose,
                      size: 128,
                      semanticLabel: status,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _pick(locale, 'Nhập mã từ sổ tay', 'Enter workbook code'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      status,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.inkMuted,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _controller,
                      enabled: !busy,
                      autofocus: widget.initialCode == null,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.go,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        letterSpacing: 8,
                        fontWeight: FontWeight.w800,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        hintText: '------',
                        counterText: '',
                      ),
                      onSubmitted: (_) => _search(),
                      onChanged: (_) {
                        if (_state == _AccessState.invalid ||
                            _state == _AccessState.error) {
                          setState(() => _state = _AccessState.idle);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: busy ? null : _search,
                        icon: _state == _AccessState.searching
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.search_rounded),
                        label: Text(_pick(locale, 'Khám phá', 'Explore')),
                      ),
                    ),
                    if (_resolvedResourceId != null &&
                        _state == _AccessState.success) ...[
                      const SizedBox(height: 8),
                      Text(
                        _resolvedResourceId!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.inkMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _search() async {
    if (_state == _AccessState.searching ||
        _state == _AccessState.success) {
      return;
    }

    final code = AccessCodeService.normalize(_controller.text);
    if (code.length != 6) {
      setState(() {
        _state = _AccessState.invalid;
        _resolvedResourceId = null;
      });
      return;
    }

    setState(() {
      _state = _AccessState.searching;
      _resolvedResourceId = null;
    });

    try {
      final resourceId = await _service.resolveResourceId(code);
      if (!mounted) return;
      if (resourceId == null) {
        setState(() => _state = _AccessState.invalid);
        return;
      }

      setState(() {
        _state = _AccessState.success;
        _resolvedResourceId = resourceId;
      });

      await Future<void>.delayed(const Duration(milliseconds: 550));
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.resourceById(resourceId),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _state = _AccessState.error);
    }
  }
}

String _pick(String locale, String vi, String en) => locale == 'en' ? en : vi;
