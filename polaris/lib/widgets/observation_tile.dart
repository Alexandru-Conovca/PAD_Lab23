import 'package:flutter/material.dart';

import '../models/domain_models.dart';
import 'stat_badge.dart';

class ObservationTile extends StatelessWidget {
  const ObservationTile({super.key, required this.observation});

  final Observation observation;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: scheme.secondaryContainer,
          foregroundColor: scheme.onSecondaryContainer,
          child: const Icon(Icons.visibility),
        ),
        title: Text(observation.objectName),
        subtitle: Text(
          '${observation.dateTime}\n${observation.location}',
          maxLines: 2,
        ),
        isThreeLine: true,
        trailing: StatBadge(
          label: observation.status,
          color: observation.status == 'Verified'
              ? scheme.tertiary
              : scheme.secondary,
        ),
      ),
    );
  }
}
