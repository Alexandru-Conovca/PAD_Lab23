import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/app_data.dart';
import '../widgets/observation_tile.dart';
import '../widgets/quest_card.dart';

Future<void> _logout(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogCtx) {
      return AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        content: const Text(
          'Вы действительно хотите завершить текущую сессию?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx, false);
            },
            child: const Text('Нет'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogCtx, true);
            },
            child: const Text('Да, выйти'),
          ),
        ],
      );
    },
  );

  if (ok == true && context.mounted) {
    context.go('/login');
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your profile'),
        actions: [
          IconButton(
            tooltip: 'Выйти из аккаунта',
            onPressed: () => _logout(context),
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
                child: const Text(
                  'AC',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentUser.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    currentUser.level,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _Metric(value: '12', label: 'Quests completed'),
              _Metric(value: '34', label: 'Objects observed'),
              _Metric(value: '7', label: 'Level'),
            ],
          ),
          const SizedBox(height: 28),
          Text('Current quest', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          QuestCard(quest: quests[1]),
          const SizedBox(height: 24),
          Text(
            'Recent activity',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          ...observations
              .take(2)
              .map((observation) => ObservationTile(observation: observation)),
        ],
      ),
    );
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
