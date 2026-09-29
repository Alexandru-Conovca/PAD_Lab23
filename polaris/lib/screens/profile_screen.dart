import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../widgets/observation_tile.dart';
import '../widgets/quest_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(appBar: AppBar(title: const Text('Your profile'), actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined))]), body: ListView(padding: const EdgeInsets.all(16), children: [
      Row(children: [CircleAvatar(radius: 32, backgroundColor: scheme.primaryContainer, foregroundColor: scheme.onPrimaryContainer, child: const Text('AC', style: TextStyle(fontWeight: FontWeight.w700))), const SizedBox(width: 14), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(currentUser.name, style: Theme.of(context).textTheme.headlineSmall), Text(currentUser.level, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant))])]),
      const SizedBox(height: 24),
      Row(children: [_Metric(value: '12', label: 'Quests completed'), _Metric(value: '34', label: 'Objects observed'), _Metric(value: '7', label: 'Level')]),
      const SizedBox(height: 28),
      Text('Current quest', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 10), QuestCard(quest: quests[1]),
      const SizedBox(height: 24),
      Text('Recent activity', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 10),
      ...observations.take(2).map((observation) => ObservationTile(observation: observation)),
    ]));
  }
}

class _Metric extends StatelessWidget { const _Metric({required this.value, required this.label}); final String value; final String label; @override Widget build(BuildContext context) => Expanded(child: Column(children: [Text(value, style: Theme.of(context).textTheme.headlineSmall), const SizedBox(height: 3), Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall)])); }