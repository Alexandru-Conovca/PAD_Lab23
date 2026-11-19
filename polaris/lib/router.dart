import 'package:go_router/go_router.dart';

import 'models/auth_model.dart';
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

import 'widgets/app_shell.dart';

GoRouter createRouter(AuthModel auth) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: auth,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isAuthRoute = location == '/login';

      if (!auth.isAuthenticated && !isAuthRoute) {
        return '/login';
      }
      if (auth.isAuthenticated && isAuthRoute) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const AuthScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) {
                  return HomeScreen(onQuest: () => context.go('/quests'));
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/catalog',
                builder: (context, state) => const CatalogScreen(),
                routes: [
                  GoRoute(
                    path: 'objects/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return ObjectDetailScreen(id: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/quests',
                builder: (context, state) => const QuestScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/star-map',
                builder: (context, state) => const StarMapScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'history',
                    builder: (context, state) => const HistoryScreen(),
                  ),
                  GoRoute(
                    path: 'favorites',
                    builder: (context, state) => const FavoritesScreen(),
                  ),
                  GoRoute(
                    path: 'statistics',
                    builder: (context, state) => const StatisticsScreen(),
                  ),
                  GoRoute(
                    path: 'telescope',
                    builder: (context, state) => const TelescopeScreen(),
                  ),
                  GoRoute(
                    path: 'verification',
                    builder: (context, state) => const VerificationScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
