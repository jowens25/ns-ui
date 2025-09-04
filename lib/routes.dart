import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nct/api/AuthApi.dart';
import 'package:nct/pages/device/deviceOverviewPage.dart';
import 'package:nct/pages/network/networkOverviewPage.dart';
import 'package:nct/pages/network/networkSettings.dart';
import 'package:nct/pages/snmp/snmpActions.dart';
import 'package:nct/pages/ntp/ntpNetwork.dart';
import 'package:nct/pages/ntp/ntpOverviewPage.dart';
import 'package:nct/pages/ntp/ntpServerConfig.dart';
import 'package:nct/pages/ntp/ntpStatus.dart';
import 'package:nct/pages/ntp/ntpUtcConfig.dart';
import 'package:nct/pages/ntp/ntpVersion.dart';

import 'package:nct/pages/snmp/snmpTraps.dart';
import 'package:nct/pages/snmp/snmpVersion12.dart';
import 'package:nct/pages/snmp/snmpVersion3.dart';
//import 'package:nct/pages/unusedPages/analyticsPage.dart';
import 'package:nct/pages/errorPage.dart';
import 'package:nct/explorerLayout.dart';
import 'package:nct/pages/generalSettingsPage.dart';
import 'package:nct/pages/loginPage.dart';
import 'package:nct/pages/logoutPage.dart';
//import 'package:nct/pages/unusedPages/metricsPage.dart';
import 'package:nct/models.dart';
import 'package:nct/pages/projects/projectDetailsPage.dart';
import 'package:nct/pages/projects/projectFilesPage.dart';
import 'package:nct/pages/projects/projectsOverviewPage.dart';
import 'package:nct/pages/dashboard/dashboardPage.dart';
import 'package:nct/pages/securitySettingsPage.dart';
import 'package:nct/pages/settingsOverviewPage.dart';
import 'package:nct/pages/snmp/snmpOverviewPage.dart';
import 'package:nct/pages/snmp/snmpStatus.dart';
import 'package:nct/pages/supportPage.dart';
import 'package:nct/pages/users/usersActions.dart';
import 'package:nct/pages/users/usersManagement.dart';
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
//final analyticsRoute = RouteConfig(
//  path: '/analytics',
//  name: 'Analytics',
//  icon: Icons.analytics,
//  pageBuilder: () => AnalyticsPage(),
//  children: [
//    RouteConfig(
//      path: '/reports',
//      name: 'Reports',
//      icon: Icons.assessment,
//      pageBuilder: () => ReportsPage(),
//    ),
//    RouteConfig(
//      path: '/metrics',
//      name: 'Metrics',
//      icon: Icons.speed,
//      pageBuilder: () => MetricsPage(),
//    ),
//  ],
//);

// ================================================================
// ================================================================
final usersRoute = RouteConfig(
  path: '/users',
  name: 'Users',
  icon: Icons.people,
  pageBuilder: () => UsersOverviewPage(),
  isAllowed: true,
  //children: [
  //  RouteConfig(
  //    path: '/actions',
  //    name: 'Actions',
  //    icon: Icons.assessment,
  //    pageBuilder: () => UsersActionsPage(),
  //  ),
  //  RouteConfig(
  //    path: '/management',
  //    name: 'Management',
  //    icon: Icons.manage_accounts,
  //    pageBuilder: () => UsersManagementPage(),
  //  ),
  //],
);

final deviceRoute = RouteConfig(
  path: '/device',
  name: 'Device ',
  icon: Icons.dns,
  pageBuilder: () => DeviceOverviewPage(),
  isAllowed: true,
  //children: [
  //  RouteConfig(
  //    path: '/actions',
  //    name: 'Actions',
  //    icon: Icons.assessment,
  //    pageBuilder: () => UsersActionsPage(),
  //  ),
  //  RouteConfig(
  //    path: '/management',
  //    name: 'Management',
  //    icon: Icons.manage_accounts,
  //    pageBuilder: () => UsersManagementPage(),
  //  ),
  //],
);

