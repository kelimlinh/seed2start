import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mam_illustration.dart';
import '../data/access_code_service.dart';

class AccessCodeCard extends StatefulWidget {
  const AccessCodeCard({super.key});

  @override
  State<AccessCodeCard> createState() => _AccessCodeCardState();
}

class _AccessCodeCardState extends State<AccessCodeCard> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.sand,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outline),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 620;
          final mascot = const MamIllustration(
            pose: MamPose.search,
            size: 92,
            semanticLabel: 'Mầm',
          );
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _pick(
                  locale,
                  'Bạn đang cầm sổ tay?',
                  'Have your workbook with you?',
                ),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppTheme.ink,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _pick(
                  locale,
                  'Nhập mã 6 số trong sổ tay để Mầm mở đúng nội dung đồng hành.',
                  'Enter the 6-digit code from your workbook so Mầm can open the matching companion content.',
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.inkMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 13),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.go,
                      maxLength: 6,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        hintText: '------',
                        errorText: _error,
                        counterText: '',
                      ),
                      onSubmitted: (_) => _open(),
                      onChanged: (_) {
                        if (_error != null) {
                          setState(() => _error = null);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    onPressed: _open,
                    icon: const Icon(Icons.search_rounded),
                    label: Text(_pick(locale, 'Khám phá', 'Explore')),
                  ),
                ],
              ),
            ],
          );

          if (wide) {
            return Row(
              children: [
                Expanded(child: content),
                const SizedBox(width: 18),
                mascot,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: content),
                  const SizedBox(width: 10),
                  const MamIllustration(
                    pose: MamPose.search,
                    size: 70,
                    semanticLabel: 'Mầm',
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _open() {
    final locale = Localizations.localeOf(context).languageCode;
    final code = AccessCodeService.normalize(_controller.text);
    if (code.length != 6) {
      setState(() {
        _error = _pick(
          locale,
          'Hãy nhập đủ 6 chữ số trong sổ tay.',
          'Enter all 6 digits from your workbook.',
        );
      });
      return;
    }

    Navigator.of(context).pushNamed(AppRoutes.accessCode(code));
  }
}

String _pick(String locale, String vi, String en) => locale == 'en' ? en : vi;
