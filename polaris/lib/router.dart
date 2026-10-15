import 'package:go_router/go_router.dart';

import 'data/mock_data.dart';
import 'screens/auth_screen.dart';
import 'screens/catalog_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/object_detail_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/quest_screen.dart';
import 'screens/star_map_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/telescope_screen.dart';
import 'screens/verification_screen.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) {
        return AuthScreen(onLogin: () => context.go('/'));
      },
    ),
    GoRoute(
      path: '/',
      builder: (context, state) {
        return HomeScreen(onQuest: () => context.go('/quests'));
      },
    ),
    GoRoute(
      path: '/catalog',
      builder: (context, state) {
        return const CatalogScreen();
      },
    ),
    GoRoute(
      path: '/objects/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;

        return ObjectDetailScreen(id: id);
      },
    ),
    GoRoute(
      path: '/quests',
      builder: (context, state) {
        return QuestScreen(quest: quests[1]);
      },
    ),
    GoRoute(
      path: '/star-map',
      builder: (context, state) {
        return const StarMapScreen();
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) {
        return const ProfileScreen();
      },
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) {
        return const HistoryScreen();
      },
    ),
    GoRoute(
      path: '/favorites',
      builder: (context, state) {
        return const FavoritesScreen();
      },
    ),
    GoRoute(
      path: '/statistics',
      builder: (context, state) {
        return const StatisticsScreen();
      },
    ),
    GoRoute(
      path: '/telescope',
      builder: (context, state) {
        return const TelescopeScreen();
      },
    ),
    GoRoute(
      path: '/verification',
      builder: (context, state) {
        return const VerificationScreen();
      },
    ),
  ],
);
