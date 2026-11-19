import 'api/polaris_api.dart';
import 'celestial_object.dart';
import 'celestial_object_repository.dart';
import 'result.dart';

class ApiCelestialObjectRepository implements CelestialObjectRepository {
  ApiCelestialObjectRepository(this._api);

  final PolarisApi _api;

  @override
  Future<Result<List<CelestialObject>>> fetchAll() async {
    try {
      return Ok(await _api.catalogObjects());
    } catch (error) {
      return Err(_message(error));
    }
  }

  @override
  Future<Result<CelestialObject>> fetchById(String id) async {
    try {
      return Ok(await _api.catalogObject(id));
    } catch (error) {
      return Err(_message(error));
    }
  }

  @override
  Future<Result<CelestialObject>> create(CelestialObject object) async =>
      const Err('Каталог объектов управляется сервером');

  @override
  Future<Result<CelestialObject>> update(CelestialObject object) async =>
      const Err('Каталог объектов управляется сервером');

  @override
  Future<Result<void>> delete(String id) async =>
      const Err('Каталог объектов управляется сервером');

  String _message(Object error) {
    if (error is ApiException) return error.message;
    return 'Не удалось загрузить каталог: $error';
  }
}
