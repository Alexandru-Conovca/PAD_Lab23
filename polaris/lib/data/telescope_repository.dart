import '../models/domain_models.dart';
import 'result.dart';

abstract class TelescopeRepository {
  Future<Result<List<Telescope>>> fetchAll();

  Future<Result<Telescope>> fetchById(String id);

  Future<Result<Telescope>> create(Telescope telescope);

  Future<Result<Telescope>> update(Telescope telescope);

  Future<Result<void>> delete(String id);

  Future<Result<Telescope>> setActive(String id);
}
