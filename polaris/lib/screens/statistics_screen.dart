import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/celestial_objects_model.dart';
import '../models/observations_model.dart';
import '../models/quests_model.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final observations = context.watch<ObservationsModel>();
    final quests = context.watch<QuestsModel>();
    final catalog = context.watch<CelestialObjectsModel>();
    final scheme = Theme.of(context).colorScheme;

    final verified = observations.items
        .where((item) => item.status == 'VERIFIED')
        .length;
    final pending = observations.items
        .where((item) => item.status == 'PENDING')
        .length;
    final rejected = observations.items
        .where((item) => item.status == 'REJECTED')
        .length;
    final completedQuests = quests.myQuests
        .where((item) => item.status == 'completed')
        .length;
    final activeQuests = quests.myQuests
        .where((item) => item.status == 'in_progress')
        .length;
    final observedIds = observations.items
        .map((item) => item.objectId)
        .whereType<String>()
        .toSet();
    final catalogCoverage = catalog.items.isEmpty
        ? 0.0
        : (observedIds.length / catalog.items.length).clamp(0.0, 1.0);

    final stats = [
      ('Verified observations', verified, observations.items.length),
      ('Pending verification', pending, observations.items.length),
      ('Rejected observations', rejected, observations.items.length),
      ('Completed quests', completedQuests, quests.myQuests.length),
      ('Active quests', activeQuests, quests.myQuests.length),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Icon(Icons.insights, size: 40, color: scheme.primary),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${(catalogCoverage * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const Text('Catalogue explored'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Your activity', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...stats.map(
            (stat) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(stat.$1)),
                        Text(
                          '${stat.$2} / ${stat.$3}',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: stat.$3 == 0 ? 0 : stat.$2 / stat.$3,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
