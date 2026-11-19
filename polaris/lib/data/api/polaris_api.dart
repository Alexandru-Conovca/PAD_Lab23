import '../../models/domain_models.dart';
import '../celestial_object.dart';
import 'api_client.dart';

export 'api_client.dart' show ApiException;

class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  final User user;
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
}

class PolarisApi {
  PolarisApi(this._client);

  final PolarisApiClient _client;

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) => _auth('/api/auth/register', {
    'name': name,
    'email': email,
    'password': password,
  });

  Future<AuthSession> login({
    required String email,
    required String password,
  }) => _auth('/api/auth/login', {'email': email, 'password': password});

  Future<User> me({bool auth = true}) async {
    final data = await _client.get('/api/auth/me', auth: auth);
    return _user(_asMap(data));
  }

  Future<AuthSession> _auth(String path, Map<String, dynamic> body) async {
    final data = await _client.post(path, body: body, auth: false);
    final map = _asMap(data);
    final token = _asMap(map['token']);
    return AuthSession(
      user: _user(_asMap(map['user'])),
      accessToken: _string(token['access_token']),
      refreshToken: _string(token['refresh_token']),
      expiresIn: _int(token['expires_in'], fallback: 0),
    );
  }

  Future<List<CelestialObject>> catalogObjects({
    String? search,
    String? type,
    String? constellation,
    bool? visibleOnly,
    int page = 1,
    int limit = 100,
  }) async {
    final data = await _client.get(
      '/api/catalog/objects',
      query: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (type != null && type.isNotEmpty) 'type': type,
        if (constellation != null && constellation.isNotEmpty)
          'constellation': constellation,
        if (visibleOnly != null) 'visible_only': '$visibleOnly',
        'page': '$page',
        'limit': '$limit',
      },
      auth: false,
    );
    final items = _asMap(data)['items'];
    return _asList(items).map(_celestialObject).toList();
  }

  Future<CelestialObject> catalogObject(String id) async {
    final data = await _client.get(
      '/api/catalog/objects/${Uri.encodeComponent(id)}',
      auth: false,
    );
    return _celestialObject(data);
  }

  Future<List<CelestialObject>> favorites() async {
    final data = await _client.get('/api/catalog/favorites');
    return _asList(data)
        .map((item) {
          final favorite = _asMap(item);
          return _celestialObject(
            favorite['object'] ?? favorite['celestial_object'] ?? favorite,
          );
        })
        .where((object) => object.id.isNotEmpty)
        .toList();
  }

  Future<void> addFavorite(String objectId) => _client.post(
    '/api/catalog/favorites',
    body: {'object_id': objectId},
  );

  Future<void> removeFavorite(String objectId) => _client.delete(
    '/api/catalog/favorites/${Uri.encodeComponent(objectId)}',
  );

  Future<List<Telescope>> equipment() async {
    final data = await _client.get('/api/equipment');
    return _asList(data).map(_telescope).toList();
  }

  Future<Telescope> equipmentById(String id) async {
    final data = await _client.get('/api/equipment/$id');
    return _telescope(data);
  }

  Future<Telescope> createEquipment(Telescope telescope) async {
    final data = await _client.post('/api/equipment', body: _telescopeBody(telescope));
    return _telescope(data);
  }

  Future<Telescope> updateEquipment(Telescope telescope) async {
    final data = await _client.put('/api/equipment/${telescope.id}', body: _telescopeBody(telescope));
    return _telescope(data);
  }

  Future<void> deleteEquipment(String id) =>
      _client.delete('/api/equipment/$id');

  Future<Telescope> setActiveEquipment(String id) async {
    final data = await _client.post('/api/equipment/$id/set-active');
    return _telescope(data);
  }

  Future<List<Observation>> observations({String? status, String? questId}) async {
    final data = await _client.get(
      '/api/observations',
      query: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (questId != null && questId.isNotEmpty) 'quest_id': questId,
      },
    );
    return _asList(data).map(_observation).toList();
  }

  Future<Observation> observation(String id) async {
    final data = await _client.get('/api/observations/$id');
    return _observation(data);
  }

  Future<Observation> createObservation({
    required String celestialObjectId,
    required DateTime observedAt,
    required double latitude,
    required double longitude,
    int? telescopeId,
    String? questId,
    String? locationName,
    String? notes,
  }) async {
    final data = await _client.post(
      '/api/observations',
      body: {
        'celestial_object_id': celestialObjectId,
        'telescope_id': telescopeId,
        'quest_id': questId,
        'observed_at': observedAt.toUtc().toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        if (locationName != null && locationName.isNotEmpty)
          'location_name': locationName,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
    return _observation(data);
  }

  Future<void> deleteObservation(String id) =>
      _client.delete('/api/observations/$id');

  Future<List<Quest>> quests({String? difficulty}) async {
    final data = await _client.get(
      '/api/quests',
      query: {
        if (difficulty != null && difficulty.isNotEmpty)
          'difficulty': difficulty,
      },
      auth: false,
    );
    return _asList(data).map(_quest).toList();
  }

  Future<Quest> generateQuest({
    String difficulty = 'beginner',
    String? targetObjectType,
  }) async {
    final data = await _client.post(
      '/api/quests/generate',
      body: {
        'difficulty': difficulty,
        if (targetObjectType != null && targetObjectType.isNotEmpty)
          'target_object_type': targetObjectType,
      },
      auth: false,
    );
    return _quest(data);
  }

  Future<List<QuestProgress>> myQuests() async {
    final data = await _client.get('/api/quests/my');
    return _asList(data).map(_questProgress).toList();
  }

  Future<QuestProgress> startQuest(String questId) async {
    final data = await _client.post('/api/quests/$questId/start');
    return _questProgress(data);
  }

  Future<QuestProgress> questProgress(String questId) async {
    final data = await _client.get('/api/quests/$questId/progress');
    return _questProgress(data);
  }

  Future<QuestProgress> completeQuest(String questId) async {
    final data = await _client.post('/api/quests/$questId/complete');
    return _questProgress(data);
  }

  Future<WeatherConditions> weatherConditions({
    required double latitude,
    required double longitude,
    DateTime? timestamp,
  }) async {
    final data = await _client.get(
      '/api/weather/conditions',
      query: {
        'latitude': '$latitude',
        'longitude': '$longitude',
        if (timestamp != null)
          'timestamp': timestamp.toUtc().toIso8601String(),
      },
      auth: false,
    );
    return _weatherConditions(data);
  }

  Future<Map<String, dynamic>> weatherCurrent({
    required double latitude,
    required double longitude,
  }) async {
    final data = await _client.get(
      '/api/weather/current',
      query: {'latitude': '$latitude', 'longitude': '$longitude'},
      auth: false,
    );
    return _asMap(data);
  }

  Future<VerificationResult> verifyObservation({
    required int observationId,
    required int userId,
    required String celestialObjectId,
    required double latitude,
    required double longitude,
    required DateTime observedAt,
  }) async {
    final data = await _client.post(
      '/api/verification/verify',
      body: {
        'observation_id': observationId,
        'user_id': userId,
        'celestial_object_id': celestialObjectId,
        'latitude': latitude,
        'longitude': longitude,
        'observed_at': observedAt.toUtc().toIso8601String(),
      },
    );
    return _verificationResult(data);
  }

  Future<VerificationResult> verificationResult(int id) async {
    final data = await _client.get('/api/verification/$id');
    return _verificationResult(data);
  }

  Map<String, dynamic> _telescopeBody(Telescope telescope) => {
    'name': telescope.name,
    'aperture': telescope.aperture,
    'focal_length': telescope.focalLength,
    'mount_type': telescope.mountType,
    'is_active': telescope.isActive,
    if (telescope.notes != null) 'notes': telescope.notes,
  };

  User _user(Map<String, dynamic> data) => User(
    id: _nullableInt(data['id']),
    name: _string(data['name'] ?? data['full_name'] ?? data['email']),
    email: _string(data['email']),
    level: 'Amateur Stargazer',
    role: _stringOrNull(data['role']),
  );

  CelestialObject _celestialObject(dynamic value) {
    final data = _asMap(value);
    return CelestialObject(
      id: _string(data['id']),
      name: _string(data['name']),
      type: _celestialType(_string(data['type'])),
      description: _string(data['description']),
      magnitude: _double(data['magnitude']),
      coordinates: _string(data['coordinates_str']),
      constellation: _string(data['constellation']),
      isVisibleNow: data['is_visible_now'] == true,
    );
  }

  Telescope _telescope(dynamic value) {
    final data = _asMap(value);
    final aperture = _int(data['aperture']);
    final focalLength = _int(data['focal_length']);
    return Telescope(
      id: _string(data['id']),
      name: _string(data['name']),
      aperture: aperture,
      focalLength: focalLength,
      mountType: _string(data['mount_type']),
      isActive: data['is_active'] == true,
      notes: _stringOrNull(data['notes']),
      focalRatio: _double(data['focal_ratio'], fallback: aperture == 0 ? 0 : focalLength / aperture),
    );
  }

  Observation _observation(dynamic value) {
    final data = _asMap(value);
    final objectId = _stringOrNull(data['celestial_object_id']);
    final questId = _stringOrNull(data['quest_id']);
    final observedAt = _string(data['observed_at']);
    return Observation(
      id: _string(data['id']),
      objectId: objectId,
      objectName: objectId ?? 'Observation',
      dateTime: _formatDateTime(observedAt),
      location: _stringOrNull(data['location_name']) ??
          '${_double(data['latitude'])}°, ${_double(data['longitude'])}°',
      status: _string(data['status']),
      questId: questId,
      questTitle: questId ?? 'Free observation',
      telescopeId: _nullableInt(data['telescope_id']),
      latitude: _nullableDouble(data['latitude']),
      longitude: _nullableDouble(data['longitude']),
      notes: _stringOrNull(data['notes']),
      verificationScore: _nullableDouble(data['verification_score']),
      verificationReason: _stringOrNull(data['verification_reason']),
    );
  }

  Quest _quest(dynamic value) {
    final data = _asMap(value);
    return Quest(
      id: _string(data['id']),
      title: _string(data['title']),
      description: _string(data['description']),
      difficulty: _questDifficulty(_string(data['difficulty'])),
      tasksCount: _int(data['tasks_count']),
      createdAt: _formatDateTime(_string(data['created_at'])),
      rewardXp: _int(data['reward_xp']),
      tasks: _asList(data['tasks']).map(_questTask).toList(),
    );
  }

  QuestTask _questTask(dynamic value) {
    final data = _asMap(value);
    return QuestTask(
      id: _int(data['id']),
      stepOrder: _int(data['step_order']),
      title: _string(data['title']),
      targetObjectId: _string(data['target_object_id']),
      targetObjectName: _string(data['target_object_name']),
      description: _stringOrNull(data['description']),
    );
  }

  QuestProgress _questProgress(dynamic value) {
    final data = _asMap(value);
    return QuestProgress(
      userQuestId: _int(data['user_quest_id']),
      questId: _string(data['quest_id']),
      questTitle: _string(data['quest_title']),
      status: _string(data['status']),
      progressPercent: _double(data['progress_percent']),
      startedAt: _formatDateTime(_string(data['started_at'])),
      completedAt: _stringOrNull(data['completed_at']) == null
          ? null
          : _formatDateTime(_string(data['completed_at'])),
      tasks: _asList(data['tasks']).map(_questTaskProgress).toList(),
    );
  }

  QuestTaskProgress _questTaskProgress(dynamic value) {
    final data = _asMap(value);
    final completedAt = _stringOrNull(data['completed_at']);
    return QuestTaskProgress(
      taskId: _int(data['task_id']),
      title: _string(data['title']),
      targetObjectId: _string(data['target_object_id']),
      targetObjectName: _string(data['target_object_name']),
      isCompleted: data['is_completed'] == true,
      completedAt: completedAt == null ? null : _formatDateTime(completedAt),
    );
  }

  WeatherConditions _weatherConditions(dynamic value) {
    final data = _asMap(value);
    return WeatherConditions(
      latitude: _double(data['latitude']),
      longitude: _double(data['longitude']),
      timestamp: _formatDateTime(_string(data['timestamp'])),
      temperature: _double(data['temperature']),
      cloudCover: _double(data['cloud_cover']),
      relativeHumidity: _double(data['relative_humidity']),
      suitabilityScore: _double(data['suitability_score']),
      rating: _string(data['rating']),
      isSuitable: data['is_suitable'] == true,
      summary: _string(data['summary']),
      source: _stringOrNull(data['source']),
    );
  }

  VerificationResult _verificationResult(dynamic value) {
    final data = _asMap(value);
    final details = data['details'];
    return VerificationResult(
      id: _int(data['id']),
      observationId: _int(data['observation_id']),
      isValid: data['is_valid'] == true,
      status: _string(data['status']),
      score: _double(data['score']),
      reasons: _string(data['reasons']),
      details: details is Map<String, dynamic> ? details : null,
      verifiedAt: _formatDateTime(_string(data['verified_at'])),
    );
  }

  CelestialType _celestialType(String value) => switch (value.toLowerCase()) {
    'planet' => CelestialType.planet,
    'galaxy' => CelestialType.galaxy,
    'nebula' => CelestialType.nebula,
    _ => CelestialType.star,
  };

  QuestDifficulty _questDifficulty(String value) =>
      switch (value.toLowerCase()) {
        'advanced' => QuestDifficulty.advanced,
        'intermediate' => QuestDifficulty.intermediate,
        _ => QuestDifficulty.beginner,
      };

  Map<String, dynamic> _asMap(dynamic value) =>
      value is Map<String, dynamic> ? value : const {};

  List<dynamic> _asList(dynamic value) => value is List ? value : const [];

  String _string(dynamic value) => value?.toString() ?? '';

  String? _stringOrNull(dynamic value) {
    final text = value?.toString();
    return text == null || text.isEmpty ? null : text;
  }

  int _int(dynamic value, {int fallback = 0}) =>
      value is int ? value : int.tryParse(value?.toString() ?? '') ?? fallback;

  int? _nullableInt(dynamic value) {
    if (value == null) return null;
    return _int(value);
  }

  double _double(dynamic value, {double fallback = 0}) =>
      value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '') ?? fallback;

  double? _nullableDouble(dynamic value) {
    if (value == null) return null;
    return _double(value);
  }

  String _formatDateTime(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    final local = parsed.toLocal();
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(local.day)}.${two(local.month)}.${local.year} ${two(local.hour)}:${two(local.minute)}';
  }
}
