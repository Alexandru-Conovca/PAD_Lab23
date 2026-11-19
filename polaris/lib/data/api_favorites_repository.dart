import 'api/polaris_api.dart';
import 'celestial_object.dart';
import 'favorites_repository.dart';
import 'result.dart';

class ApiFavoritesRepository implements FavoritesRepository {
  ApiFavoritesRepository(this._api);

  final PolarisApi _api;

  @override
  Future<Result<List<CelestialObject>>> fetchAll() async {
    try {
      return Ok(await _api.favorites());
    } catch (error) {
      return Err(_message(error));
    }
  }

  @override
  Future<Result<void>> add(String objectId) async {
    try {
      await _api.addFavorite(objectId);
      return const Ok(null);
    } catch (error) {
      return Err(_message(error));
    }
  }

  @override
  Future<Result<void>> remove(String objectId) async {
    try {
      await _api.removeFavorite(objectId);
      return const Ok(null);
    } catch (error) {
      return Err(_message(error));
    }
  }

  String _message(Object error) {
    if (error is ApiException) return error.message;
    return 'Не удалось обновить избранное: $error';
  }
}
