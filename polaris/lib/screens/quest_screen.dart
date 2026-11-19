import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/domain_models.dart';
import '../models/quests_model.dart';
import '../widgets/error_view.dart';
import '../widgets/quest_card.dart';
import '../widgets/stat_badge.dart';

class QuestScreen extends StatefulWidget {
  const QuestScreen({super.key});

  @override
  State<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen> {
  String? _selectedQuestId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<QuestsModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final quests = context.watch<QuestsModel>();
    final selectedQuest = quests.byId(_selectedQuestId ?? '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Observation quests'),
        actions: [
          IconButton(
            onPressed: quests.load,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh quests',
          ),
          IconButton(
            onPressed: () => _generateQuest(context),
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Generate quest',
          ),
        ],
      ),
      body: switch ((quests.isLoading, quests.errorMessage)) {
        (true, _) => const Center(child: CircularProgressIndicator()),
        (false, final String? errorMessage) when errorMessage != null => Center(
          child: ErrorView(message: errorMessage, onRetry: quests.load),
        ),
        _ => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (quests.myQuests.isNotEmpty) ...[
              Text('My missions', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              ...quests.myQuests.map(_MyQuestCard.new),
              const SizedBox(height: 24),
            ],
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Available quests',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _generateQuest(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Generate'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (quests.quests.isEmpty)
              const Card(
                child: ListTile(title: Text('No quests available')),
              )
            else
              ...quests.quests.map(
                (quest) => Column(
                  children: [
                    QuestCard(
                      quest: quest,
                      onTap: () => setState(() => _selectedQuestId = quest.id),
                    ),
                    _QuestActions(quest: quest),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            if (selectedQuest != null) ...[
              const SizedBox(height: 12),
              Text(
                'Checklist',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              ...selectedQuest.tasks.map(
                (task) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${task.stepOrder}'),
                    ),
                    title: Text(task.title),
                    subtitle: Text(task.targetObjectName),
                  ),
                ),
              ),
            ],
          ],
        ),
      },
    );
  }

  Future<void> _generateQuest(BuildContext context) async {
    final difficulty = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Quest difficulty'),
        children: [
          for (final difficulty in ['beginner', 'intermediate', 'advanced'])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, difficulty),
              child: Text(difficulty[0].toUpperCase() + difficulty.substring(1)),
            ),
        ],
      ),
    );
    if (difficulty == null || !context.mounted) return;

    final quest = await context.read<QuestsModel>().generate(
      difficulty: difficulty,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          quest == null ? 'Failed to generate quest' : 'Quest created: ${quest.title}',
        ),
      ),
    );
  }
}

class _MyQuestCard extends StatelessWidget {
  const _MyQuestCard(this.progress);

  final QuestProgress progress;

  @override
  Widget build(BuildContext context) {
    final quests = context.watch<QuestsModel>();
    final quest = quests.byId(progress.questId);
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    progress.questTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                StatBadge(
                  label: progress.status,
                  color: progress.status == 'completed'
                      ? scheme.tertiary
                      : scheme.secondary,
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: (progress.progressPercent / 100).clamp(0.0, 1.0),
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 8),
            Text('${progress.progressPercent.toStringAsFixed(0)}% complete'),
            const SizedBox(height: 10),
            Row(
              children: [
                TextButton(
                  onPressed: () => quests.progress(progress.questId),
                  child: const Text('Refresh'),
                ),
                const Spacer(),
                if (quest != null)
                  TextButton(
                    onPressed: () => quests.complete(progress.questId),
                    child: const Text('Complete'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestActions extends StatelessWidget {
  const _QuestActions({required this.quest});

  final Quest quest;

  @override
  Widget build(BuildContext context) {
    final quests = context.watch<QuestsModel>();
    QuestProgress? progress;
    for (final item in quests.myQuests) {
      if (item.questId == quest.id) {
        progress = item;
        break;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          if (progress == null)
            FilledButton.tonalIcon(
              onPressed: () => quests.start(quest.id),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start'),
            )
          else ...[
            StatBadge(
              label: '${progress.progressPercent.toStringAsFixed(0)}%',
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () => quests.progress(quest.id),
              child: const Text('Progress'),
            ),
            TextButton(
              onPressed: () => quests.complete(quest.id),
              child: const Text('Complete'),
            ),
          ],
        ],
      ),
    );
  }
}
