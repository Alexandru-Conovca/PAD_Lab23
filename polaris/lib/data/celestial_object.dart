import '../models/domain_models.dart';

class CelestialObject {
  const CelestialObject({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.magnitude,
    required this.coordinates,
    required this.constellation,
    required this.isVisibleNow,
  });

  final String id;
  final String name;
  final CelestialType type;
  final String description;
  final double magnitude;
  final String coordinates;
  final String constellation;
  final bool isVisibleNow;

  CelestialObject copyWith({String? id}) => CelestialObject(
    id: id ?? this.id,
    name: name,
    type: type,
    description: description,
    magnitude: magnitude,
    coordinates: coordinates,
    constellation: constellation,
    isVisibleNow: isVisibleNow,
  );
}
