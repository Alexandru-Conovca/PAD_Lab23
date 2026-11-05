import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/favorites_model.dart';
import 'router.dart';

void main() {
  runApp(const Polaris());
}

class Polaris extends StatelessWidget {
  const Polaris({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FavoritesModel(),
      child: MaterialApp.router(
        title: 'Polaris',
        theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
        routerConfig: router,
      ),
    );
  }
}
