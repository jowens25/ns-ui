import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ntsc_ui/api/LoginApi.dart';
import 'package:ntsc_ui/pages/analyticsPage.dart';
import 'package:ntsc_ui/pages/errorPage.dart';
import 'package:ntsc_ui/explorerLayout.dart';
import 'package:ntsc_ui/pages/generalSettingsPage.dart';
import 'package:ntsc_ui/pages/loginPage.dart';
import 'package:ntsc_ui/pages/logoutPage.dart';
import 'package:ntsc_ui/pages/metricsPage.dart';
import 'package:ntsc_ui/models.dart';
import 'package:ntsc_ui/pages/projectDetailsPage.dart';
import 'package:ntsc_ui/pages/projectFilesPage.dart';
import 'package:ntsc_ui/pages/projectsOverviewPage.dart';
import 'package:ntsc_ui/pages/dashboardPage.dart';
import 'package:ntsc_ui/pages/reportsPage.dart';
import 'package:ntsc_ui/pages/securitySettingsPage.dart';
import 'package:ntsc_ui/pages/settingsOverviewPage.dart';
import 'package:ntsc_ui/pages/usersPage.dart';
import 'package:provider/provider.dart';

// Consolidated Route Configuration

final loginRoute = RouteConfig(
  path: "/login",
  name: "Login",
  icon: Icons.login,
  pageBuilder: () => LoginPage(),
  isAllowed: true,
);

final logoutRoute = RouteConfig(
  path: "/logout",
  name: "Logout",
  icon: Icons.logout,
  pageBuilder: () => LogoutPage(),
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
  isAllowed: false,
);

// ================================================================
// Router Configuration
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final loginApi = Provider.of<LoginApi>(context, listen: false);
      final loggedIn = loginApi.isLoggedIn;

      final isLoginRoute = state.uri.path == '/login';

      // If not authenticated and trying to access protected route, redirect to login
      if (!loggedIn && AppRoutes.requiresAuthentication(state.uri.path)) {
        return '/login';
      }

      // If authenticated and on login page, redirect to dashboard
      if (loggedIn && isLoginRoute) {
        return '/dashboard';
      }

      // Check if route is allowed by server
      if (!AppRoutes.isRouteAllowed(state.uri.path)) {
        return loggedIn ? '/dashboard' : '/login';
      }

      return null; // Allow navigation
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (BuildContext context, GoRouterState state) {
          final loginApi = Provider.of<LoginApi>(context, listen: false);
          return loginApi.isLoggedIn ? '/dashboard' : '/login';
        },
      ),
      //GoRoute(
      //  path: '/login',
      //  pageBuilder: (context, state) => NoTransitionPage(child: LoginPage()),
      //),
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
    logoutRoute,
  ];

  // Utility methods to work with route configuration
  static List<String> getAllowedPaths() {
    List<String> paths = ['/', '/login'];

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

  static List<ExplorerItem> generateExplorerItems(BuildContext context) {
    final loginApi = Provider.of<LoginApi>(context, listen: false);
    // Only return items if user is authenticated
    if (!loginApi.isLoggedIn) {
      return [];
    }

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
      if (route.isAllowed) {
        items.add(buildItem(route, ''));
      }
    }

    return items;
  }

  static bool isRouteAllowed(String route) {
    return getAllowedPaths().contains(route);
  }

  static bool requiresAuthentication(String route) {
    // Public routes that don't require authentication
    List<String> publicRoutes = ['/', '/login'];
    return !publicRoutes.contains(route);
  }
}
