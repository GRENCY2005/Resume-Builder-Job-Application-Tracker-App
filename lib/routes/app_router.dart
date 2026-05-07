import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/applications/screens/application_tracking_screen.dart';
import '../features/applications/screens/application_entry_screen.dart';
import '../features/resume/screens/resume_list_screen.dart';
import '../features/resume/screens/resume_builder_screen.dart';
import '../features/search/screens/search_filter_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../widgets/main_navigation_screen.dart';
import '../features/resume/models/resume_model.dart';
import '../features/applications/models/application_model.dart';

// Navigator Keys for maintaining state across tabs
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorDashboardKey = GlobalKey<NavigatorState>(debugLabel: 'shellDashboard');
final GlobalKey<NavigatorState> _shellNavigatorAppsKey = GlobalKey<NavigatorState>(debugLabel: 'shellApps');
final GlobalKey<NavigatorState> _shellNavigatorResumeKey = GlobalKey<NavigatorState>(debugLabel: 'shellResume');
final GlobalKey<NavigatorState> _shellNavigatorSearchKey = GlobalKey<NavigatorState>(debugLabel: 'shellSearch');
final GlobalKey<NavigatorState> _shellNavigatorSettingsKey = GlobalKey<NavigatorState>(debugLabel: 'shellSettings');

/// The main GoRouter configuration for the Smart Resume Tracker app.
final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/dashboard',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        // Return the UI shell containing the BottomNavigationBar
        return MainNavigationScreen(navigationShell: navigationShell);
      },
      branches: [
        // Branch 0: Dashboard
        StatefulShellBranch(
          navigatorKey: _shellNavigatorDashboardKey,
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        // Branch 1: Applications
        StatefulShellBranch(
          navigatorKey: _shellNavigatorAppsKey,
          routes: [
            GoRoute(
              path: '/applications',
              builder: (context, state) => const ApplicationTrackingScreen(),
              routes: [
                GoRoute(
                  path: 'entry',
                  parentNavigatorKey: _rootNavigatorKey, // Hide bottom nav on this screen
                  builder: (context, state) {
                    final app = state.extra as JobApplicationModel?;
                    return ApplicationEntryScreen(existingApplication: app);
                  },
                ),
              ],
            ),
          ],
        ),
        // Branch 2: Resumes
        StatefulShellBranch(
          navigatorKey: _shellNavigatorResumeKey,
          routes: [
            GoRoute(
              path: '/resumes',
              builder: (context, state) => const ResumeListScreen(),
              routes: [
                GoRoute(
                  path: 'builder',
                  parentNavigatorKey: _rootNavigatorKey, // Hide bottom nav on this screen
                  builder: (context, state) {
                    final resume = state.extra as ResumeModel?;
                    return ResumeBuilderScreen(existingResume: resume);
                  },
                ),
              ],
            ),
          ],
        ),
        // Branch 3: Search & Filter
        StatefulShellBranch(
          navigatorKey: _shellNavigatorSearchKey,
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchFilterScreen(),
            ),
          ],
        ),
        // Branch 4: Settings
        StatefulShellBranch(
          navigatorKey: _shellNavigatorSettingsKey,
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
