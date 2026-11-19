import 'package:flutter/foundation.dart';

import '../data/api/polaris_api.dart';
import 'domain_models.dart';

class WeatherModel extends ChangeNotifier {
  WeatherModel(this._api, {this.latitude = 47.0101, this.longitude = 28.8638});

  final PolarisApi _api;
  final double latitude;
  final double longitude;

  bool _isLoading = false;
  String? _errorMessage;
  WeatherConditions? _conditions;
  Map<String, dynamic> _current = const {};

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  WeatherConditions? get conditions => _conditions;
  Map<String, dynamic> get current => _current;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _conditions = await _api.weatherConditions(
        latitude: latitude,
        longitude: longitude,
      );
      _current = await _api.weatherCurrent(
        latitude: latitude,
        longitude: longitude,
      );
    } catch (error) {
      _errorMessage = error is ApiException
          ? error.message
          : 'Не удалось загрузить погоду: $error';
    }

    _isLoading = false;
    notifyListeners();
  }
}
