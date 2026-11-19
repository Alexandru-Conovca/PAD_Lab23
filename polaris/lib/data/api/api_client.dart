import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound => statusCode == 404;

  @override
  String toString() => message;
}

class PolarisApiClient {
  PolarisApiClient({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      baseUrl = (baseUrl ??
              const String.fromEnvironment(
                'POLARIS_API_BASE_URL',
                defaultValue: 'http://localhost:8080',
              ))
          .replaceAll(RegExp(r'/+$'), '');

  final http.Client _client;
  final String baseUrl;

  String? accessToken;
  String? refreshToken;

  Future<void> Function(String accessToken, String refreshToken)?
  onTokensRefreshed;
  Future<void> Function()? onSessionExpired;

  Future<dynamic> get(
    String path, {
    Map<String, String>? query,
    bool auth = true,
  }) => _request('GET', path, query: query, auth: auth);

  Future<dynamic> post(
    String path, {
    Object? body,
    bool auth = true,
  }) => _request('POST', path, body: body, auth: auth);

  Future<dynamic> put(
    String path, {
    Object? body,
    bool auth = true,
  }) => _request('PUT', path, body: body, auth: auth);

  Future<dynamic> delete(String path, {bool auth = true}) =>
      _request('DELETE', path, auth: auth);

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
    bool auth = true,
    bool retried = false,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: query == null || query.isEmpty ? null : query,
    );
    final headers = <String, String>{'Accept': 'application/json'};
    if (body != null) {
      headers['Content-Type'] = 'application/json';
    }
    if (auth && accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    final request = http.Request(method, uri)..headers.addAll(headers);
    if (body != null) {
      request.body = jsonEncode(body);
    }

    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 401 &&
        auth &&
        !retried &&
        refreshToken != null) {
      final refreshed = await _refreshTokens();
      if (refreshed) {
        return _request(
          method,
          path,
          query: query,
          body: body,
          auth: auth,
          retried: true,
        );
      }
    }

    if (response.statusCode == 401 && auth && retried) {
      await onSessionExpired?.call();
    }

    final decoded = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, _errorMessage(decoded, response));
    }
    return decoded;
  }

  Future<bool> _refreshTokens() async {
    final currentRefreshToken = refreshToken;
    if (currentRefreshToken == null) {
      return false;
    }

    try {
      final uri = Uri.parse('$baseUrl/api/auth/refresh');
      final response = await _client.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'refresh_token': currentRefreshToken}),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return false;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return false;
      }
      final nextAccess = decoded['access_token'];
      final nextRefresh = decoded['refresh_token'];
      if (nextAccess is! String || nextRefresh is! String) {
        return false;
      }

      accessToken = nextAccess;
      refreshToken = nextRefresh;
      await onTokensRefreshed?.call(nextAccess, nextRefresh);
      return true;
    } catch (_) {
      return false;
    }
  }

  dynamic _decode(http.Response response) {
    if (response.body.isEmpty) {
      return null;
    }
    try {
      return jsonDecode(response.body);
    } catch (_) {
      return response.body;
    }
  }

  String _errorMessage(dynamic decoded, http.Response response) {
    if (decoded is Map<String, dynamic>) {
      final error = decoded['error'];
      if (error is Map<String, dynamic> && error['message'] != null) {
        return error['message'].toString();
      }
      if (decoded['detail'] != null) {
        return decoded['detail'].toString();
      }
      if (decoded['message'] != null) {
        return decoded['message'].toString();
      }
    }
    if (decoded is String && decoded.isNotEmpty) {
      return decoded;
    }
    return 'Request failed (${response.statusCode})';
  }

  void clearSession() {
    accessToken = null;
    refreshToken = null;
  }

  void close() => _client.close();
}
