import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_data.dart';
import '../widgets/celestial_object_card.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sky catalogue')),
      body: ListView(
        children: [
          ...celestialObjects.map(
            (object) => CelestialObjectCard(
              object: object,
              onTap: () {
                context.push('/objects/${object.id}');
              },
            ),
          ),
        ],
      ),
    );
  }
}
