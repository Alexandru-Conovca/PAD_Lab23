import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/favorites_model.dart';
import '../widgets/celestial_object_card.dart';
import '../widgets/error_view.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          IconButton(
            onPressed: () => favorites.load(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: switch ((favorites.isLoading, favorites.errorMessage)) {
        (true, _) => const Center(child: CircularProgressIndicator()),
        (false, final String? errorMessage) when errorMessage != null => Center(
          child: ErrorView(message: errorMessage, onRetry: favorites.load),
        ),
        _ when favorites.items.isEmpty => const Center(
          child: Text('No favorite objects yet.'),
        ),
        _ => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: favorites.items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, index) {
            final object = favorites.items[index];
            return CelestialObjectCard(
              object: object,
              onTap: () => context.push('/catalog/objects/${object.id}'),
            );
          },
        ),
      },
    );
  }
}
