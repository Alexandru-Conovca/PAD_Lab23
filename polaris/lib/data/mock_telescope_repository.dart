import '../models/domain_models.dart';
import 'app_data.dart';
import 'result.dart';
import 'telescope_repository.dart';

class MockTelescopeRepository implements TelescopeRepository {
  MockTelescopeRepository() : _telescope = telescopes.first;

  Telescope _telescope;

  static const _latency = Duration(milliseconds: 800);
  static const _errNetwork = 'Сервер не отвечает — повторите попытку';
  static const _errNotFound = 'Телескоп не существует';
  bool simulateError = false;

  @override
  Future<Result<Telescope>> fetchById(String id) async {
    await Future.delayed(_latency);
    if (simulateError) {
      return const Err(_errNetwork);
    }
    if (_telescope.id != id) {
      return const Err(_errNotFound);
    }
    return Ok(_telescope);
  }

  @override
  Future<Result<Telescope>> update(Telescope telescope) async {
    await Future.delayed(_latency);
    if (simulateError) {
      return const Err(_errNetwork);
    }
    if (_telescope.id != telescope.id) {
      return const Err(_errNotFound);
    }
    _telescope = telescope;
    return Ok(_telescope);
  }
}
