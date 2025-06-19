import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ntsc_ui/LoginApi.dart';

void main() {
  //final ntpServerApi = NtpServerApi(baseUrl: "http://100.127.98.7:8080/api/v1");
  //final ptpOcApi = PtpOcApi(baseUrl: "http://100.127.98.7:8080/api/v1");
  final loginApi = LoginApi(baseUrl: "http://10.1.10.205:8080");

  runApp(
    MultiProvider(
      providers: [
        //ChangeNotifierProvider(create: (_) => ntpServerApi),
        //ChangeNotifierProvider(create: (_) => ptpOcApi),
        ChangeNotifierProvider(create: (_) => loginApi),
        // Add more providers here as needed
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Explorer UI',
      theme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark),
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}

// Consolidated Route Configuration
class RouteConfig {
  final String path;
  final String name;
  final IconData icon;
  final Widget Function() pageBuilder;
  final List<RouteConfig> children;
  final bool isAllowed;

  const RouteConfig({
    required this.path,
    required this.name,
    required this.icon,
    required this.pageBuilder,
    this.children = const [],
    this.isAllowed = true,
  });
}

// Single source of truth for all routes
class AppRoutes {
  static final List<RouteConfig> routes = [
    RouteConfig(
      path: '/login',
      name: 'Login',
      icon: Icons.login,
      pageBuilder: () => LoginPage(),
    ),
    RouteConfig(
      path: '/dashboard',
      name: 'Dashboard',
      icon: Icons.dashboard,
      pageBuilder: () => DashboardPage(),
    ),
    RouteConfig(
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
    ),
    RouteConfig(
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
    ),
    // Add new routes here - they'll automatically appear in explorer and routing
    RouteConfig(
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
    ),
    RouteConfig(
      path: '/users',
      name: 'User Management',
      icon: Icons.people,
      pageBuilder: () => UsersPage(),
      isAllowed: false, // Example of restricted route
    ),
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

// Router Configuration
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final loginApi = Provider.of<LoginApi>(context, listen: false);
      final loggedIn = loginApi.isLoggedIn;
      final isLoginPage = state.uri.path == '/login';

      if (!loggedIn && !isLoginPage) return '/login';
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

// Main Layout with Explorer
class ExplorerLayout extends StatefulWidget {
  final Widget child;

  const ExplorerLayout({Key? key, required this.child}) : super(key: key);

  @override
  _ExplorerLayoutState createState() => _ExplorerLayoutState();
}

class _ExplorerLayoutState extends State<ExplorerLayout> {
  List<ExplorerItem> explorerItems = [];
  double explorerWidth = 250.0;

  @override
  void initState() {
    super.initState();
    explorerItems = AppRoutes.generateExplorerItems();
  }

  void _navigateToItem(ExplorerItem item) {
    if (AppRoutes.isRouteAllowed(item.route)) {
      context.go(item.route);
    } else {
      _showAccessDeniedDialog(item.route);
    }
  }

  void _toggleExpansion(ExplorerItem item) {
    setState(() {
      item.isExpanded = !item.isExpanded;
    });
  }

  void _showAccessDeniedDialog(String route) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Access Denied'),
            content: Text('You don\'t have permission to access: $route'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String currentRoute = GoRouterState.of(context).uri.path;

    return Scaffold(
      body: Row(
        children: [
          // Explorer Panel
          Container(
            width: explorerWidth,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Explorer Header
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.explore, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'EXPLORER',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                // Explorer Items
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children:
                        explorerItems
                            .map(
                              (item) =>
                                  _buildExplorerItem(item, 0, currentRoute),
                            )
                            .toList(),
                  ),
                ),
              ],
            ),
          ),
          // Resizer
          GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                explorerWidth = (explorerWidth + details.delta.dx).clamp(
                  200.0,
                  400.0,
                );
              });
            },
            child: Container(
              width: 4,
              color: Colors.transparent,
              child: Center(
                child: Container(
                  width: 2,
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
          ),
          // Main Content Area
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Content Header
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.description, size: 20),
                        SizedBox(width: 8),
                        Text(
                          currentRoute,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        Spacer(),
                        // Navigation buttons
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back, size: 18),
                              onPressed:
                                  context.canPop() ? () => context.pop() : null,
                              tooltip: 'Go Back',
                            ),
                            IconButton(
                              icon: Icon(Icons.refresh, size: 18),
                              onPressed: () => context.go(currentRoute),
                              tooltip: 'Refresh',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Content Body
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplorerItem(ExplorerItem item, int depth, String currentRoute) {
    bool isSelected = currentRoute == item.route;
    bool hasChildren = item.children.isNotEmpty;

    // Auto-expand if current route is within this item's children
    if (hasChildren &&
        currentRoute.startsWith(item.route) &&
        item.route != '/') {
      item.isExpanded = true;
    }

    return Column(
      children: [
        Material(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Colors.transparent,
          child: InkWell(
            onTap: () => _navigateToItem(item),
            child: Container(
              padding: EdgeInsets.only(
                left: 16.0 + (depth * 16.0),
                right: 16.0,
                top: 8.0,
                bottom: 8.0,
              ),
              child: Row(
                children: [
                  if (hasChildren)
                    GestureDetector(
                      onTap: () => _toggleExpansion(item),
                      child: Container(
                        padding: EdgeInsets.all(2),
                        child: Icon(
                          item.isExpanded
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_right,
                          size: 16,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    )
                  else
                    SizedBox(width: 20),
                  Icon(
                    item.icon,
                    size: 16,
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color:
                            isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (hasChildren && item.isExpanded)
          ...item.children.map(
            (child) => _buildExplorerItem(child, depth + 1, currentRoute),
          ),
      ],
    );
  }
}

// Base Page Component for consistent styling
class BasePage extends StatelessWidget {
  final String title;
  final String description;
  final List<Widget> children;

  const BasePage({
    Key? key,
    required this.title,
    required this.description,
    this.children = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(description, style: Theme.of(context).textTheme.bodyLarge),
                if (children.isNotEmpty) ...[SizedBox(height: 16), ...children],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Page Components - now much simpler since routes are auto-generated
class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Dashboard',
      description:
          'Welcome to your dashboard! Here you can see an overview of your projects and recent activity.',
      children: [
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active Projects',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '4',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Activity',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '12 updates',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

// Page Components - now much simpler since routes are auto-generated
class LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    //final loginApi = Provider.of<LoginApi>(context, listen: false);
  }

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginApi>(
      builder: (context, loginApi, _) {
        return BasePage(
          title: 'Login',
          description: 'Please Login',
          children: [
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //                    Text(
                            //                      'Active Projects',
                            //                      style: TextStyle(fontWeight: FontWeight.bold),
                            //                    ),
                            //                    SizedBox(height: 8),
                            //                    Text(
                            //                      '4',
                            //                      style: Theme.of(context).textTheme.headlineMedium,
                            //                    ),
                            TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: 'Username',
                              ),
                              validator:
                                  (value) => value!.isEmpty ? 'Required' : null,
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                              ),
                              obscureText: true,
                              validator:
                                  (value) => value!.isEmpty ? 'Required' : null,
                            ),
                            SizedBox(height: 16),
                            if (_errorMessage != null)
                              Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red),
                              ),
                            ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    final response = await loginApi.login(
                                      _usernameController.text,
                                      _passwordController.text,
                                    );
                                    // Handle successful login (e.g., save token, navigate)
                                    context.go('/dashboard');

                                    _errorMessage =
                                        'Login successful: $response';
                                  } catch (e) {
                                    setState(() {
                                      _errorMessage = e.toString();
                                    });
                                  }
                                }
                              },
                              child: Text('Sign In'),
                            ),
                            //
                            //
                            //
                            //
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recent Activity',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '12 updates',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class ProjectsOverviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Projects Overview',
      description: 'Here are all your available projects.',
      children: [
        ListTile(
          leading: Icon(Icons.work),
          title: Text('Project Alpha'),
          subtitle: Text('Active development'),
          trailing: ElevatedButton(
            onPressed: () => context.go('/projects/project1'),
            child: Text('View'),
          ),
        ),
        ListTile(
          leading: Icon(Icons.work),
          title: Text('Project Beta'),
          subtitle: Text('Planning phase'),
          trailing: ElevatedButton(
            onPressed: () => context.go('/projects/project2'),
            child: Text('View'),
          ),
        ),
      ],
    );
  }
}

class ProjectDetailsPage extends StatelessWidget {
  final String projectId;
  final String projectName;

  const ProjectDetailsPage({
    Key? key,
    required this.projectId,
    required this.projectName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: '$projectName Details',
      description:
          'This is $projectName with all its configurations and settings.',
      children: [
        Text(
          'Project ID: $projectId',
          style: TextStyle(fontFamily: 'monospace'),
        ),
        SizedBox(height: 8),
        if (projectId == 'project1')
          ElevatedButton(
            onPressed: () => context.go('/projects/project1/files'),
            child: Text('View Files'),
          ),
      ],
    );
  }
}

class ProjectFilesPage extends StatelessWidget {
  final String projectId;

  const ProjectFilesPage({Key? key, required this.projectId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Project Files',
      description: 'Files for project: $projectId',
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.insert_drive_file),
              title: Text('main.dart'),
              subtitle: Text('Application entry point'),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('config.json'),
              subtitle: Text('Configuration file'),
            ),
            ListTile(
              leading: Icon(Icons.description),
              title: Text('README.md'),
              subtitle: Text('Project documentation'),
            ),
            ListTile(
              leading: Icon(Icons.folder),
              title: Text('assets/'),
              subtitle: Text('Asset directory'),
            ),
          ],
        ),
      ],
    );
  }
}

class SettingsOverviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Settings Overview',
      description: 'Manage your application settings here.',
      children: [
        ListTile(
          leading: Icon(Icons.tune),
          title: Text('General Settings'),
          subtitle: Text('Basic app preferences'),
          trailing: ElevatedButton(
            onPressed: () => context.go('/settings/general'),
            child: Text('Configure'),
          ),
        ),
        ListTile(
          leading: Icon(Icons.security),
          title: Text('Security Settings'),
          subtitle: Text('Privacy and security options'),
          trailing: ElevatedButton(
            onPressed: () => context.go('/settings/security'),
            child: Text('Configure'),
          ),
        ),
      ],
    );
  }
}

class GeneralSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'General Settings',
      description: 'Configure your basic application preferences.',
      children: [
        ListTile(
          title: Text('Theme'),
          subtitle: Text('Dark'),
          trailing: Switch(value: true, onChanged: null),
        ),
        ListTile(
          title: Text('Language'),
          subtitle: Text('English'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
        ),
        ListTile(
          title: Text('Auto-save'),
          subtitle: Text('Automatically save changes'),
          trailing: Switch(value: true, onChanged: (value) {}),
        ),
      ],
    );
  }
}

class SecuritySettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Security Settings',
      description: 'Manage your privacy and security preferences.',
      children: [
        ListTile(
          title: Text('Two-factor Authentication'),
          subtitle: Text('Extra security for your account'),
          trailing: Switch(value: true, onChanged: (value) {}),
        ),
        ListTile(
          title: Text('Session Timeout'),
          subtitle: Text('30 minutes'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
        ),
        ListTile(
          title: Text('Password Strength'),
          subtitle: Text('Strong'),
          trailing: Icon(Icons.check_circle, color: Colors.green),
        ),
      ],
    );
  }
}

