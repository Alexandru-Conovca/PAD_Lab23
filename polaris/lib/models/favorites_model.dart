import 'package:flutter/foundation.dart';

import '../data/celestial_object.dart';
import '../data/favorites_repository.dart';
import '../data/result.dart';
import 'auth_model.dart';

class FavoritesModel extends ChangeNotifier {
  FavoritesModel(this._repository, {this.auth}) {
    auth?.addListener(_handleAuthChanged);
    _handleAuthChanged();
  }

  final FavoritesRepository _repository;
  final AuthModel? auth;

  bool _isLoading = false;
  String? _errorMessage;
  final List<CelestialObject> _items = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<CelestialObject> get items => List.unmodifiable(_items);
  int get count => _items.length;

  bool contains(CelestialObject object) => containsId(object.id);

  bool containsId(String id) => _items.any((item) => item.id == id);

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    switch (await _repository.fetchAll()) {
      case Ok(value: final objects):
        _items
          ..clear()
          ..addAll(objects);
      case Err(msg: final message):
        _errorMessage = message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> toggle(CelestialObject object) async {
    final result = containsId(object.id)
        ? await _repository.remove(object.id)
        : await _repository.add(object.id);

    switch (result) {
      case Ok():
        if (containsId(object.id)) {
          _items.removeWhere((item) => item.id == object.id);
        } else {
          _items.add(object);
        }
        notifyListeners();
        return null;
      case Err(msg: final message):
        return message;
    }
  }

  void update(CelestialObject object) {
    final index = _items.indexWhere((item) => item.id == object.id);
    if (index == -1) return;
    _items[index] = object;
    notifyListeners();
  }

  void remove(CelestialObject object) {
    final index = _items.indexWhere((item) => item.id == object.id);
    if (index == -1) return;
    _items.removeAt(index);
    notifyListeners();
  }

  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }

  void _handleAuthChanged() {
    if (auth?.isAuthenticated == true) {
      load();
    } else {
      clear();
    }
  }

  @override
  void dispose() {
    auth?.removeListener(_handleAuthChanged);
    super.dispose();
  }
}
