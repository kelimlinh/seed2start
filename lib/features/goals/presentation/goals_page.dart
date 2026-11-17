import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../data/goal_service.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final GoalService _goalService = GoalService();
  bool _writing = false;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.goals),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _writing ? null : () => _openGoalEditor(),
        icon: const Icon(Icons.add_rounded),
        label: Text(strings.addGoal),
      ),
      body: SafeArea(
        top: false,
        child: StreamBuilder<List<GoalItem>>(
          stream: _goalService.watchGoals(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _MessageState(
                icon: Icons.cloud_off_outlined,
                title: strings.goalsLoadError,
                body: strings.tryAgainLater,
              );
            }

            final goals = snapshot.data ?? const <GoalItem>[];
            final active = goals.where((goal) => !goal.completed).toList();
            final completed = goals.where((goal) => goal.completed).toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 104),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.goalsPageSubtitle,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colors.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _GoalOverview(
                          activeCount: active.length,
                          completedCount: completed.length,
                          strings: strings,
                        ),
                        const SizedBox(height: 26),
                        if (goals.isEmpty)
                          _EmptyGoals(
                            strings: strings,
                            onCreate: () => _openGoalEditor(),
                          )
                        else ...[
                          if (active.isNotEmpty) ...[
                            _SectionTitle(
                              title: strings.activeGoals,
                              count: active.length,
                            ),
                            const SizedBox(height: 10),
                            for (final goal in active) ...[
                              _GoalCard(
                                goal: goal,
                                strings: strings,
                                onEdit: () => _openGoalEditor(goal: goal),
                                onComplete: () => _completeGoal(goal),
                                onDelete: () => _confirmDelete(goal),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ],
                          if (completed.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            _SectionTitle(
                              title: strings.completedGoals,
                              count: completed.length,
                            ),
                            const SizedBox(height: 10),
                            for (final goal in completed) ...[
                              _GoalCard(
                                goal: goal,
                                strings: strings,
                                onEdit: () => _openGoalEditor(goal: goal),
                                onComplete: null,
                                onDelete: () => _confirmDelete(goal),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _openGoalEditor({GoalItem? goal}) async {
    if (_writing) return;

    final draft = await showModalBottomSheet<_GoalDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _GoalEditor(goal: goal),
    );

    if (draft == null || !mounted) return;

    setState(() => _writing = true);
    try {
      if (goal == null) {
        await _goalService.createGoal(
          title: draft.title,
          description: draft.description,
          timeframe: draft.timeframe,
        );
      } else {
        await _goalService.updateGoal(
          goalId: goal.id,
          title: draft.title,
          description: draft.description,
          timeframe: draft.timeframe,
          progress: draft.progress,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              goal == null
                  ? stringsOf(context).goalCreated
                  : stringsOf(context).goalUpdated,
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(stringsOf(context).somethingWrong)),
        );
      }
    } finally {
      if (mounted) setState(() => _writing = false);
    }
  }

  Future<void> _completeGoal(GoalItem goal) async {
    try {
      await _goalService.completeGoal(goal.id);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(stringsOf(context).somethingWrong)),
        );
      }
    }
  }

  Future<void> _confirmDelete(GoalItem goal) async {
    final strings = stringsOf(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.deleteGoal),
        content: Text(strings.deleteGoalConfirm),
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
      await _goalService.deleteGoal(goal.id);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(stringsOf(context).somethingWrong)),
        );
      }
    }
  }

  AppLocalizations stringsOf(BuildContext context) =>
      AppLocalizations.of(context);
}

class _GoalOverview extends StatelessWidget {
  const _GoalOverview({
    required this.activeCount,
    required this.completedCount,
    required this.strings,
  });

