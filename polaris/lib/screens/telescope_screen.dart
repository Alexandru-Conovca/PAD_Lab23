import 'package:flutter/material.dart';
import '../data/mock_data.dart';

class TelescopeScreen extends StatelessWidget {
  const TelescopeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final telescope = telescopes.first;
    final ratio = telescope.focalLength / telescope.aperture;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(appBar: AppBar(title: const Text('Telescope setup')), body: ListView(padding: const EdgeInsets.all(16), children: [
      Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(telescope.name, style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 16), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Aperture\n${telescope.aperture} mm'), Text('Focal length\n${telescope.focalLength} mm'), Text('Focal ratio\nf/${ratio.toStringAsFixed(1)}')])]))),
      const SizedBox(height: 24), Text('Equipment profile', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 12),
      const TextField(decoration: InputDecoration(labelText: 'Aperture (mm)', prefixIcon: Icon(Icons.circle_outlined))), const SizedBox(height: 12), const TextField(decoration: InputDecoration(labelText: 'Focal length (mm)', prefixIcon: Icon(Icons.straighten))), const SizedBox(height: 12), const TextField(decoration: InputDecoration(labelText: 'Mount type', prefixIcon: Icon(Icons.alt_route))),
      const SizedBox(height: 24), Card(color: scheme.secondaryContainer, child: Padding(padding: const EdgeInsets.all(18), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.lightbulb_outline, color: scheme.onSecondaryContainer), const SizedBox(width: 12), Expanded(child: Text('Recommended eyepiece for deep sky: 25 mm\nStart with a wide field, then increase magnification as the object settles.', style: TextStyle(color: scheme.onSecondaryContainer)))]))),
    ]));
  }
}