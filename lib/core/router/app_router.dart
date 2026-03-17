import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/line_summary_dto.dart';
import '../../ui/features/lines/screens/line_directory_screen.dart';
import '../../ui/features/lines/screens/line_map_details_screen.dart';
import '../../ui/features/stops/screens/global_stops_map_screen.dart';
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
          // Branch 0: Linhas (Lines Directory)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/lines',
                builder: (context, state) => const LineDirectoryScreen(),
                routes: [
                  GoRoute(
                    path: 'details',
                    builder: (context, state) {
                      final line = state.extra as LineSummaryDto;
                      return LineMapDetailsScreen(line: line);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Branch 1: Mapa (Global Stops Map)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                builder: (context, state) => const GlobalStopsMapScreen(),
              ),
            ],
          ),

          // Branch 2: Favoritos (Saved - Placeholder for now)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                builder: (context, state) => const Scaffold(body: Center(child: Text('Favoritos'))),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
