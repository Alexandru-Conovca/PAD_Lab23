import 'package:flutter/foundation.dart';

import '../data/celestial_object.dart';
import '../data/celestial_object_repository.dart';
import '../data/result.dart';

class CelestialObjectsModel extends ChangeNotifier {
  CelestialObjectsModel(this._repository);

  final CelestialObjectRepository _repository;

  List<CelestialObject> _items = [];
  bool isLoading = false;
  String? errorMessage;

  List<CelestialObject> get items => List.unmodifiable(_items);

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await _repository.fetchAll();
    switch (result) {
      case Ok(value: final objects):
        _items = objects;
      case Err(msg: final message):
        errorMessage = message;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<Result<CelestialObject>> fetchById(String id) {
    return _repository.fetchById(id);
  }
}
