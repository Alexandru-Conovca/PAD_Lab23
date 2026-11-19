import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/celestial_objects_model.dart';
import '../models/domain_models.dart';
import '../models/observations_model.dart';
import '../widgets/error_view.dart';
import '../widgets/observation_tile.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final observations = context.watch<ObservationsModel>();
    final catalog = context.watch<CelestialObjectsModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Observation history'),
        actions: [
          IconButton(
            onPressed: observations.load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: switch ((observations.isLoading, observations.errorMessage)) {
        (true, _) => const Center(child: CircularProgressIndicator()),
        (false, final String? errorMessage) when errorMessage != null => Center(
          child: ErrorView(message: errorMessage, onRetry: observations.load),
        ),
        _ when observations.items.isEmpty => const Center(
          child: Text('No observations yet. Submit one from Verify observation.'),
        ),
        _ => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: observations.items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, index) {
            final observation = observations.items[index];
            return ObservationTile(
              observation: _withObjectName(observation, catalog),
            );
          },
        ),
      },
    );
  }

  Observation _withObjectName(
    Observation observation,
    CelestialObjectsModel catalog,
  ) {
    final objectId = observation.objectId;
    if (objectId == null) return observation;
    final object = catalog.byId(objectId);
    if (object == null || object.name == observation.objectName) {
      return observation;
    }
    return Observation(
      id: observation.id,
      objectId: observation.objectId,
      objectName: object.name,
      dateTime: observation.dateTime,
      location: observation.location,
      status: observation.status,
      questId: observation.questId,
      questTitle: observation.questTitle,
      telescopeId: observation.telescopeId,
      latitude: observation.latitude,
      longitude: observation.longitude,
      notes: observation.notes,
      verificationScore: observation.verificationScore,
      verificationReason: observation.verificationReason,
    );
  }
}
