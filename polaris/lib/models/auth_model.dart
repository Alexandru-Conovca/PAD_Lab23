import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/api/api_client.dart';
import '../data/api/polaris_api.dart';
import 'domain_models.dart';

class AuthModel extends ChangeNotifier {
  AuthModel(this._api, this._client);

  static const _accessTokenKey = 'polaris.access_token';
  static const _refreshTokenKey = 'polaris.refresh_token';
  static const _userKey = 'polaris.user';

  final PolarisApi _api;
  final PolarisApiClient _client;

  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;
  User? _user;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  User? get user => _user;

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString(_accessTokenKey);
    final refreshToken = prefs.getString(_refreshTokenKey);
    final encodedUser = prefs.getString(_userKey);

    if (accessToken == null || refreshToken == null || encodedUser == null) {
      return;
    }

    try {
      final userJson = jsonDecode(encodedUser);
      if (userJson is! Map<String, dynamic>) return;
      _client.accessToken = accessToken;
      _client.refreshToken = refreshToken;
      _user = User(
        id: userJson['id'] is int ? userJson['id'] as int : null,
        name: userJson['name']?.toString() ?? '',
        email: userJson['email']?.toString() ?? '',
        level: userJson['level']?.toString() ?? 'Astronomer',
        role: userJson['role']?.toString(),
      );
      _isAuthenticated = true;
      notifyListeners();
    } catch (_) {
      await _clearStoredSession();
    }
  }

  Future<String?> login(String email, String password) =>
      _authenticate(() => _api.login(email: email, password: password));

  Future<String?> register(String name, String email, String password) =>
      _authenticate(
        () => _api.register(name: name, email: email, password: password),
      );

  Future<void> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _clearStoredSession();
      _isAuthenticated = false;
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> _authenticate(Future<AuthSession> Function() request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final session = await request();
      await _applySession(session);
      return null;
    } catch (error) {
      _errorMessage = _message(error);
      notifyListeners();
      return _errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _applySession(AuthSession session) async {
    _client.accessToken = session.accessToken;
    _client.refreshToken = session.refreshToken;
    _user = session.user;
    _isAuthenticated = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, session.accessToken);
    await prefs.setString(_refreshTokenKey, session.refreshToken);
    await prefs.setString(
      _userKey,
      jsonEncode({
        'id': session.user.id,
        'name': session.user.name,
        'email': session.user.email,
        'level': session.user.level,
        'role': session.user.role,
      }),
    );
  }

  Future<void> handleTokensRefreshed(
    String accessToken,
    String refreshToken,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  Future<void> handleSessionExpired() async {
    await _clearStoredSession();
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }

  Future<void> _clearStoredSession() async {
    _client.clearSession();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userKey);
  }

  String _message(Object error) {
    if (error is ApiException) return error.message;
    return 'Ошибка авторизации: $error';
  }
}
