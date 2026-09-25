import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/domain_models.dart';
import '../widgets/celestial_object_card.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key, required this.onObjectTap});

  final ValueChanged<CelestialObject> onObjectTap;

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Sky catalogue')), body: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
    const TextField(decoration: InputDecoration(hintText: 'Search objects', prefixIcon: Icon(Icons.search))),
    const SizedBox(height: 14),
    SizedBox(height: 42, child: ListView(scrollDirection: Axis.horizontal, children: const [ChoiceChip(label: Text('All'), selected: true), SizedBox(width: 8), ChoiceChip(label: Text('Planets'), selected: false), SizedBox(width: 8), ChoiceChip(label: Text('Deep Sky'), selected: false), SizedBox(width: 8), ChoiceChip(label: Text('Stars'), selected: false)])),
    const SizedBox(height: 14),
    ...celestialObjects.map((object) => Padding(padding: const EdgeInsets.only(bottom: 10), child: CelestialObjectCard(object: object, onTap: () => onObjectTap(object)))),
  ]));
}