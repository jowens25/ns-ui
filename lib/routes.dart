import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nct/api/AuthApi.dart';
import 'package:nct/pages/device/deviceOverviewPage.dart';
import 'package:nct/pages/network/networkOverviewPage.dart';

import 'package:nct/pages/errorPage.dart';
import 'package:nct/explorerLayout.dart';
import 'package:nct/pages/loginPage.dart';
import 'package:nct/pages/logoutPage.dart';
import 'package:nct/models.dart';
import 'package:nct/pages/snmp/snmpOverviewPage.dart';
import 'package:nct/pages/supportPage.dart';

import 'package:nct/pages/users/usersOverviewPage.dart';

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

final usersRoute = RouteConfig(
  path: '/users',
  name: 'Users',
  icon: Icons.people,
  pageBuilder: () => UsersOverviewPage(),
  isAllowed: true,
);

final deviceRoute = RouteConfig(
  path: '/device',
  name: 'Device ',
  icon: Icons.dns,
  pageBuilder: () => DeviceOverviewPage(),
  isAllowed: true,
);

final snmpRoute = RouteConfig(
  path: '/snmp',
  name: 'Snmp',
  icon: Icons.alarm,
  pageBuilder: () => SnmpOverviewPage(),
);

final networkRoute = RouteConfig(
  path: '/network',
  name: 'Network',
  icon: Icons.assessment,
  pageBuilder: () => NetworkOverviewPage(),
);

final supportRoute = RouteConfig(
  path: '/support',
  name: 'Support',
  icon: Icons.help,
  pageBuilder: () => SupportPage(),
  isAllowed: true,
);

// ================================================================
// Router Configuration
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final authApi = Provider.of<AuthApi>(context, listen: false);
      final loggedIn = authApi.isLoggedIn;

      final isLoginRoute = state.uri.path == '/login';

      // If not authenticated and trying to access protected route, redirect to login
      if (!loggedIn && AppRoutes.requiresAuthentication(state.uri.path)) {
        return '/login';
      }

      // If authenticated and on login page, redirect to dashboard
      if (loggedIn && isLoginRoute) {
        return '/device';
      }

      // Check if route is allowed by server
      if (!AppRoutes.isRouteAllowed(state.uri.path)) {
        return loggedIn ? '/device' : '/login';
      }

      return null; // Allow navigation
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (BuildContext context, GoRouterState state) {
          final authApi = Provider.of<AuthApi>(context, listen: false);
          return authApi.isLoggedIn ? '/device' : '/login';
        },
      ),

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
    deviceRoute,
    usersRoute,
    loginRoute,
    snmpRoute,
    networkRoute,
    supportRoute,
    logoutRoute,
  ];

  // Utility methods to work with route configuration
  static List<String> getAllowedPaths() {
    List<String> paths = ['/', '/login', '/support'];

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

  static List<ExplorerItem> generateExplorerItems(bool isLoggedIn) {
    //inal loginApi = Provider.of<LoginApi>(context, listen: false);
    // Only return items if user is authenticated
    if (!isLoggedIn) {
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
      // Exclude /login for logged-in users
      if (route.isAllowed && route.path != '/login') {
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
    List<String> publicRoutes = ['/', '/login', '/support'];
    return !publicRoutes.contains(route);
  }
}
