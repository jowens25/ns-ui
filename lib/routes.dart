import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ntsc_ui/LoginApi.dart';
import 'package:ntsc_ui/analyticsPage.dart';
import 'package:ntsc_ui/errorPage.dart';
import 'package:ntsc_ui/explorerLayout.dart';
import 'package:ntsc_ui/generalSettingsPage.dart';
import 'package:ntsc_ui/loginPage.dart';
import 'package:ntsc_ui/metricsPage.dart';
import 'package:ntsc_ui/models.dart';
import 'package:ntsc_ui/projectDetailsPage.dart';
import 'package:ntsc_ui/projectFilesPage.dart';
import 'package:ntsc_ui/projectsOverviewPage.dart';
import 'package:ntsc_ui/dashboardPage.dart';
import 'package:ntsc_ui/reportsPage.dart';
import 'package:ntsc_ui/securitySettingsPage.dart';
import 'package:ntsc_ui/settingsOverviewPage.dart';
import 'package:ntsc_ui/usersPage.dart';
import 'package:provider/provider.dart';

// Consolidated Route Configuration

final loginRoute = RouteConfig(
  path: "/login",
  name: "Login",
  icon: Icons.login,
  pageBuilder: () => LoginPage(),
);

final dashboardRoute = RouteConfig(
  path: '/dashboard',
  name: 'Dashboard',
  icon: Icons.dashboard,
  pageBuilder: () => DashboardPage(),
);

// ================================================================
final projectsRoute = RouteConfig(
  path: '/projects',
  name: 'Projects',
  icon: Icons.folder,
  pageBuilder: () => ProjectsOverviewPage(),
  children: [
    RouteConfig(
      path: '/project1',
      name: 'Project Alpha',
      icon: Icons.work,
      pageBuilder:
          () => ProjectDetailsPage(
            projectId: 'project1',
            projectName: 'Project Alpha',
          ),
      children: [
        RouteConfig(
          path: '/files',
          name: 'Files',
          icon: Icons.insert_drive_file,
          pageBuilder: () => ProjectFilesPage(projectId: 'project1'),
        ),
      ],
    ),
    RouteConfig(
      path: '/project2',
      name: 'Project Beta',
      icon: Icons.work,
      pageBuilder:
          () => ProjectDetailsPage(
            projectId: 'project2',
            projectName: 'Project Beta',
          ),
    ),
  ],
);
// ================================================================
// ================================================================
final settingsRoute = RouteConfig(
  path: '/settings',
  name: 'Settings',
  icon: Icons.settings,
  pageBuilder: () => SettingsOverviewPage(),
  children: [
    RouteConfig(
      path: '/general',
      name: 'General',
      icon: Icons.tune,
      pageBuilder: () => GeneralSettingsPage(),
    ),
    RouteConfig(
      path: '/security',
      name: 'Security',
      icon: Icons.security,
      pageBuilder: () => SecuritySettingsPage(),
    ),
  ],
);

// ================================================================
// ================================================================
final analyticsRoute = RouteConfig(
  path: '/analytics',
  name: 'Analytics',
  icon: Icons.analytics,
  pageBuilder: () => AnalyticsPage(),
  children: [
    RouteConfig(
      path: '/reports',
      name: 'Reports',
      icon: Icons.assessment,
      pageBuilder: () => ReportsPage(),
    ),
    RouteConfig(
      path: '/metrics',
      name: 'Metrics',
      icon: Icons.speed,
      pageBuilder: () => MetricsPage(),
    ),
  ],
);

// ================================================================
// ================================================================
final usersRoute = RouteConfig(
  path: '/users',
  name: 'User Management',
  icon: Icons.people,
  pageBuilder: () => UsersPage(),
  isAllowed: false, // Example of restricted route
);

// Router Configuration
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final loginApi = Provider.of<LoginApi>(context, listen: false);
      final loggedIn = loginApi.isLoggedIn;
      final isLoginPage = state.uri.path == '/login';

      if (!loggedIn) return '/login';
      if (loggedIn && isLoginPage) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/dashboard'),
      ShellRoute(
        builder: (context, state, child) {
          return ExplorerLayout(child: child);
        },
        routes: AppRoutes.generateGoRoutes(),
      ),
    ],
    errorPageBuilder:
        (context, state) =>
            NoTransitionPage(child: ErrorPage(error: state.error.toString())),
  );
}

// ================================================================
// Single source of truth for all routes
class AppRoutes {
  static final List<RouteConfig> routes = [
    loginRoute,
    dashboardRoute,
    projectsRoute,
    settingsRoute,
    analyticsRoute,
    usersRoute,
  ];

  // Utility methods to work with route configuration
  static List<String> getAllowedPaths() {
    List<String> paths = ['/'];

    void addPaths(List<RouteConfig> configs, String parentPath) {
      for (var config in configs) {
        String fullPath = parentPath + config.path;
        if (config.isAllowed) {
          paths.add(fullPath);
        }
        if (config.children.isNotEmpty) {
          addPaths(config.children, fullPath);
        }
      }
    }

    addPaths(routes, '');
    return paths;
  }

  static List<GoRoute> generateGoRoutes() {
    List<GoRoute> goRoutes = [];

    GoRoute buildRoute(RouteConfig config, String parentPath) {
      String fullPath = parentPath + config.path;

      return GoRoute(
        path: config.path,
        pageBuilder:
            (context, state) => NoTransitionPage(child: config.pageBuilder()),
        routes:
            config.children
                .map((child) => buildRoute(child, fullPath))
                .toList(),
      );
    }

    for (var route in routes) {
      goRoutes.add(buildRoute(route, ''));
    }

    return goRoutes;
  }

  static List<ExplorerItem> generateExplorerItems() {
    List<ExplorerItem> items = [];

    ExplorerItem buildItem(RouteConfig config, String parentPath) {
      String fullPath = parentPath + config.path;

      return ExplorerItem(
        id: fullPath.replaceAll('/', '_'),
        name: config.name,
        route: fullPath,
        icon: config.icon,
        children:
            config.children.map((child) => buildItem(child, fullPath)).toList(),
      );
    }

    for (var route in routes) {
      items.add(buildItem(route, ''));
    }

    return items;
  }

  static bool isRouteAllowed(String route) {
    return getAllowedPaths().contains(route);
  }
}
