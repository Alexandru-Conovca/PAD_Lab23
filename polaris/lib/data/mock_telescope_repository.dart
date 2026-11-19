import '../models/domain_models.dart';
import 'app_data.dart';
import 'result.dart';
import 'telescope_repository.dart';

class MockTelescopeRepository implements TelescopeRepository {
  MockTelescopeRepository() : _telescopes = List.of(telescopes);

  final List<Telescope> _telescopes;
  int _nextId = 100;
  bool simulateError = false;

  static const _latency = Duration(milliseconds: 800);
  static const _errNetwork = 'Сервер не отвечает — повторите попытку';
  static const _errNotFound = 'Телескоп не существует';

  Future<Result<T>?> _failure<T>() async {
    await Future.delayed(_latency);
    if (simulateError) {
      return const Err(_errNetwork);
    }
    return null;
  }

  @override
  Future<Result<List<Telescope>>> fetchAll() async {
    final failure = await _failure<List<Telescope>>();
    if (failure != null) return failure;
    return Ok(List.of(_telescopes));
  }

  @override
  Future<Result<Telescope>> fetchById(String id) async {
    final failure = await _failure<Telescope>();
    if (failure != null) return failure;
    final telescope = _find(id);
    if (telescope == null) return const Err(_errNotFound);
    return Ok(telescope);
  }

  @override
  Future<Result<Telescope>> create(Telescope telescope) async {
    final failure = await _failure<Telescope>();
    if (failure != null) return failure;
    final created = telescope.copyWith(id: '${_nextId++}');
    _telescopes.add(created);
    return Ok(created);
  }

  @override
  Future<Result<Telescope>> update(Telescope telescope) async {
    final failure = await _failure<Telescope>();
    if (failure != null) return failure;
    final index = _telescopes.indexWhere((item) => item.id == telescope.id);
    if (index == -1) return const Err(_errNotFound);
    _telescopes[index] = telescope;
    return Ok(telescope);
  }

  @override
  Future<Result<void>> delete(String id) async {
    final failure = await _failure<void>();
    if (failure != null) return failure;
    final index = _telescopes.indexWhere((item) => item.id == id);
    if (index == -1) return const Err(_errNotFound);
    _telescopes.removeAt(index);
    return const Ok(null);
  }

  @override
  Future<Result<Telescope>> setActive(String id) async {
    final failure = await _failure<Telescope>();
    if (failure != null) return failure;
    final index = _telescopes.indexWhere((item) => item.id == id);
    if (index == -1) return const Err(_errNotFound);
    for (var i = 0; i < _telescopes.length; i++) {
      _telescopes[i] = _telescopes[i].copyWith(isActive: i == index);
    }
    return Ok(_telescopes[index]);
  }

  Telescope? _find(String id) {
    for (final telescope in _telescopes) {
      if (telescope.id == id) return telescope;
    }
    return null;
  }
}
