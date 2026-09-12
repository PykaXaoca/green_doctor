import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/calendar/presentation/screens/calendar_screen.dart';
import '../../features/diagnosis/presentation/screens/active_treatments_screen.dart';
import '../../features/diagnosis/presentation/screens/diagnosis_screen.dart';
import '../../features/diagnosis/presentation/screens/treatment_screen.dart';
import '../../features/identification/presentation/screens/identify_screen.dart';
import '../../features/plants/presentation/screens/plant_detail_screen.dart';
import '../../features/plants/presentation/screens/plant_form_screen.dart';
import '../../features/plants/presentation/screens/plants_list_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/today/presentation/screens/today_screen.dart';

class _StubScreen extends StatelessWidget {
  const _StubScreen({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('Экран в разработке'),
          ],
        ),
      ),
    );
  }
}

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/today',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            _ScaffoldWithNavBar(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/today',
                builder: (context, state) => const TodayScreen(),
                routes: [
                  GoRoute(
                    path: 'calendar',
                    builder: (context, state) => const CalendarScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/plants',
                builder: (context, state) => const PlantsListScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const PlantFormScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = int.tryParse(state.pathParameters['id'] ?? '');
                      if (id == null) {
                        return const _StubScreen(
                          title: 'Растение не найдено',
                          icon: Icons.error_outline,
                        );
                      }
                      return PlantDetailScreen(plantId: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) {
                          final id = int.tryParse(
                            state.pathParameters['id'] ?? '',
                          );
                          return PlantFormScreen(plantId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/identify',
                builder: (context, state) => const IdentifyScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: '/diagnosis',
        builder: (context, state) => const DiagnosisScreen(),
        routes: [
          GoRoute(
            path: 'plant/:plantId',
            builder: (context, state) {
              final plantId = int.tryParse(
                state.pathParameters['plantId'] ?? '',
              );
              return DiagnosisScreen(plantId: plantId);
            },
          ),
          GoRoute(
            path: 'active',
            builder: (context, state) => const ActiveTreatmentsScreen(),
          ),
          GoRoute(
            path: 'treatment/:id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              if (id == null) {
                return const _StubScreen(
                  title: 'Лечение не найдено',
                  icon: Icons.error_outline,
                );
              }
              return TreatmentScreen(diagnosisId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/paywall',
        builder: (context, state) =>
            const _StubScreen(title: 'Premium', icon: Icons.star),
      ),
    ],
  );
}

class _ScaffoldWithNavBar extends StatelessWidget {
  const _ScaffoldWithNavBar({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Сегодня',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_florist_outlined),
            selectedIcon: Icon(Icons.local_florist),
            label: 'Растения',
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined),
            selectedIcon: Icon(Icons.camera_alt),
            label: 'Определить',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
