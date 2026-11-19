import '../models/domain_models.dart';
import 'api/polaris_api.dart';
import 'result.dart';
import 'telescope_repository.dart';

class ApiTelescopeRepository implements TelescopeRepository {
  ApiTelescopeRepository(this._api);

  final PolarisApi _api;

  @override
  Future<Result<List<Telescope>>> fetchAll() async {
    try {
      return Ok(await _api.equipment());
    } catch (error) {
      return Err(_message(error));
    }
  }

  @override
  Future<Result<Telescope>> fetchById(String id) async {
    try {
      return Ok(await _api.equipmentById(id));
    } catch (error) {
      return Err(_message(error));
    }
  }

  @override
  Future<Result<Telescope>> create(Telescope telescope) async {
    try {
      return Ok(await _api.createEquipment(telescope));
    } catch (error) {
      return Err(_message(error));
    }
  }

  @override
  Future<Result<Telescope>> update(Telescope telescope) async {
    try {
      return Ok(await _api.updateEquipment(telescope));
    } catch (error) {
      return Err(_message(error));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _api.deleteEquipment(id);
      return const Ok(null);
    } catch (error) {
      return Err(_message(error));
    }
  }

  @override
  Future<Result<Telescope>> setActive(String id) async {
    try {
      return Ok(await _api.setActiveEquipment(id));
    } catch (error) {
      return Err(_message(error));
    }
  }

  String _message(Object error) {
    if (error is ApiException) return error.message;
    return 'Ошибка оборудования: $error';
  }
}
