import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../data/reflection_service.dart';

class ReflectionPage extends StatefulWidget {
  const ReflectionPage({super.key});

  @override
  State<ReflectionPage> createState() => _ReflectionPageState();
}

class _ReflectionPageState extends State<ReflectionPage> {
  final ReflectionService _service = ReflectionService();
  bool _savingMood = false;
  bool _writing = false;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(strings.reflection)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _writing ? null : () => _openReflectionEditor(),
        icon: const Icon(Icons.edit_outlined),
        label: Text(strings.writeReflection),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 104),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.reflectionPageSubtitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      strings.howAreYouToday,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      strings.moodPrompt,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 14),
                    StreamBuilder<DailyMood?>(
                      stream: _service.watchTodayMood(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return _InlineMessage(
                            icon: Icons.cloud_off_outlined,
                            message: strings.moodLoadError,
                          );
                        }

                        return _MoodPicker(
                          selected: snapshot.data?.mood,
                          saving: _savingMood,
                          strings: strings,
                          onSelected: _saveMood,
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            strings.recentReflections,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed:
                              _writing ? null : () => _openReflectionEditor(),
                          icon: const Icon(Icons.add_rounded),
                          label: Text(strings.addReflection),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    StreamBuilder<List<ReflectionEntry>>(
                      stream: _service.watchReflections(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (snapshot.hasError) {
                          return _InlineMessage(
                            icon: Icons.cloud_off_outlined,
                            message: strings.reflectionLoadError,
                          );
                        }

                        final entries =
                            snapshot.data ?? const <ReflectionEntry>[];
                        if (entries.isEmpty) {
                          return _EmptyReflection(strings: strings);
                        }

                        return Column(
                          children: [
                            for (var index = 0;
                                index < entries.length;
                                index++) ...[
                              _ReflectionCard(
                                entry: entries[index],
                                strings: strings,
                                onEdit: () => _openReflectionEditor(
                                    entry: entries[index]),
                                onDelete: () => _confirmDelete(entries[index]),
                              ),
                              if (index != entries.length - 1)
                                const SizedBox(height: 12),
                            ],
                          ],
                        );
                      },
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

  Future<void> _saveMood(MoodLevel mood) async {
    if (_savingMood) return;
    setState(() => _savingMood = true);
    try {
      await _service.saveTodayMood(mood);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).somethingWrong)),
        );
      }
    } finally {
      if (mounted) setState(() => _savingMood = false);
    }
  }

  Future<void> _openReflectionEditor({ReflectionEntry? entry}) async {
    if (_writing) return;

    final content = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _ReflectionEditor(entry: entry),
    );

    if (content == null || !mounted) return;

    setState(() => _writing = true);
    try {
      if (entry == null) {
        await _service.createReflection(content);
      } else {
        await _service.updateReflection(
          reflectionId: entry.id,
          content: content,
        );
      }

      if (mounted) {
        final strings = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              entry == null
                  ? strings.reflectionSaved
                  : strings.reflectionUpdated,
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).somethingWrong)),
        );
      }
    } finally {
      if (mounted) setState(() => _writing = false);
    }
  }

  Future<void> _confirmDelete(ReflectionEntry entry) async {
    final strings = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.deleteReflection),
        content: Text(strings.deleteReflectionConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(strings.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _service.deleteReflection(entry.id);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).somethingWrong)),
        );
      }
    }
  }
}

class _MoodPicker extends StatelessWidget {
  const _MoodPicker({
    required this.selected,
    required this.saving,
    required this.strings,
    required this.onSelected,
  });

  final MoodLevel? selected;
  final bool saving;
  final AppLocalizations strings;
  final ValueChanged<MoodLevel> onSelected;

  @override
  Widget build(BuildContext context) {
    final items = <({MoodLevel mood, IconData icon, String label})>[
      (
        mood: MoodLevel.veryLow,
        icon: Icons.sentiment_very_dissatisfied_outlined,
        label: strings.moodVeryLow
      ),
      (
        mood: MoodLevel.low,
        icon: Icons.sentiment_dissatisfied_outlined,
        label: strings.moodLow
      ),
      (
        mood: MoodLevel.okay,
        icon: Icons.sentiment_neutral_outlined,
        label: strings.moodOkay
      ),
      (
        mood: MoodLevel.good,
        icon: Icons.sentiment_satisfied_outlined,
        label: strings.moodGood
      ),
      (
        mood: MoodLevel.great,
        icon: Icons.sentiment_very_satisfied_outlined,
        label: strings.moodGreat
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final item in items)
              SizedBox(
                width: compact
                    ? (constraints.maxWidth - 10) / 2
                    : (constraints.maxWidth - 40) / 5,
                child: _MoodButton(
                  icon: item.icon,
                  label: item.label,
                  selected: selected == item.mood,
                  onTap: saving ? null : () => onSelected(item.mood),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MoodButton extends StatelessWidget {
  const _MoodButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: selected ? colors.primaryContainer : colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: selected ? colors.primary : colors.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected
                    ? colors.onPrimaryContainer
                    : colors.onSurfaceVariant,
              ),
              const SizedBox(height: 7),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReflectionCard extends StatelessWidget {
  const _ReflectionCard({
    required this.entry,
    required this.strings,
    required this.onEdit,
    required this.onDelete,
  });

  final ReflectionEntry entry;
  final AppLocalizations strings;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final date = entry.updatedAt ?? entry.createdAt;
    final dateLabel = date == null
        ? strings.justNow
        : MaterialLocalizations.of(context).formatMediumDate(date);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_outlined,
                  size: 20, color: colors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  dateLabel,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                tooltip: strings.reflectionActions,
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                      value: 'edit', child: Text(strings.editReflection)),
                  PopupMenuItem(value: 'delete', child: Text(strings.delete)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            entry.content,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _EmptyReflection extends StatelessWidget {
  const _EmptyReflection({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.edit_note_rounded, size: 42, color: colors.primary),
          const SizedBox(height: 10),
          Text(
            strings.noReflectionsYet,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            strings.noReflectionsBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _ReflectionEditor extends StatefulWidget {
  const _ReflectionEditor({this.entry});

  final ReflectionEntry? entry;

  @override
  State<_ReflectionEditor> createState() => _ReflectionEditorState();
}

class _ReflectionEditorState extends State<_ReflectionEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.entry?.content ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 18, 20, 20 + bottomInset),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.entry == null
                  ? strings.writeReflection
                  : strings.editReflection,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(strings.reflectionPrompt),
            const SizedBox(height: 14),
            TextField(
              controller: _controller,
              autofocus: true,
              minLines: 4,
              maxLines: 8,
              maxLength: 800,
              decoration: InputDecoration(
                hintText: strings.reflectionHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final content = _controller.text.trim();
                  if (content.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(strings.reflectionRequired)),
                    );
                    return;
                  }
                  Navigator.of(context).pop(content);
                },
                child: Text(strings.saveReflection),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
