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

  CelestialObject copyWith({
    String? id,
    String? name,
    CelestialType? type,
    String? description,
    double? magnitude,
    String? coordinates,
    String? constellation,
    bool? isVisibleNow,
  }) => CelestialObject(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    description: description ?? this.description,
    magnitude: magnitude ?? this.magnitude,
    coordinates: coordinates ?? this.coordinates,
    constellation: constellation ?? this.constellation,
    isVisibleNow: isVisibleNow ?? this.isVisibleNow,
  );
}
