import 'package:flutter/material.dart';
import '../widgets/stat_badge.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(appBar: AppBar(title: const Text('Verify observation')), body: ListView(padding: const EdgeInsets.all(16), children: [
      Text('Record M31', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 8),
      Text('Point your telescope toward Andromeda and capture a steady observation. Polaris will compare your coordinates and timestamp.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant)),
      const SizedBox(height: 22),
      Container(height: 230, decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(16), border: Border.all(color: scheme.outlineVariant)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_outlined, size: 48, color: scheme.primary), const SizedBox(height: 12), const Text('Add a photo or observation log'), const SizedBox(height: 5), Text('EXIF coordinates supported', style: Theme.of(context).textTheme.bodySmall)])),
      const SizedBox(height: 18),
      const Row(children: [Icon(Icons.check_circle_outline), SizedBox(width: 8), Text('Coordinates captured: 47.0101° N, 28.8638° E')]),
      const SizedBox(height: 10),
      StatBadge(label: 'Готово к проверке', color: scheme.tertiary),
      const SizedBox(height: 24),
      FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.auto_awesome), label: const Text('Выполнить автопроверку')),
    ]));
  }
}