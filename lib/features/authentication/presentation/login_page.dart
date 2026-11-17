import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/mam_illustration.dart';
import '../data/auth_services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.authService, this.returnRoute});

  final AuthService? authService;
  final String? returnRoute;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final AuthService _authService = widget.authService ?? AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  static const _ink = Color(0xFF24352A);
  static const _muted = Color(0xFF6B756E);
  static const _leaf = Color(0xFF4F7658);
  static const _paper = Color(0xFFFFFCF8);
  static const _outline = Color(0xFFE4DBCE);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFAF7F1),
              Color(0xFFF2F6F0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, viewport) {
              final wide = viewport.maxWidth >= 920;
              final horizontalPadding = wide ? 28.0 : 18.0;
              final availableWidth = (viewport.maxWidth - horizontalPadding * 2)
                  .clamp(0.0, 1100.0);
              final brandWidth = wide ? 540.0 : availableWidth;
              final formWidth = wide ? 430.0 : availableWidth;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  wide ? 28 : 18,
                  horizontalPadding,
                  28,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      spacing: 24,
                      runSpacing: 18,
                      children: [
                        SizedBox(
                          width: brandWidth,
                          child: _BrandPanel(
                            strings: strings,
                            languageCode: languageCode,
                            compact: !wide,
                          ),
                        ),
                        SizedBox(
                          width: formWidth,
                          child: _buildFormCard(
                            context,
                            strings,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(
    BuildContext context,
    AppLocalizations strings,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
      decoration: BoxDecoration(
        color: _paper.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0E5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.lock_open_rounded,
                    color: _leaf,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    strings.login,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: _ink,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              strings.loginSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _muted,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: InputDecoration(
                labelText: strings.email,
                prefixIcon: const Icon(Icons.mail_outline_rounded),
                filled: true,
                fillColor: const Color(0xFFFFFEFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              validator: (value) => _validateEmail(value, strings),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                labelText: strings.password,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                filled: true,
                fillColor: const Color(0xFFFFFEFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                suffixIcon: IconButton(
                  tooltip: _obscurePassword
                      ? strings.showPassword
                      : strings.hidePassword,
                  onPressed: () => setState(
                    () => _obscurePassword = !_obscurePassword,
                  ),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return strings.passwordRequired;
                }
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _isLoading ? null : _resetPassword,
                child: Text(strings.forgotPassword),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _leaf,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      strings.login,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
            ),
            const SizedBox(height: 18),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  strings.noAccount,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _muted,
                  ),
                ),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.of(context).pushReplacementNamed(
                            AppRoutes.register,
                            arguments: widget.returnRoute,
                          ),
                  child: Text(strings.register),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _validateEmail(String? value, AppLocalizations strings) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return strings.emailRequired;
    }
    if (!email.contains('@') || !email.contains('.')) {
      return strings.invalidEmail;
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _authService.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        widget.returnRoute ?? AppRoutes.home,
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      debugPrint(
        'LOGIN AUTH ERROR: ${error.code} | ${error.message}',
      );
      if (!mounted) return;
      _showMessage(_messageForAuthError(error.code));
    } catch (_) {
      if (!mounted) return;
      _showMessage(AppLocalizations.of(context).somethingWrong);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resetPassword() async {
    final strings = AppLocalizations.of(context);
    final emailError = _validateEmail(_emailController.text, strings);
    if (emailError != null) {
      _showMessage(strings.enterEmailToReset);
      return;
    }

    try {
      await _authService.sendPasswordResetEmail(_emailController.text);
      if (!mounted) return;
      _showMessage(strings.resetEmailSent);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      _showMessage(_messageForAuthError(error.code));
    } catch (_) {
      if (!mounted) return;
      _showMessage(strings.somethingWrong);
    }
  }

  String _messageForAuthError(String code) {
    final strings = AppLocalizations.of(context);
    return switch (code) {
      'invalid-email' => strings.invalidEmail,
      'invalid-credential' ||
      'user-not-found' ||
      'wrong-password' =>
        strings.wrongCredentials,
      'too-many-requests' => strings.tooManyRequests,
      _ => strings.somethingWrong,
    };
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel({
    required this.strings,
    required this.languageCode,
    required this.compact,
  });

  final AppLocalizations strings;
  final String languageCode;
  final bool compact;

  static const _ink = Color(0xFF24352A);
  static const _muted = Color(0xFF667168);
  static const _leaf = Color(0xFF4F7658);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        compact ? 18 : 30,
        compact ? 16 : 26,
        compact ? 18 : 30,
        compact ? 16 : 26,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEFF5EC),
            Color(0xFFF8F0E6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE3D9C9)),
      ),
      child: compact
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const MamIllustration(
                  pose: MamPose.book,
                  size: 88,
                  semanticLabel: 'Mầm',
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        strings.appName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: _ink,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _pick(
                          languageCode,
                          'Tiếp tục một bước nhỏ cùng Mầm.',
                          'Continue one small step with Mầm.',
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _muted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.62),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.eco_rounded, size: 18, color: _leaf),
                      const SizedBox(width: 7),
                      Text(
                        'SEED2START',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: _leaf,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Center(
                  child: MamIllustration(
                    pose: MamPose.book,
                    size: 185,
                    semanticLabel: 'Mầm',
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  strings.appName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: _ink,
                    fontWeight: FontWeight.w900,
                    height: 1.18,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _pick(
                    languageCode,
                    'Kết nối sổ tay giấy với những hoạt động số vừa đủ để bạn tiếp tục hành trình của riêng mình.',
                    'Connect the printed workbook with just enough digital support to continue your own journey.',
                  ),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: _muted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                _Feature(
                  icon: Icons.menu_book_outlined,
                  text: _pick(
                    languageCode,
                    '14 bài đồng hành cùng sổ tay',
                    '14 guided workbook lessons',
                  ),
                  color: const Color(0xFFF4EBDD),
                ),
                const SizedBox(height: 10),
                _Feature(
                  icon: Icons.spa_outlined,
                  text: _pick(
                    languageCode,
                    'Mầm gợi mở để bạn tự tìm câu trả lời',
                    'Mầm prompts you to find your own answers',
                  ),
                  color: const Color(0xFFE6EFE3),
                ),
                const SizedBox(height: 10),
                _Feature(
                  icon: Icons.lock_outline_rounded,
                  text: _pick(
                    languageCode,
                    'Tiến trình học tập thuộc về riêng bạn',
                    'Your learning progress stays personal',
                  ),
                  color: const Color(0xFFF1ECE6),
                ),
              ],
            ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF4F7658),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF34483A),
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _pick(String languageCode, String vi, String en) {
  return languageCode.toLowerCase().startsWith('en') ? en : vi;
}
