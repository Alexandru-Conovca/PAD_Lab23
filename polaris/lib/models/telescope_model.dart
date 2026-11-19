import 'package:flutter/foundation.dart';

import '../data/result.dart';
import '../data/telescope_repository.dart';
import 'auth_model.dart';
import 'domain_models.dart';

class TelescopeModel extends ChangeNotifier {
  TelescopeModel(this._repository, {this.auth}) {
    auth?.addListener(_handleAuthChanged);
    _handleAuthChanged();
  }

  final TelescopeRepository _repository;
  final AuthModel? auth;

  bool _isLoading = false;
  String? _errorMessage;
  List<Telescope> _items = const [];
  Telescope? _selected;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Telescope> get items => List.unmodifiable(_items);
  Telescope? get telescope => _selected;
  Telescope? byId(String id) {
    for (final telescope in _items) {
      if (telescope.id == id) return telescope;
    }
    return null;
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    switch (await _repository.fetchAll()) {
      case Ok(value: final telescopes):
        _items = telescopes;
        _selected = _firstActive(_items) ?? _firstOrNull(_items);
      case Err(msg: final message):
        _errorMessage = message;
        _items = const [];
        _selected = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  void select(Telescope telescope) {
    _selected = telescope;
    notifyListeners();
  }

  Future<String?> add(Telescope telescope) => _save(() => _repository.create(telescope));

  Future<String?> update(Telescope telescope) =>
      _save(() => _repository.update(telescope));

  Future<String?> delete(String id) async {
    switch (await _repository.delete(id)) {
      case Ok():
        _items = _items.where((item) => item.id != id).toList();
        if (_selected?.id == id) {
          _selected = _firstActive(_items) ?? _firstOrNull(_items);
        }
        notifyListeners();
        return null;
      case Err(msg: final message):
        return message;
    }
  }

  Future<String?> setActive(String id) async {
    switch (await _repository.setActive(id)) {
      case Ok(value: final telescope):
        _items = [
          for (final item in _items)
            item.id == telescope.id
                ? telescope
                : item.copyWith(isActive: false),
        ];
        _selected = telescope;
        notifyListeners();
        return null;
      case Err(msg: final message):
        return message;
    }
  }

  Future<String?> _save(Future<Result<Telescope>> Function() request) async {
    switch (await request()) {
      case Ok(value: final telescope):
        final index = _items.indexWhere((item) => item.id == telescope.id);
        if (index == -1) {
          _items = [..._items, telescope];
        } else {
          _items = [
            for (final item in _items) item.id == telescope.id ? telescope : item,
          ];
        }
        _selected = telescope;
        notifyListeners();
        return null;
      case Err(msg: final message):
        return message;
    }
  }

  Telescope? _firstActive(List<Telescope> items) {
    for (final item in items) {
      if (item.isActive) return item;
    }
    return null;
  }

  Telescope? _firstOrNull(List<Telescope> items) =>
      items.isEmpty ? null : items.first;

  void clear() {
    _items = const [];
    _selected = null;
    _errorMessage = null;
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
