import 'package:flutter/foundation.dart';

import '../data/api/polaris_api.dart';
import '../models/domain_models.dart';
import 'auth_model.dart';

class ObservationsModel extends ChangeNotifier {
  ObservationsModel(this._api, {this.auth}) {
    auth?.addListener(_handleAuthChanged);
    _handleAuthChanged();
  }

  final PolarisApi _api;
  final AuthModel? auth;

  bool _isLoading = false;
  String? _errorMessage;
  List<Observation> _items = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Observation> get items => List.unmodifiable(_items);

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _api.observations();
    } catch (error) {
      _errorMessage = _message(error);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> create({
    required String celestialObjectId,
    required DateTime observedAt,
    required double latitude,
    required double longitude,
    int? telescopeId,
    String? questId,
    String? locationName,
    String? notes,
  }) async {
    try {
      final observation = await _api.createObservation(
        celestialObjectId: celestialObjectId,
        observedAt: observedAt,
        latitude: latitude,
        longitude: longitude,
        telescopeId: telescopeId,
        questId: questId,
        locationName: locationName,
        notes: notes,
      );
      _items = [observation, ..._items];
      notifyListeners();
      return null;
    } catch (error) {
      return _message(error);
    }
  }

  Future<Observation?> refresh(String id) async {
    try {
      final observation = await _api.observation(id);
      _items = [
        for (final item in _items) item.id == id ? observation : item,
      ];
      notifyListeners();
      return observation;
    } catch (error) {
      _errorMessage = _message(error);
      notifyListeners();
      return null;
    }
  }

  Future<String?> delete(String id) async {
    try {
      await _api.deleteObservation(id);
      _items = _items.where((item) => item.id != id).toList();
      notifyListeners();
      return null;
    } catch (error) {
      return _message(error);
    }
  }

  String _message(Object error) {
    if (error is ApiException) return error.message;
    return 'Не удалось загрузить наблюдения: $error';
  }

  void clear() {
    _items = const [];
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
