import 'package:go_router/go_router.dart';

import '../../data/models/line_summary_dto.dart';
import '../../ui/features/lines/screens/line_directory_screen.dart';
import '../../ui/features/lines/screens/line_map_details_screen.dart';
import '../../ui/features/stops/screens/global_stops_map_screen.dart';
import '../../ui/features/favorites/screens/favorites_screen.dart';
import '../../ui/widgets/scaffold_with_nav_bar.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/lines',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/lines',
                builder: (context, state) => const LineDirectoryScreen(),
                routes: [
                  GoRoute(
                    path: 'details',
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>;
                      final line = extra['line'] as LineSummaryDto;
                      final direction = extra['direction'] as int? ?? 0;
                      return LineMapDetailsScreen(
                        line: line,
                        direction: direction,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                builder: (context, state) => const GlobalStopsMapScreen(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                builder: (context, state) => const FavoritesScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
