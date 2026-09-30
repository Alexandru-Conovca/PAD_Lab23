import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../widgets/observation_tile.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Observation history')), body: ListView.separated(padding: const EdgeInsets.all(16), itemCount: observations.length, separatorBuilder: (_, _) => const SizedBox(height: 10), itemBuilder: (_, index) => ObservationTile(observation: observations[index])));
}