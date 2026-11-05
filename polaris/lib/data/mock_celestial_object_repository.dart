import 'celestial_object.dart';
import 'celestial_object_repository.dart';
import 'mock_data.dart';
import 'result.dart';

class MockCelestialObjectRepository implements CelestialObjectRepository {
  MockCelestialObjectRepository() : _objects = List.of(celestialObjects);

  final List<CelestialObject> _objects;
  int _nextId = 1000;
  bool simulateError = false;

  static const _latency = Duration(milliseconds: 800);
  static const _errNetwork = 'Сервер не отвечает — повторите попытку';
  static const _errNotFound = 'Небесный объект не существует';

  Future<Result<T>?> _failure<T>() async {
    await Future.delayed(_latency);
    if (simulateError) {
      return const Err(_errNetwork);
    }
    return null;
  }

  @override
  Future<Result<List<CelestialObject>>> fetchAll() async {
    final failure = await _failure<List<CelestialObject>>();
    if (failure != null) {
      return failure;
    }

    return Ok(List.of(_objects));
  }

  @override
  Future<Result<CelestialObject>> fetchById(String id) async {
    final failure = await _failure<CelestialObject>();
    if (failure != null) {
      return failure;
    }

    final index = _objects.indexWhere((object) => object.id == id);
    if (index == -1) {
      return const Err(_errNotFound);
    }

    return Ok(_objects[index]);
  }

  @override
  Future<Result<CelestialObject>> create(CelestialObject object) async {
    final failure = await _failure<CelestialObject>();
    if (failure != null) {
      return failure;
    }

    final created = object.copyWith(id: '${_nextId++}');
    _objects.add(created);
    return Ok(created);
  }

  @override
  Future<Result<CelestialObject>> update(CelestialObject object) async {
    final failure = await _failure<CelestialObject>();
    if (failure != null) {
      return failure;
    }

    final index = _objects.indexWhere((item) => item.id == object.id);
    if (index == -1) {
      return const Err(_errNotFound);
    }

    _objects[index] = object;
    return Ok(object);
  }

  @override
  Future<Result<void>> delete(String id) async {
    final failure = await _failure<void>();
    if (failure != null) {
      return failure;
    }

    final exists = _objects.any((object) => object.id == id);
    if (!exists) {
      return const Err(_errNotFound);
    }

    _objects.removeWhere((object) => object.id == id);
    return const Ok(null);
  }
}
