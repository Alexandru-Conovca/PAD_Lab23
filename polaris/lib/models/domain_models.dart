enum CelestialType { planet, galaxy, nebula, star }

enum QuestDifficulty { beginner, intermediate, advanced }

class User {
  const User({
    this.id,
    required this.name,
    required this.email,
    required this.level,
    this.role,
  });

  final int? id;
  final String name;
  final String email;
  final String level;
  final String? role;
}

class QuestTask {
  const QuestTask({
    required this.id,
    required this.title,
    required this.targetObjectId,
    required this.targetObjectName,
    this.description,
    this.stepOrder = 0,
  });

  final int id;
  final int stepOrder;
  final String title;
  final String targetObjectId;
  final String targetObjectName;
  final String? description;
}

class Quest {
  const Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.tasksCount,
    required this.createdAt,
    this.rewardXp = 0,
    this.tasks = const [],
  });

  final String id;
  final String title;
  final String description;
  final QuestDifficulty difficulty;
  final int tasksCount;
  final String createdAt;
  final int rewardXp;
  final List<QuestTask> tasks;
}

class QuestTaskProgress {
  const QuestTaskProgress({
    required this.taskId,
    required this.title,
    required this.targetObjectId,
    required this.targetObjectName,
    required this.isCompleted,
    this.completedAt,
  });

  final int taskId;
  final String title;
  final String targetObjectId;
  final String targetObjectName;
  final bool isCompleted;
  final String? completedAt;
}

class QuestProgress {
  const QuestProgress({
    required this.userQuestId,
    required this.questId,
    required this.questTitle,
    required this.status,
    required this.progressPercent,
    required this.startedAt,
    this.completedAt,
    this.tasks = const [],
  });

  final int userQuestId;
  final String questId;
  final String questTitle;
  final String status;
  final double progressPercent;
  final String startedAt;
  final String? completedAt;
  final List<QuestTaskProgress> tasks;
}

class Observation {
  const Observation({
    required this.id,
    required this.objectName,
    required this.dateTime,
    required this.location,
    required this.status,
    required this.questTitle,
    this.objectId,
    this.questId,
    this.telescopeId,
    this.latitude,
    this.longitude,
    this.notes,
    this.verificationScore,
    this.verificationReason,
  });

  final String id;
  final String objectName;
  final String dateTime;
  final String location;
  final String status;
  final String questTitle;
  final String? objectId;
  final String? questId;
  final int? telescopeId;
  final double? latitude;
  final double? longitude;
  final String? notes;
  final double? verificationScore;
  final String? verificationReason;
}

class Telescope {
  const Telescope({
    required this.id,
    required this.name,
    required this.aperture,
    required this.focalLength,
    required this.mountType,
    this.isActive = false,
    this.notes,
    this.focalRatio = 0,
  });

  final String id;
  final String name;
  final int aperture;
  final int focalLength;
  final String mountType;
  final bool isActive;
  final String? notes;
  final double focalRatio;

  Telescope copyWith({
    String? id,
    String? name,
    int? aperture,
    int? focalLength,
    String? mountType,
    bool? isActive,
    String? notes,
    double? focalRatio,
  }) => Telescope(
    id: id ?? this.id,
    name: name ?? this.name,
    aperture: aperture ?? this.aperture,
    focalLength: focalLength ?? this.focalLength,
    mountType: mountType ?? this.mountType,
    isActive: isActive ?? this.isActive,
    notes: notes ?? this.notes,
    focalRatio: focalRatio ?? this.focalRatio,
  );
}

class WeatherConditions {
  const WeatherConditions({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.temperature,
    required this.cloudCover,
    required this.relativeHumidity,
    required this.suitabilityScore,
    required this.rating,
    required this.isSuitable,
    required this.summary,
    this.source,
  });

  final double latitude;
  final double longitude;
  final String timestamp;
  final double temperature;
  final double cloudCover;
  final double relativeHumidity;
  final double suitabilityScore;
  final String rating;
  final bool isSuitable;
  final String summary;
  final String? source;
}

class VerificationResult {
  const VerificationResult({
    required this.id,
    required this.observationId,
    required this.isValid,
    required this.status,
    required this.score,
    required this.reasons,
    this.details,
    required this.verifiedAt,
  });

  final int id;
  final int observationId;
  final bool isValid;
  final String status;
  final double score;
  final String reasons;
  final Map<String, dynamic>? details;
  final String verifiedAt;
}
