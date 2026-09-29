import 'package:flutter/material.dart';
import '../models/domain_models.dart';
import '../widgets/stat_badge.dart';

class ObjectDetailScreen extends StatelessWidget {
  const ObjectDetailScreen({super.key, required this.object});

  final CelestialObject object;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(appBar: AppBar(title: Text(object.name)), body: ListView(padding: const EdgeInsets.all(16), children: [
      Container(height: 190, decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)), child: Icon(Icons.brightness_3, size: 88, color: scheme.primary)),
      const SizedBox(height: 20),
      Row(children: [Expanded(child: Text(object.name, style: Theme.of(context).textTheme.headlineSmall)), StatBadge(label: object.isVisibleNow ? 'Visible now' : 'Not visible', color: object.isVisibleNow ? scheme.tertiary : scheme.outline)]),
      const SizedBox(height: 8),
      Text(object.description, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant)),
      const SizedBox(height: 24),
      Wrap(spacing: 10, runSpacing: 10, children: [
        _Parameter(label: 'Magnitude', value: object.magnitude.toStringAsFixed(1)), _Parameter(label: 'Distance', value: object.type == CelestialType.galaxy ? '2.5 Mly' : 'Variable'), _Parameter(label: 'Coordinates', value: object.coordinates), _Parameter(label: 'Constellation', value: object.constellation),
      ]),
      const SizedBox(height: 24),
      Row(children: [Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Добавить в квест'))), const SizedBox(width: 10), Expanded(child: FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.bookmark_border), label: const Text('В избранное')))]),
    ]));
  }
}

class _Parameter extends StatelessWidget {
  const _Parameter({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: (MediaQuery.sizeOf(context).width - 42) / 2,
    child: Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: Theme.of(context).textTheme.labelMedium), const SizedBox(height: 5), Text(value, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall)]))),
  );
}