final snmpRoute = RouteConfig(
  path: '/snmp',
  name: 'Snmp',
  icon: Icons.alarm,
  pageBuilder: () => SnmpOverviewPage(),

  //children: [
  //  RouteConfig(
  //    path: '/status',
  //    name: 'Status',
  //    icon: Icons.toggle_off,
  //    pageBuilder: () => SnmpStatusPage(),
  //  ),
  //  RouteConfig(
  //    path: '/actions',
  //    name: 'Actions',
  //    icon: Icons.assignment,
  //    pageBuilder: () => SnmpActionsPage(),
  //  ),
  //  RouteConfig(
  //    path: '/v1-v2',
  //    name: 'V1/V2',
  //    icon: Icons.person_add,
  //    pageBuilder: () => SnmpVersion12Page(),
  //  ),
  //  RouteConfig(
  //    path: '/v3',
  //    name: 'V3',
  //    icon: Icons.add_moderator,
  //    pageBuilder: () => SnmpVersion3Page(),
  //  ),
  //  RouteConfig(
  //    path: '/traps',
  //    name: 'Traps',
  //    icon: Icons.notification_add,
  //    pageBuilder: () => SnmpTrapsPage(),
  //  ),
  //],
);

final networkRoute = RouteConfig(
  path: '/network',
  name: 'Network',
  icon: Icons.alarm,
  pageBuilder: () => NetworkOverviewPage(),

  //children: [
  //  RouteConfig(
  //    path: '/status',
  //    name: 'Status',
  //    icon: Icons.toggle_off,
  //    pageBuilder: () => NetworkStatusPage(),
  //  ),
  //  RouteConfig(
  //    path: '/actions',
  //    name: 'Actions',
  //    icon: Icons.assignment,
  //    pageBuilder: () => NetworkActionsPage(),
  //  ),
  //],
);

final ntpRoute = RouteConfig(
  path: '/ntp',
  name: 'NTP',
  icon: Icons.alarm,
  pageBuilder: () => NtpOverviewPage(),

  children: [
    RouteConfig(
      path: '/status',
      name: 'Status',
      icon: Icons.toggle_off,
      pageBuilder: () => NtpStatusPage(),
    ),
    RouteConfig(
      path: '/version',
      name: 'Version',
      icon: Icons.info,
      pageBuilder: () => NtpVersionPage(),
    ),
    RouteConfig(
      path: '/network',
      name: 'Network',
      icon: Icons.network_cell,
      pageBuilder: () => NtpNetworkPage(),
    ),
    RouteConfig(
      path: '/config',
      name: 'Server Config',
      icon: Icons.dns,
      pageBuilder: () => NtpServerConfigPage(),
    ),
    RouteConfig(
      path: '/utc',
      name: 'UTC Config',
      icon: Icons.storage,
      pageBuilder: () => NtpUtcConfigPage(),
    ),
  ],
);

final ptpOcRoute = RouteConfig(
  path: '/ptpoc',
  name: 'PTP OC',
  icon: Icons.alarm,
  pageBuilder: () => SnmpOverviewPage(),

  children: [
    RouteConfig(
      path: '/version',
      name: 'Version',
      icon: Icons.work,
      pageBuilder: () => SnmpStatusPage(),
    ),
    RouteConfig(
      path: '/network',
      name: 'Network',
      icon: Icons.work,
      pageBuilder: () => SnmpActionsPage(),
    ),
    RouteConfig(
      path: '/default',
      name: 'Default Dataset',
      icon: Icons.work,
      pageBuilder: () => SnmpVersion12Page(),
    ),
    RouteConfig(
      path: '/port',
      name: 'Port Dataset',
      icon: Icons.work,
      pageBuilder: () => SnmpVersion3Page(),
    ),
    RouteConfig(
      path: '/current',
      name: 'Current Dataset',
      icon: Icons.work,
      pageBuilder: () => SnmpTrapsPage(),
    ),
    RouteConfig(
      path: '/parent',
      name: 'Parent Dataset',
      icon: Icons.work,
      pageBuilder: () => SnmpTrapsPage(),
    ),
    RouteConfig(
      path: '/timeproperties',
      name: 'Time Properties Dataset',
      icon: Icons.work,
      pageBuilder: () => SnmpTrapsPage(),
    ),
  ],
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
          final authApi = Provider.of<AuthApi>(context, listen: false);
          return authApi.isLoggedIn ? '/dashboard' : '/login';
        },
      ),
      //GoRoute(
      //  path: '/support',
      //  redirect: (BuildContext context, GoRouterState state) {
      //    //final loginApi = Provider.of<LoginApi>(context, listen: false);
      //    return NoTransitionPage(child: SupportPage());
      //    //NoTransitionPage(child: SupportPage())
      //  },
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
    snmpRoute,
    //ntpRoute,
    //ptpOcRoute,
    deviceRoute,
    networkRoute,
    usersRoute,

    //projectsRoute,
    //settingsRoute,
    //analyticsRoute,
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