  final int activeCount;
  final int completedCount;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: _OverviewValue(
              value: activeCount.toString(),
              label: strings.inProgress,
            ),
          ),
          Container(
            width: 1,
            height: 44,
            color: colors.onPrimaryContainer.withValues(alpha: 0.18),
          ),
          Expanded(
            child: _OverviewValue(
              value: completedCount.toString(),
              label: strings.done,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewValue extends StatelessWidget {
  const _OverviewValue({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colors.onPrimaryContainer,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onPrimaryContainer,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            count.toString(),
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.strings,
    required this.onEdit,
    required this.onComplete,
    required this.onDelete,
  });

  final GoalItem goal;
  final AppLocalizations strings;
  final VoidCallback onEdit;
  final VoidCallback? onComplete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final timeframeLabel = goal.timeframe == GoalTimeframe.shortTerm
        ? strings.shortTerm
        : strings.longTerm;

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: goal.completed,
              onChanged: onComplete == null ? null : (_) => onComplete!(),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          goal.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            decoration: goal.completed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _TimeframeChip(label: timeframeLabel),
                    ],
                  ),
                  if (goal.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      goal.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: goal.progress / 100,
                          minHeight: 7,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${goal.progress}%',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<_GoalAction>(
              tooltip: strings.goalActions,
              onSelected: (action) {
                switch (action) {
                  case _GoalAction.edit:
                    onEdit();
                    break;
                  case _GoalAction.delete:
                    onDelete();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _GoalAction.edit,
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined),
                      const SizedBox(width: 10),
                      Text(strings.editGoal),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: _GoalAction.delete,
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline_rounded),
                      const SizedBox(width: 10),
                      Text(strings.delete),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _GoalAction { edit, delete }

class _TimeframeChip extends StatelessWidget {
  const _TimeframeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: colors.onSecondaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyGoals extends StatelessWidget {
  const _EmptyGoals({required this.strings, required this.onCreate});

  final AppLocalizations strings;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(Icons.flag_outlined, size: 42, color: colors.primary),
          const SizedBox(height: 14),
          Text(
            strings.noGoalsYet,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            strings.noGoalsBody,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add_rounded),
            label: Text(strings.createFirstGoal),
          ),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
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

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 46, color: colors.primary),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                body,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalDraft {
  const _GoalDraft({
    required this.title,
    required this.description,
    required this.timeframe,
    required this.progress,
  });

  final String title;
  final String description;
  final GoalTimeframe timeframe;
  final int progress;
}

class _GoalEditor extends StatefulWidget {
  const _GoalEditor({this.goal});

  final GoalItem? goal;

  @override
  State<_GoalEditor> createState() => _GoalEditorState();
}

class _GoalEditorState extends State<_GoalEditor> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late GoalTimeframe _timeframe;
  late int _progress;

  @override
  void initState() {
    super.initState();
    final goal = widget.goal;
    _titleController = TextEditingController(text: goal?.title ?? '');
    _descriptionController =
        TextEditingController(text: goal?.description ?? '');
    _timeframe = goal?.timeframe ?? GoalTimeframe.shortTerm;
    _progress = goal?.progress ?? 0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final editing = widget.goal != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        18,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        editing ? strings.editGoal : strings.newGoal,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _titleController,
                  autofocus: !editing,
                  maxLength: 80,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: strings.goalTitle,
                    hintText: strings.goalTitleHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  maxLength: 240,
                  minLines: 2,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: strings.goalDescription,
                    hintText: strings.goalDescriptionHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  strings.goalTimeframe,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<GoalTimeframe>(
                  segments: [
                    ButtonSegment(
                      value: GoalTimeframe.shortTerm,
                      label: Text(strings.shortTerm),
                      icon: const Icon(Icons.bolt_outlined),
                    ),
                    ButtonSegment(
                      value: GoalTimeframe.longTerm,
                      label: Text(strings.longTerm),
                      icon: const Icon(Icons.landscape_outlined),
                    ),
                  ],
                  selected: {_timeframe},
                  onSelectionChanged: (selection) {
                    setState(() => _timeframe = selection.first);
                  },
                ),
                if (editing) ...[
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          strings.progress,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        '$_progress%',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _progress.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 10,
                    label: '$_progress%',
                    onChanged: (value) {
                      setState(() => _progress = value.round());
                    },
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submit,
                    child: Text(
                        editing ? strings.saveChanges : strings.createGoal),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).goalTitleRequired)),
      );
      return;
    }

    Navigator.of(context).pop(
      _GoalDraft(
        title: title,
        description: _descriptionController.text.trim(),
        timeframe: _timeframe,
        progress: _progress,
      ),
    );
  }
}
