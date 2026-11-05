import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/celestial_object_repository.dart';
import 'data/mock_celestial_object_repository.dart';
import 'models/celestial_objects_model.dart';
import 'models/favorites_model.dart';
import 'router.dart';

void main() {
  runApp(const Polaris());
}

class Polaris extends StatelessWidget {
  const Polaris({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<CelestialObjectRepository>(
          create: (_) => MockCelestialObjectRepository(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              CelestialObjectsModel(context.read<CelestialObjectRepository>())
                ..load(),
        ),
        ChangeNotifierProvider(create: (_) => FavoritesModel()),
      ],
      child: MaterialApp.router(
        title: 'Polaris',
        theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
        routerConfig: router,
      ),
    );
  }
}
