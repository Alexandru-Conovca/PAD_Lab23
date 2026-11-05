import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/celestial_objects_model.dart';
import '../models/favorites_model.dart';
import '../widgets/celestial_object_card.dart';
import '../widgets/error_view.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CelestialObjectsModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sky catalogue'),
        actions: [
          Consumer<FavoritesModel>(
            builder: (context, favorites, child) => Badge(
              isLabelVisible: favorites.count > 0,
              label: Text('${favorites.count}'),
              child: child,
            ),
            child: IconButton(
              onPressed: () => context.push('/profile/favorites'),
              icon: const Icon(Icons.bookmarks_outlined),
              tooltip: 'Favorites',
            ),
          ),
        ],
      ),
      body: switch ((catalog.isLoading, catalog.errorMessage)) {
        (true, _) => const Center(child: CircularProgressIndicator()),
        (false, final String? errorMessage) when errorMessage != null => Center(
          child: ErrorView(
            message: errorMessage,
            onRetry: () => context.read<CelestialObjectsModel>().load(),
          ),
        ),
        _ => ListView(
          children: [
            ...catalog.items.map(
              (object) => CelestialObjectCard(
                object: object,
                onTap: () {
                  context.push('/catalog/objects/${object.id}');
                },
              ),
            ),
          ],
        ),
      },
    );
  }
}
