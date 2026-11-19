import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'data/api/api_client.dart';
import 'data/api/polaris_api.dart';
import 'data/api_celestial_object_repository.dart';
import 'data/api_favorites_repository.dart';
import 'data/api_telescope_repository.dart';
import 'data/celestial_object_repository.dart';
import 'data/favorites_repository.dart';
import 'data/telescope_repository.dart';
import 'models/auth_model.dart';
import 'models/celestial_objects_model.dart';
import 'models/favorites_model.dart';
import 'models/observations_model.dart';
import 'models/quests_model.dart';
import 'models/telescope_model.dart';
import 'models/weather_model.dart';
import 'router.dart';

String _apiBaseUrl() {
  const configured = String.fromEnvironment('POLARIS_API_BASE_URL');
  if (configured.isNotEmpty) {
    return configured;
  }
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:8080';
  }
  return 'http://localhost:8080';
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final client = PolarisApiClient(baseUrl: _apiBaseUrl());
  final api = PolarisApi(client);
  final auth = AuthModel(api, client);
  client.onTokensRefreshed = auth.handleTokensRefreshed;
  client.onSessionExpired = auth.handleSessionExpired;
  await auth.restore();

  runApp(
    MultiProvider(
      providers: [
        Provider<PolarisApiClient>.value(value: client),
        Provider<PolarisApi>.value(value: api),
        ChangeNotifierProvider<AuthModel>.value(value: auth),
        Provider<CelestialObjectRepository>(
          create: (_) => ApiCelestialObjectRepository(api),
        ),
        ChangeNotifierProvider(
          create: (context) => CelestialObjectsModel(
            context.read<CelestialObjectRepository>(),
          )..load(),
        ),
        Provider<TelescopeRepository>(
          create: (_) => ApiTelescopeRepository(api),
        ),
        Provider<FavoritesRepository>(
          create: (_) => ApiFavoritesRepository(api),
        ),
        ChangeNotifierProvider(
          create: (context) => TelescopeModel(
            context.read<TelescopeRepository>(),
            auth: context.read<AuthModel>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => FavoritesModel(
            context.read<FavoritesRepository>(),
            auth: context.read<AuthModel>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              ObservationsModel(api, auth: context.read<AuthModel>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              QuestsModel(api, auth: context.read<AuthModel>()),
        ),
        ChangeNotifierProvider(create: (_) => WeatherModel(api)..load()),
      ],
      child: Polaris(routerConfig: createRouter(auth)),
    ),
  );
}

class Polaris extends StatelessWidget {
  const Polaris({super.key, required this.routerConfig});

  final GoRouter routerConfig;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Polaris',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      routerConfig: routerConfig,
    );
  }
}
