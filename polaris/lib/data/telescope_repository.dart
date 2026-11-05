import '../models/domain_models.dart';
import 'result.dart';

abstract class TelescopeRepository {
  Future<Result<Telescope>> fetchById(String id);

  Future<Result<Telescope>> update(Telescope telescope);
}
