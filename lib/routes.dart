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
import 'package:nct/api/TimeApi.dart';

class AppRouter {
  static final _publicRoutes = ['/', '/login', '/support'];

  static GoRouter createRouter(PublicApi publicApi) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: publicApi,
      redirect: (context, state) {
        final path = state.uri.path;
        final isPublic = _publicRoutes.contains(path);

        if (!publicApi.isLoggedIn && !isPublic) return '/login';
        if (publicApi.isLoggedIn && path == '/login') return '/network';
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          redirect: (context, state) =>
              publicApi.isLoggedIn ? '/network' : '/login',
        ),

        ShellRoute(
          builder: (context, state, child) => ExplorerLayout(child: child),
          routes: [
            GoRoute(
              path: '/network',
              pageBuilder: (context, state) =>
                  NoTransitionPage(child: NetworkPage()),
            ),
            GoRoute(
              path: '/ntp',
              pageBuilder: (context, state) =>
                  NoTransitionPage(child: NtpOverviewPage()),
            ),
            GoRoute(
              path: '/login',
              pageBuilder: (context, state) =>
                  NoTransitionPage(child: LoginPage()),
            ),
            GoRoute(
              path: '/snmp',
              pageBuilder: (context, state) =>
                  NoTransitionPage(child: SnmpOverviewPage()),
            ),
            GoRoute(
              path: '/users',
              pageBuilder: (context, state) =>
                  NoTransitionPage(child: UsersOverviewPage()),
            ),
            GoRoute(
              path: '/support',
              pageBuilder: (context, state) =>
                  NoTransitionPage(child: SupportPage()),
            ),
            GoRoute(
              path: '/logout',
              pageBuilder: (context, state) =>
                  NoTransitionPage(child: LogoutPage()),
            ),
          ],
        ),
      ],
      errorPageBuilder: (context, state) =>
          NoTransitionPage(child: ErrorPage(error: state.error.toString())),
    );
  }

  static List<ExplorerItem> generateExplorerItems(bool isLoggedIn) {
    if (!isLoggedIn) {
      return [
        ExplorerItem(
          id: '_login',
          name: 'Login',
          route: '/login',
          icon: Icons.login,
          children: [],
        ),
        ExplorerItem(
          id: '_support',
          name: 'Support',
          route: '/support',
          icon: Icons.help,
          children: [],
        ),
      ];
    }

    return [
      ExplorerItem(
        id: '_network',
        name: 'Network',
        route: '/network',
        icon: Icons.assessment,
        children: [],
      ),
      ExplorerItem(
        id: '_ntp',
        name: 'Ntp',
        route: '/ntp',
        icon: Icons.assessment,
        children: [],
      ),
      ExplorerItem(
        id: '_snmp',
        name: 'Snmp',
        route: '/snmp',
        icon: Icons.alarm,
        children: [],
      ),
      ExplorerItem(
        id: '_users',
        name: 'Users',
        route: '/users',
        icon: Icons.people,
        children: [],
      ),
      ExplorerItem(
        id: '_support',
        name: 'Support',
        route: '/support',
        icon: Icons.help,
        children: [],
      ),
      ExplorerItem(
        id: '_logout',
        name: 'Logout',
        route: '/logout',
        icon: Icons.assessment,
        children: [],
      ),
    ];
  }
}

class RouteConfig {
  final String path;
  final String name;
  final IconData icon;
  final Widget Function() pageBuilder;

  final List<RouteConfig> children;
  final bool isAllowed;
  final bool requiresAuth;

  const RouteConfig({
    required this.path,
    required this.name,
    required this.icon,
    required this.pageBuilder,
    this.children = const [],
    this.isAllowed = true,
    this.requiresAuth = true,
  });
}

// Model classes
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
