import 'package:flutter/material.dart';

import '../../../core/localization/app_locale_controller.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/app_routes.dart';
import '../../authentication/data/auth_services.dart';
import '../../gamification/data/gamification_service.dart';
import '../data/profile_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    this.profileService,
    this.authService,
    this.gamificationService,
  });

  final ProfileService? profileService;
  final AuthService? authService;
  final GamificationService? gamificationService;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileService _profileService =
      widget.profileService ?? ProfileService();
  late final AuthService _authService = widget.authService ?? AuthService();
  late final GamificationService _gamificationService =
      widget.gamificationService ?? GamificationService();
  final AppLocaleController _localeController = AppLocaleController.instance;

  bool _savingLanguage = false;
  bool _signingOut = false;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final user = _profileService.currentUser;

    return SafeArea(
      child: StreamBuilder<Map<String, dynamic>?>(
        stream: _profileService.watchProfile(),
        builder: (context, snapshot) {
          final data = snapshot.data;
          final displayName = _displayName(data, user?.displayName, strings);
          final storedLocale = data?['locale'] as String?;

          _syncLocale(storedLocale);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.profile,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      strings.profileSubtitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _ProfileHeader(
                      displayName: displayName,
                      email: user?.email ?? '',
                      editLabel: strings.editName,
                      onEdit: () => _editName(displayName),
                    ),
                    const SizedBox(height: 18),
                    StreamBuilder<GamificationState>(
                      stream: _gamificationService.watchState(),
                      builder: (context, progressSnapshot) {
                        final progress =
                            progressSnapshot.data ?? GamificationState.empty();
                        return _ProgressCard(
                          level: progress.level,
                          xp: progress.xp,
                          streak: progress.streak,
                          strings: strings,
                          onTap: () => Navigator.of(context)
                              .pushNamed(AppRoutes.progress),
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    _SectionTitle(title: strings.language),
                    const SizedBox(height: 10),
                    _LanguageCard(
                      selectedLanguageCode:
                          _localeController.locale.languageCode,
                      vietnameseLabel: strings.vietnamese,
                      englishLabel: strings.english,
                      saving: _savingLanguage,
                      onChanged: _changeLanguage,
                    ),
                    const SizedBox(height: 28),
                    _SectionTitle(title: strings.privacy),
                    const SizedBox(height: 10),
                    _InfoCard(
                      icon: Icons.lock_outline_rounded,
                      title: strings.privateByDefault,
                      body: strings.privacyDescription,
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _signingOut ? null : _signOut,
                        icon: _signingOut
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.logout_rounded),
                        label: Text(strings.logout),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _displayName(
    Map<String, dynamic>? data,
    String? authDisplayName,
    AppLocalizations strings,
  ) {
    final firestoreName = (data?['displayName'] as String?)?.trim();
    if (firestoreName != null && firestoreName.isNotEmpty) {
      return firestoreName;
    }

    final authName = authDisplayName?.trim();
    if (authName != null && authName.isNotEmpty) {
      return authName;
    }

    return strings.student;
  }

  void _syncLocale(String? storedLocale) {
    if (storedLocale == null ||
        !_localeController.supports(storedLocale) ||
        _localeController.locale.languageCode == storedLocale) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _localeController.setLocaleCode(storedLocale);
      }
    });
  }

  Future<void> _changeLanguage(String languageCode) async {
    if (_savingLanguage ||
        _localeController.locale.languageCode == languageCode) {
      return;
    }

    setState(() => _savingLanguage = true);

    try {
      await _profileService.updateLocale(languageCode);
      _localeController.setLocaleCode(languageCode);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).somethingWrong)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _savingLanguage = false);
      }
    }
  }

  Future<void> _editName(String currentName) async {
    final strings = AppLocalizations.of(context);
    final controller = TextEditingController(text: currentName);

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(strings.editName),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 40,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: strings.name),
            onSubmitted: (value) {
              final cleanValue = value.trim();
              if (cleanValue.isNotEmpty) {
                Navigator.of(dialogContext).pop(cleanValue);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: () {
                final cleanValue = controller.text.trim();
                if (cleanValue.isNotEmpty) {
                  Navigator.of(dialogContext).pop(cleanValue);
                }
              },
              child: Text(strings.save),
            ),
          ],
        );
      },
    );

    controller.dispose();
    if (newName == null || newName == currentName || !mounted) {
      return;
    }

    try {
      await _profileService.updateDisplayName(newName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.profileUpdated)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.somethingWrong)),
        );
      }
    }
  }

  Future<void> _signOut() async {
    if (_signingOut) return;

    setState(() => _signingOut = true);
    try {
      await _authService.signOut();
      _localeController.resetToDefault();

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.root,
        (route) => false,
      );
    } catch (_) {
      if (mounted) {
        setState(() => _signingOut = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).somethingWrong)),
        );
      }
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.displayName,
    required this.email,
    required this.editLabel,
    required this.onEdit,
  });

  final String displayName;
  final String email;
  final String editLabel;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final initial = displayName.trim().isEmpty
        ? '?'
        : displayName.trim().substring(0, 1).toUpperCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: colors.primaryContainer,
            foregroundColor: colors.onPrimaryContainer,
            child: Text(
              initial,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: editLabel,
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.level,
    required this.xp,
    required this.streak,
    required this.strings,
    required this.onTap,
  });

  final int level;
  final int xp;
  final int streak;
  final AppLocalizations strings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.secondaryContainer,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$level',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.personalProgress,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${strings.totalXp(xp)} · ${strings.streakDays(streak)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: colors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.selectedLanguageCode,
    required this.vietnameseLabel,
    required this.englishLabel,
    required this.saving,
    required this.onChanged,
  });

  final String selectedLanguageCode;
  final String vietnameseLabel;
  final String englishLabel;
  final bool saving;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: RadioGroup<String>(
        groupValue: selectedLanguageCode,
        onChanged: (value) {
          if (saving || value == null) return;
          onChanged(value);
        },
        child: Column(
          children: [
            RadioListTile<String>(
              value: 'vi',
              title: Text(vietnameseLabel),
            ),
            Divider(height: 1, color: colors.outlineVariant),
            RadioListTile<String>(
              value: 'en',
              title: Text(englishLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.4,
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
