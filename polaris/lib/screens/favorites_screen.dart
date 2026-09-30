import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../widgets/celestial_object_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Favorites')), body: ListView.separated(padding: const EdgeInsets.all(16), itemCount: 6, separatorBuilder: (_, _) => const SizedBox(height: 10), itemBuilder: (_, index) => CelestialObjectCard(object: celestialObjects[index + 2])));
}