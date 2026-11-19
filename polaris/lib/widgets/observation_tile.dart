import 'package:flutter/material.dart';

import '../models/domain_models.dart';
import 'stat_badge.dart';

class ObservationTile extends StatelessWidget {
  const ObservationTile({super.key, required this.observation});

  final Observation observation;

  String get _statusLabel => switch (observation.status.toUpperCase()) {
    'VERIFIED' => 'Verified',
    'REJECTED' => 'Rejected',
    'PENDING' => 'Pending',
    _ => observation.status,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = observation.status.toUpperCase();
    final color = status == 'VERIFIED'
        ? scheme.tertiary
        : status == 'REJECTED'
        ? scheme.error
        : scheme.secondary;

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
        trailing: StatBadge(label: _statusLabel, color: color),
      ),
    );
  }
}
