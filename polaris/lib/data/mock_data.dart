import '../models/domain_models.dart';

const currentUser = User(
  name: 'Alexandru',
  email: 'alexandru@polaris.app',
  level: 'Amateur Stargazer',
);

const celestialObjects = [
  CelestialObject(
    id: 'mars',
    name: 'Mars',
    type: CelestialType.planet,
    description: 'The red planet and a rewarding target for a small telescope.',
    magnitude: -1.8,
    coordinates: 'RA 12h 42m / Dec -05°',
    constellation: 'Virgo',
    isVisibleNow: true,
  ),
  CelestialObject(
    id: 'saturn',
    name: 'Saturn',
    type: CelestialType.planet,
    description: 'A gas giant famous for its bright, delicate ring system.',
    magnitude: 0.7,
    coordinates: 'RA 23h 18m / Dec -07°',
    constellation: 'Aquarius',
    isVisibleNow: true,
  ),
  CelestialObject(
    id: 'm31',
    name: 'Andromeda Galaxy (M31)',
    type: CelestialType.galaxy,
    description:
        'Our nearest major galactic neighbor, visible as a soft oval glow.',
    magnitude: 3.4,
    coordinates: 'RA 00h 42m / Dec +41°',
    constellation: 'Andromeda',
    isVisibleNow: true,
  ),
  CelestialObject(
    id: 'm42',
    name: 'Orion Nebula (M42)',
    type: CelestialType.nebula,
    description: 'A stellar nursery with bright, intricate clouds of gas.',
    magnitude: 4.0,
    coordinates: 'RA 05h 35m / Dec -05°',
    constellation: 'Orion',
    isVisibleNow: false,
  ),
  CelestialObject(
    id: 'm45',
    name: 'Pleiades (M45)',
    type: CelestialType.star,
    description:
        'A compact and beautiful open cluster known as the Seven Sisters.',
    magnitude: 1.6,
    coordinates: 'RA 03h 47m / Dec +24°',
    constellation: 'Taurus',
    isVisibleNow: false,
  ),
  CelestialObject(
    id: 'm57',
    name: 'Ring Nebula (M57)',
    type: CelestialType.nebula,
    description:
        'A compact planetary nebula with a distinctive smoke-ring shape.',
    magnitude: 8.8,
    coordinates: 'RA 18h 53m / Dec +33°',
    constellation: 'Lyra',
    isVisibleNow: true,
  ),
  CelestialObject(
    id: 'vega',
    name: 'Vega',
    type: CelestialType.star,
    description:
        'A brilliant blue-white star and anchor of the Summer Triangle.',
    magnitude: 0.0,
    coordinates: 'RA 18h 37m / Dec +38°',
    constellation: 'Lyra',
    isVisibleNow: true,
  ),
  CelestialObject(
    id: 'albireo',
    name: 'Albireo',
    type: CelestialType.star,
    description:
        'A striking double star with contrasting golden and blue components.',
    magnitude: 2.9,
    coordinates: 'RA 19h 31m / Dec +28°',
    constellation: 'Cygnus',
    isVisibleNow: true,
  ),
];

const quests = [
  Quest(
    id: 'solar',
    title: 'Tour of the Solar System',
    description:
        'Visit bright planets and learn to read their changing positions.',
    difficulty: QuestDifficulty.beginner,
    tasksCount: 5,
    createdAt: 'September 2026',
  ),
  Quest(
    id: 'deep-sky',
    title: 'Deep Sky Wonders of Autumn',
    description: 'Build confidence finding galaxies and nebulae beyond our neighborhood.',
    difficulty: QuestDifficulty.intermediate,
    tasksCount: 8,
    createdAt: 'September 2026',
  ),
  Quest(
    id: 'binary',
    title: 'Binary Star Hunt',
    description:
        'Resolve colorful double stars and compare their apparent brightness.',
    difficulty: QuestDifficulty.intermediate,
    tasksCount: 6,
    createdAt: 'August 2026',
  ),
  Quest(
    id: 'messier',
    title: 'Messier Challenge: Part 1',
    description:
        'Start a classic catalogue with ten rewarding Messier objects.',
    difficulty: QuestDifficulty.advanced,
    tasksCount: 10,
    createdAt: 'August 2026',
  ),
  Quest(
    id: 'moon',
    title: 'Moonwatch: Mare and Craters',
    description:
        'Learn lunar geography by tracing seas, craters, and mountain ranges.',
    difficulty: QuestDifficulty.beginner,
    tasksCount: 7,
    createdAt: 'July 2026',
  ),
  Quest(
    id: 'summer',
    title: 'Summer Triangle Field Notes',
    description:
        'Map three bright stars and discover the objects hidden around them.',
    difficulty: QuestDifficulty.intermediate,
    tasksCount: 6,
    createdAt: 'July 2026',
  ),
];

const observations = [
  Observation(
    id: 'obs-1',
    objectName: 'Saturn',
    dateTime: '18 Sep 2026, 22:14',
    location: 'Chișinău, 47.0101° N',
    status: 'Verified',
    questTitle: 'Tour of the Solar System',
  ),
  Observation(
    id: 'obs-2',
    objectName: 'Vega',
    dateTime: '16 Sep 2026, 21:48',
    location: 'Chișinău, 28.8638° E',
    status: 'Verified',
    questTitle: 'Binary Star Hunt',
  ),
  Observation(
    id: 'obs-3',
    objectName: 'Andromeda Galaxy (M31)',
    dateTime: '12 Sep 2026, 23:02',
    location: 'Orhei, 47.3833° N',
    status: 'Pending',
    questTitle: 'Deep Sky Wonders of Autumn',
  ),
  Observation(
    id: 'obs-4',
    objectName: 'Mars',
    dateTime: '08 Sep 2026, 21:35',
    location: 'Chișinău, 28.8638° E',
    status: 'Verified',
    questTitle: 'Tour of the Solar System',
  ),
  Observation(
    id: 'obs-5',
    objectName: 'Albireo',
    dateTime: '01 Sep 2026, 22:21',
    location: 'Codru, 46.9786° N',
    status: 'Verified',
    questTitle: 'Binary Star Hunt',
  ),
  Observation(
    id: 'obs-6',
    objectName: 'Ring Nebula (M57)',
    dateTime: '28 Aug 2026, 23:10',
    location: 'Chișinău, 28.8638° E',
    status: 'Pending',
    questTitle: 'Deep Sky Wonders of Autumn',
  ),
];

const telescopes = [
  Telescope(
    id: 'sw',
    name: 'Sky-Watcher BK 1309EQ2',
    aperture: 130,
    focalLength: 900,
    mountType: 'Equatorial',
  ),
  Telescope(
    id: 'celestron',
    name: 'Celestron NexStar 8SE',
    aperture: 203,
    focalLength: 2032,
    mountType: 'Alt-Az GoTo',
  ),
  Telescope(
    id: 'heritage',
    name: 'Sky-Watcher Heritage 130P',
    aperture: 130,
    focalLength: 650,
    mountType: 'Tabletop Dobsonian',
  ),
  Telescope(
    id: 'dobsonian',
    name: 'Orion SkyQuest XT8',
    aperture: 203,
    focalLength: 1200,
    mountType: 'Dobsonian',
  ),
  Telescope(
    id: 'mak',
    name: 'Explore Scientific 127 Mak',
    aperture: 127,
    focalLength: 1540,
    mountType: 'Alt-Az',
  ),
  Telescope(
    id: 'refractor',
    name: 'William Optics ZenithStar 73',
    aperture: 73,
    focalLength: 430,
    mountType: 'Alt-Az Camera Mount',
  ),
];
