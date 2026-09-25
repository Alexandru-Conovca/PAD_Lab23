import 'package:flutter/material.dart';
import '../models/domain_models.dart';
import 'stat_badge.dart';

class CelestialObjectCard extends StatelessWidget {
  const CelestialObjectCard({super.key, required this.object, this.onTap});

  final CelestialObject object;
  final VoidCallback? onTap;

  IconData get _icon => switch (object.type) {
    CelestialType.planet => Icons.public,
    CelestialType.galaxy => Icons.blur_on,
    CelestialType.nebula => Icons.cloud,
    CelestialType.star => Icons.star,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(backgroundColor: scheme.primaryContainer, foregroundColor: scheme.onPrimaryContainer, child: Icon(_icon)),
        title: Text(object.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('${object.constellation}  •  Mag ${object.magnitude.toStringAsFixed(1)}'),
        trailing: StatBadge(label: object.isVisibleNow ? 'Visible' : 'Later', color: object.isVisibleNow ? scheme.tertiary : scheme.outline),
      ),
    );
  }
}