// NEW PAGES - These were automatically added by just adding them to AppRoutes
class AnalyticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Analytics',
      description:
          'View detailed analytics and insights about your application usage.',
      children: [
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Users',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '1,234',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Page Views',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '45,678',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => context.go('/analytics/reports'),
          child: Text('View Reports'),
        ),
      ],
    );
  }
}

class ReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Reports',
      description: 'Generate and view detailed reports.',
      children: [
        ListTile(
          leading: Icon(Icons.assignment),
          title: Text('User Activity Report'),
          subtitle: Text('Last generated: 2 hours ago'),
        ),
        ListTile(
          leading: Icon(Icons.trending_up),
          title: Text('Performance Report'),
          subtitle: Text('Last generated: 1 day ago'),
        ),
      ],
    );
  }
}

class MetricsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Metrics',
      description: 'Real-time application metrics and performance indicators.',
      children: [
        ListTile(
          leading: Icon(Icons.speed),
          title: Text('Response Time'),
          subtitle: Text('Average: 120ms'),
        ),
        ListTile(
          leading: Icon(Icons.memory),
          title: Text('Memory Usage'),
          subtitle: Text('Current: 45%'),
        ),
      ],
    );
  }
}

class UsersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'User Management',
      description:
          'Manage users and their permissions. (This is a restricted page for demo purposes)',
      children: [
        Text(
          'This page is restricted and should not be accessible based on server permissions.',
        ),
      ],
    );
  }
}

class ErrorPage extends StatelessWidget {
  final String error;

  const ErrorPage({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Error',
      description: 'An error occurred while navigating.',
      children: [
        Text('Error: $error', style: TextStyle(color: Colors.red)),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => context.go('/dashboard'),
          child: Text('Go to Dashboard'),
        ),
      ],
    );
  }
}
