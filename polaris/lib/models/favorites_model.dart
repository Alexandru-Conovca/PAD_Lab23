import 'package:flutter/foundation.dart';

import '../data/celestial_object.dart';

class FavoritesModel extends ChangeNotifier {
  final List<CelestialObject> _items = [];

  List<CelestialObject> get items => List.unmodifiable(_items);

  int get count => _items.length;

  bool contains(CelestialObject object) => _items.contains(object);

  void add(CelestialObject object) {
    if (_items.contains(object)) {
      return;
    }

    _items.add(object);
    notifyListeners();
  }

  void remove(CelestialObject object) {
    if (!_items.remove(object)) {
      return;
    }

    notifyListeners();
  }

  void toggle(CelestialObject object) {
    if (_items.contains(object)) {
      _items.remove(object);
    } else {
      _items.add(object);
    }

    notifyListeners();
  }
}
