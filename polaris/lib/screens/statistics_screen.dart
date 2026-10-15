import 'package:flutter/material.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final stats = [
      ('Planets', 1.0, '8 / 8'),
      ('Nebulae', 0.45, '5 / 11'),
      ('Galaxies', 0.2, '2 / 10'),
      ('Stars', 0.7, '14 / 20'),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Detailed statistics')),
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
                        '68%',
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
          Text('By object type', style: Theme.of(context).textTheme.titleLarge),
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
                          stat.$3,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: stat.$2,
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
