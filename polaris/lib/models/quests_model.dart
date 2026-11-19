import 'package:flutter/foundation.dart';

import '../data/api/polaris_api.dart';
import 'auth_model.dart';
import 'domain_models.dart';

class QuestsModel extends ChangeNotifier {
  QuestsModel(this._api, {this.auth}) {
    auth?.addListener(_handleAuthChanged);
    _handleAuthChanged();
  }

  final PolarisApi _api;
  final AuthModel? auth;

  bool _isLoading = false;
  String? _errorMessage;
  List<Quest> _quests = const [];
  List<QuestProgress> _myQuests = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Quest> get quests => List.unmodifiable(_quests);
  List<QuestProgress> get myQuests => List.unmodifiable(_myQuests);

  Quest? byId(String id) {
    for (final quest in _quests) {
      if (quest.id == id) return quest;
    }
    return null;
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _quests = await _api.quests();
      _myQuests = await _api.myQuests();
    } catch (error) {
      _errorMessage = _message(error);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Quest?> generate({String difficulty = 'beginner'}) async {
    try {
      final quest = await _api.generateQuest(difficulty: difficulty);
      _quests = [quest, ..._quests.where((item) => item.id != quest.id)];
      notifyListeners();
      return quest;
    } catch (error) {
      _errorMessage = _message(error);
      notifyListeners();
      return null;
    }
  }

  Future<QuestProgress?> start(String questId) =>
      _updateProgress(() => _api.startQuest(questId));

  Future<QuestProgress?> progress(String questId) =>
      _updateProgress(() => _api.questProgress(questId));

  Future<QuestProgress?> complete(String questId) =>
      _updateProgress(() => _api.completeQuest(questId));

  Future<QuestProgress?> _updateProgress(
    Future<QuestProgress> Function() request,
  ) async {
    try {
      final progress = await request();
      _myQuests = [
        progress,
        ..._myQuests.where((item) => item.questId != progress.questId),
      ];
      notifyListeners();
      return progress;
    } catch (error) {
      _errorMessage = _message(error);
      notifyListeners();
      return null;
    }
  }

  String _message(Object error) {
    if (error is ApiException) return error.message;
    return 'Не удалось загрузить квесты: $error';
  }

  void clear() {
    _quests = const [];
    _myQuests = const [];
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
