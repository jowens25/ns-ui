import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nct/pages/device/deviceOverviewPage.dart';
import 'package:nct/pages/logoutPage.dart';
import 'package:nct/pages/network/networkPage.dart';
import 'package:nct/api/PublicApi.dart';

import 'package:nct/pages/errorPage.dart';
import 'package:nct/layout.dart';
import 'package:nct/pages/loginPage.dart';
import 'package:nct/pages/ntp/ntpOverviewPage.dart';
import 'package:nct/pages/snmp/snmpOverviewPage.dart';
import 'package:nct/pages/supportPage.dart';
import 'package:nct/pages/users/usersOverviewPage.dart';

GoRouter router = GoRouter(
  initialLocation: '/login',
  redirect: (BuildContext context, GoRouterState state) {
    // Using PublicApiScope.of(context) creates a dependency.
    // This will cause go_router to re-evaluate the redirect whenever
    // PublicApi notifies listeners (when auth state changes).
    final publicApi = PublicApiScope.of(context);
    final loggedIn = publicApi.isLoggedIn;
    //final isPublicRoute = _publicRoutes.contains(state.matchedLocation);

    print(
      'GoRouter redirect check - loggedIn: $loggedIn, route: ${state.matchedLocation}',
    );

    // Redirect to login if not logged in and trying to access private route
    if (!loggedIn) {
      return '/login';
    }

    // Redirect to network if logged in and on login page
    if (loggedIn && state.matchedLocation == '/login') {
      return '/network';
    }

    return null;
  },
  routes: _routes,
  errorPageBuilder: (context, state) =>
      NoTransitionPage(child: ErrorPage(error: state.error.toString())),
);

// Centralized route definitions
final List<RouteConfig> _routeConfigs = [
  RouteConfig(
    path: '/login',
    name: 'Login',
    icon: Icons.login,
    pageBuilder: () => LoginPage(),
    requiresAuth: false,
  ),
  RouteConfig(
    path: '/network',
    name: 'Network',
    icon: Icons.network_check,
    pageBuilder: () => NetworkPage(),
  ),
  RouteConfig(
    path: '/ntp',
    name: 'NTP',
    icon: Icons.access_time,
    pageBuilder: () => NtpOverviewPage(),
  ),
  RouteConfig(
    path: '/snmp',
    name: 'SNMP',
    icon: Icons.settings_ethernet,
    pageBuilder: () => SnmpOverviewPage(),
  ),
  RouteConfig(
    path: '/users',
    name: 'Users',
    icon: Icons.people,
    pageBuilder: () => UsersOverviewPage(),
  ),
  RouteConfig(
    path: '/support',
    name: 'Support',
    icon: Icons.help_outline,
    pageBuilder: () => SupportPage(),
    requiresAuth: false,
  ),
  RouteConfig(
    path: '/logout',
    name: 'Logout',
    icon: Icons.logout,
    pageBuilder: () => LogoutPage(),
  ),
];

// Generate GoRouter routes from configs
List<RouteBase> get _routes {
  final loginRoute = GoRoute(
    path: '/login',
    pageBuilder: (context, state) => NoTransitionPage(child: LoginPage()),
  );

  final shellRoutes = _routeConfigs
      .where((config) => config.path != '/login')
      .map(
        (config) => GoRoute(
          path: config.path,
          pageBuilder: (context, state) =>
              NoTransitionPage(child: config.pageBuilder()),
        ),
      )
      .toList();

  return [
    loginRoute,
    ShellRoute(
      builder: (context, state, child) => ExplorerLayout(child: child),
      routes: shellRoutes,
    ),
  ];
}

// Generate drawer/explorer items
List<ExplorerItem> generateExplorerItems(bool isLoggedIn) {
  return _routeConfigs
      .where((config) {
        if (!isLoggedIn) {
          return !config.requiresAuth; // Show only public routes
        }
        return config.path != '/login'; // Show all except login when logged in
      })
      .map(
        (config) => ExplorerItem(
          id: config.path.replaceAll('/', '_'),
          name: config.name,
          route: config.path,
          icon: config.icon,
          children: config.children
              .map(
                (child) => ExplorerItem(
                  id: child.path.replaceAll('/', '_'),
                  name: child.name,
                  route: child.path,
                  icon: child.icon,
                  children: [],
                ),
              )
              .toList(),
        ),
      )
      .toList();
}

// Simplified RouteConfig
class RouteConfig {
  final String path;
  final String name;
  final IconData icon;
  final Widget Function() pageBuilder;
  final List<RouteConfig> children;
  final bool requiresAuth;

  const RouteConfig({
    required this.path,
    required this.name,
    required this.icon,
    required this.pageBuilder,
    this.children = const [],
    this.requiresAuth = true,
  });
}

// ExplorerItem model
class ExplorerItem {
  final String id;
  final String name;
  final String route;
  final IconData icon;
  final List<ExplorerItem> children;
  bool isExpanded;

  ExplorerItem({
    required this.id,
    required this.name,
    required this.route,
    required this.icon,
    this.children = const [],
    this.isExpanded = false,
  });
}
