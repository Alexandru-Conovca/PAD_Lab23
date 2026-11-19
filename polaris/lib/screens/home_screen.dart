import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/auth_model.dart';
import '../models/celestial_objects_model.dart';
import '../models/weather_model.dart';
import '../widgets/celestial_object_card.dart';
import '../widgets/error_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onQuest});

  final VoidCallback onQuest;

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CelestialObjectsModel>();
    final weather = context.watch<WeatherModel>();
    final auth = context.watch<AuthModel>();
    final scheme = Theme.of(context).colorScheme;
    final conditions = weather.conditions;
    final current = weather.current;
    final temperature = current['temperature'];
    final humidity = current['relative_humidity'];
    final visibleObjects = catalog.items
        .where((object) => object.isVisibleNow)
        .toList();
    final recommended = visibleObjects.isEmpty
        ? catalog.items
        : visibleObjects;

    return Scaffold(
      appBar: AppBar(
        title: Text('Good evening, ${auth.user?.name ?? 'astronomer'}'),
        actions: [
          IconButton(
            onPressed: weather.load,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh weather',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            'Tonight in the sky',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.wb_sunny_outlined, color: scheme.tertiary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          conditions == null
                              ? 'Loading conditions'
                              : '${conditions.rating} conditions',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (temperature is num)
                        Text(
                          '${temperature.toStringAsFixed(1)}°C',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '${weather.latitude.toStringAsFixed(4)}° N, '
                    '${weather.longitude.toStringAsFixed(4)}° E',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  if (weather.errorMessage case final message?)
                    Text(
                      message,
                      style: TextStyle(color: scheme.error),
                    )
                  else if (conditions != null) ...[
                    Text(
                      'Cloud cover ${conditions.cloudCover.toStringAsFixed(0)}%\n'
                      'Humidity ${humidity is num ? humidity.toStringAsFixed(0) : '--'}%',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Suitability ${(conditions.suitabilityScore * 100).toStringAsFixed(0)}%\n'
                      '${conditions.summary}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ] else
                    const LinearProgressIndicator(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recommended tonight',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/catalog'),
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 170,
            child: switch ((catalog.isLoading, catalog.errorMessage)) {
              (true, _) => const Center(child: CircularProgressIndicator()),
              (false, final String? errorMessage) when errorMessage != null =>
                ErrorView(
                  message: errorMessage,
                  onRetry: () => context.read<CelestialObjectsModel>().load(),
                ),
              _ => ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: recommended.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (_, index) => SizedBox(
                  width: 260,
                  child: CelestialObjectCard(object: recommended[index]),
                ),
              ),
            },
          ),
          const SizedBox(height: 28),
          Card(
            color: scheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Plan a new adventure',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: scheme.onPrimaryContainer),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Let Polaris pick a challenge for tonight.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: scheme.onPrimaryContainer),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: onQuest,
                    child: const Text('Generate quest'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
