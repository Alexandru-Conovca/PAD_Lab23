import 'package:flutter/foundation.dart';

import '../data/celestial_object.dart';
import '../data/celestial_object_repository.dart';
import '../data/result.dart';

class CelestialObjectsModel extends ChangeNotifier {
  CelestialObjectsModel(this._repository);

  final CelestialObjectRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<CelestialObject> _items = const [];

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  List<CelestialObject> get items => List.unmodifiable(_items);

  CelestialObject? byId(String id) {
    for (final object in _items) {
      if (object.id == id) {
        return object;
      }
    }

    return null;
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.fetchAll();
    switch (result) {
      case Ok(value: final objects):
        _items = objects;
      case Err(msg: final message):
        _errorMessage = message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> add(CelestialObject draft) async {
    switch (await _repository.create(draft)) {
      case Ok(value: final object):
        _items = [..._items, object];
        notifyListeners();
        return null;
      case Err(msg: final message):
        return message;
    }
  }

  Future<String?> remove(String id) async {
    switch (await _repository.delete(id)) {
      case Ok():
        _items = _items.where((object) => object.id != id).toList();
        notifyListeners();
        return null;
      case Err(msg: final message):
        return message;
    }
  }

  Future<String?> update(CelestialObject object) async {
    switch (await _repository.update(object)) {
      case Ok(value: final updated):
        _items = [
          for (final item in _items)
            if (item.id == updated.id) updated else item,
        ];
        notifyListeners();
        return null;
      case Err(msg: final message):
        return message;
    }
  }
}
