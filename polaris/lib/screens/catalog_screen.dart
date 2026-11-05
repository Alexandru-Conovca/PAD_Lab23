import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/mock_data.dart';
import '../models/favorites_model.dart';
import '../widgets/celestial_object_card.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: ListView(
        children: [
          ...celestialObjects.map(
            (object) => CelestialObjectCard(
              object: object,
              onTap: () {
                context.push('/catalog/objects/${object.id}');
              },
            ),
          ),
        ],
      ),
    );
  }
}
