import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/celestial_objects_model.dart';
import '../widgets/celestial_object_card.dart';

class StarMapScreen extends StatelessWidget {
  const StarMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CelestialObjectsModel>();
    final scheme = Theme.of(context).colorScheme;
    final visible = catalog.items.where((item) => item.isVisibleNow).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Star map'),
        actions: [
          IconButton(
            onPressed: catalog.load,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh catalog',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Container(
            height: 420,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Stack(
              children: [
                const Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(child: Text('N')),
                ),
                const Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(child: Text('S')),
                ),
                const Positioned(
                  top: 0,
                  bottom: 0,
                  left: 16,
                  child: Center(child: Text('W')),
                ),
                const Positioned(
                  top: 0,
                  bottom: 0,
                  right: 16,
                  child: Center(child: Text('E')),
                ),
                Center(
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: scheme.outline, width: 1),
                    ),
                    child: CustomPaint(
                      painter: _StarsPainter(color: scheme.onSurface),
                    ),
                  ),
                ),
                Positioned(
                  top: 120,
                  left: 72,
                  child: _Tag(label: 'Vega', color: scheme.tertiary),
                ),
                Positioned(
                  top: 250,
                  right: 58,
                  child: _Tag(label: 'M31', color: scheme.primary),
                ),
                Positioned(
                  bottom: 120,
                  left: 108,
                  child: _Tag(label: 'Cassiopeia', color: scheme.secondary),
                ),
                Positioned(
                  top: 46,
                  right: 52,
                  child: Icon(Icons.navigation, color: scheme.tertiary),
                ),
                const Positioned(top: 42, right: 44, child: Text('ZENITH')),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Visible tonight', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          if (catalog.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (catalog.errorMessage != null)
            Text(catalog.errorMessage!)
          else if (visible.isEmpty)
            const Text('No objects are marked visible right now.')
          else
            SizedBox(
              height: 170,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: visible.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (_, index) => SizedBox(
                  width: 260,
                  child: CelestialObjectCard(object: visible[index]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontWeight: FontWeight.w700),
    ),
  );
}

class _StarsPainter extends CustomPainter {
  const _StarsPainter({required this.color});
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.8);
    for (final point in const [
      Offset(34, 28),
      Offset(74, 72),
      Offset(126, 42),
      Offset(180, 94),
      Offset(92, 148),
      Offset(152, 174),
      Offset(48, 194),
      Offset(202, 48),
    ]) {
      canvas.drawCircle(point, 2.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarsPainter oldDelegate) =>
      oldDelegate.color != color;
}
