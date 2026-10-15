enum CelestialType { planet, galaxy, nebula, star }

enum QuestDifficulty { beginner, intermediate, advanced }

class User {
  const User({required this.name, required this.email, required this.level});

  final String name;
  final String email;
  final String level;
}

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
}

class Quest {
  const Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.tasksCount,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final QuestDifficulty difficulty;
  final int tasksCount;
  final String createdAt;
}

class Observation {
  const Observation({
    required this.id,
    required this.objectName,
    required this.dateTime,
    required this.location,
    required this.status,
    required this.questTitle,
  });

  final String id;
  final String objectName;
  final String dateTime;
  final String location;
  final String status;
  final String questTitle;
}

class Telescope {
  const Telescope({
    required this.id,
    required this.name,
    required this.aperture,
    required this.focalLength,
    required this.mountType,
  });

  final String id;
  final String name;
  final int aperture;
  final int focalLength;
  final String mountType;
}
