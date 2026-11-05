import '../models/domain_models.dart';
import 'celestial_object.dart';

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
