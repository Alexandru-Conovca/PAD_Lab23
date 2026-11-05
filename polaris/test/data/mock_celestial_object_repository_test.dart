import 'package:flutter_test/flutter_test.dart';
import 'package:polaris/data/celestial_object.dart';
import 'package:polaris/data/mock_celestial_object_repository.dart';
import 'package:polaris/data/result.dart';

void main() {
  late MockCelestialObjectRepository repository;

  setUp(() {
    repository = MockCelestialObjectRepository();
  });

  test(
    'fetchAll returns a copy and supports a simulated network error',
    () async {
      final result = await repository.fetchAll();

      expect(result, isA<Ok<List<CelestialObject>>>());
      final objects = (result as Ok<List<CelestialObject>>).value;
      expect(objects, isNotEmpty);

      objects.clear();
      final secondResult = await repository.fetchAll();
      expect((secondResult as Ok<List<CelestialObject>>).value, isNotEmpty);

      repository.simulateError = true;
      final errorResult = await repository.fetchAll();
      expect(errorResult, isA<Err<List<CelestialObject>>>());
    },
  );

  test('CRUD operations use repository-owned IDs and return errors for missing IDs', () async {
    final source =
        (await repository.fetchAll() as Ok<List<CelestialObject>>).value.first;

    final created = await repository.create(source.copyWith(id: 'client-id'));
    expect(created, isA<Ok<CelestialObject>>());
    final createdObject = (created as Ok<CelestialObject>).value;
    expect(createdObject.id, '1000');

    final updated = await repository.update(
      createdObject.copyWith(id: createdObject.id),
    );
    expect(updated, isA<Ok<CelestialObject>>());

    final deleted = await repository.delete(createdObject.id);
    expect(deleted, isA<Ok<void>>());

    final missing = await repository.fetchById(createdObject.id);
    expect(missing, isA<Err<CelestialObject>>());

    final missingDelete = await repository.delete('missing');
    expect(missingDelete, isA<Err<void>>());
  });
}
