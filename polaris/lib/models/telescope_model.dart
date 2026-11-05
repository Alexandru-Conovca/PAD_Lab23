import 'package:flutter/foundation.dart';

import '../data/result.dart';
import '../data/telescope_repository.dart';
import 'domain_models.dart';

class TelescopeModel extends ChangeNotifier {
  TelescopeModel(this._repository);

  final TelescopeRepository _repository;

  Telescope? _telescope;

  Telescope? get telescope => _telescope;

  Future<void> load(String id) async {
    switch (await _repository.fetchById(id)) {
      case Ok(value: final telescope):
        _telescope = telescope;
      case Err():
        _telescope = null;
    }
    notifyListeners();
  }

  Future<String?> update(Telescope telescope) async {
    switch (await _repository.update(telescope)) {
      case Ok(value: final updated):
        _telescope = updated;
        notifyListeners();
        return null;
      case Err(msg: final message):
        return message;
    }
  }
}
