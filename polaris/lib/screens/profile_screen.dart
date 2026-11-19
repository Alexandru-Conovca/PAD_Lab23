import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/auth_model.dart';
import '../models/celestial_objects_model.dart';
import '../models/domain_models.dart';
import '../models/observations_model.dart';
import '../models/quests_model.dart';
import '../widgets/observation_tile.dart';
import '../widgets/quest_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthModel>();
    final quests = context.watch<QuestsModel>();
    final observations = context.watch<ObservationsModel>();
    final catalog = context.watch<CelestialObjectsModel>();
    final user = auth.user;
    final scheme = Theme.of(context).colorScheme;
    final completedQuests = quests.myQuests
        .where((quest) => quest.status == 'completed')
        .length;
    QuestProgress? activeQuest;
    for (final quest in quests.myQuests) {
      if (quest.status == 'in_progress') {
        activeQuest = quest;
        break;
      }
    }
    final recent = observations.items.take(2).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your profile'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
                child: Text(
                  _initials(user?.name ?? user?.email ?? '?'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Astronomer',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      user?.email ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _Metric(value: '$completedQuests', label: 'Quests completed'),
              _Metric(
                value: '${observations.items.length}',
                label: 'Objects observed',
              ),
              _Metric(value: user?.level ?? 'User', label: 'Level'),
            ],
          ),
          const SizedBox(height: 28),
          Card(
            child: ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Telescope settings'),
              subtitle: const Text('Aperture, focal length and mount'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/profile/telescope'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.verified_outlined),
              title: const Text('Verify observation'),
              subtitle: const Text('Submit coordinates for automatic check'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/profile/verification'),
            ),
          ),
          const SizedBox(height: 24),
          Text('Current quest', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          if (activeQuest != null)
            QuestCard(
              quest:
                  quests.byId(activeQuest.questId) ??
                  Quest(
                    id: activeQuest.questId,
                    title: activeQuest.questTitle,
                    description: 'Progress: ${activeQuest.progressPercent.toStringAsFixed(0)}%',
                    difficulty: QuestDifficulty.beginner,
                    tasksCount: activeQuest.tasks.length,
                    createdAt: activeQuest.startedAt,
                  ),
            )
          else if (quests.quests.isNotEmpty)
            QuestCard(quest: quests.quests.first)
          else
            const Card(child: ListTile(title: Text('No quests available'))),
          const SizedBox(height: 24),
          Text(
            'Recent activity',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          if (recent.isEmpty)
            const Card(
              child: ListTile(title: Text('No observations yet')),
            )
          else
            ...recent.map(
              (observation) => ObservationTile(
                observation: _withObjectName(observation, catalog),
              ),
            ),
        ],
      ),
    );
  }

  String _initials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  Observation _withObjectName(
    Observation observation,
    CelestialObjectsModel catalog,
  ) {
    final objectId = observation.objectId;
    if (objectId == null) return observation;
    final object = catalog.byId(objectId);
    if (object == null) return observation;
    return Observation(
      id: observation.id,
      objectId: observation.objectId,
      objectName: object.name,
      dateTime: observation.dateTime,
      location: observation.location,
      status: observation.status,
      questId: observation.questId,
      questTitle: observation.questTitle,
      telescopeId: observation.telescopeId,
      latitude: observation.latitude,
      longitude: observation.longitude,
      notes: observation.notes,
      verificationScore: observation.verificationScore,
      verificationReason: observation.verificationReason,
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('Your local session will be cleared.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AuthModel>().logout();
    }
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    ),
  );
}
