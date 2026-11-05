import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/celestial_object_repository.dart';
import 'data/mock_celestial_object_repository.dart';
import 'data/mock_telescope_repository.dart';
import 'data/telescope_repository.dart';
import 'models/celestial_objects_model.dart';
import 'models/favorites_model.dart';
import 'models/telescope_model.dart';
import 'router.dart';

void main() {
  final repository = MockCelestialObjectRepository();

  runApp(
    MultiProvider(
      providers: [
        Provider<CelestialObjectRepository>.value(value: repository),
        Provider<TelescopeRepository>(
          create: (_) => MockTelescopeRepository(),
        ),
        ChangeNotifierProvider(
          create: (_) => CelestialObjectsModel(repository)..load(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              TelescopeModel(context.read<TelescopeRepository>())
                ..load('sw'),
        ),
        ChangeNotifierProvider(create: (_) => FavoritesModel()),
      ],
      child: const Polaris(),
    ),
  );
}

class Polaris extends StatelessWidget {
  const Polaris({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Polaris',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      routerConfig: router,
    );
  }
}
