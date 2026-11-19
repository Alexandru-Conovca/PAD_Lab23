import 'celestial_object.dart';
import 'result.dart';

abstract class FavoritesRepository {
  Future<Result<List<CelestialObject>>> fetchAll();

  Future<Result<void>> add(String objectId);

  Future<Result<void>> remove(String objectId);
}
