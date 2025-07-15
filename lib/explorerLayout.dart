import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ntsc_ui/api/AuthApi.dart';
import 'package:ntsc_ui/api/UserApi.dart';
import 'package:ntsc_ui/models.dart';
import 'package:ntsc_ui/routes.dart';
import 'package:provider/provider.dart';

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
    final authApi = Provider.of<AuthApi>(context, listen: false);
    explorerItems = AppRoutes.generateExplorerItems(authApi.isLoggedIn);
  }

  @override
  Widget build(BuildContext context) {
    String currentRoute = GoRouterState.of(context).uri.path;
    final authApi = Provider.of<AuthApi>(context, listen: false);
    explorerItems = AppRoutes.generateExplorerItems(authApi.isLoggedIn);

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
                      //Icon(Icons.explore, size: 20),
                      //SizedBox(width: 8)
                      Image.asset(
                        'assets/images/logo.png',
                        width: 217, // Adjust width as needed
                        height: 30, // Adjust height as needed
                        fit: BoxFit.contain,
                      ),
                      //Text(
                      //  'NOVUS',
                      //  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      //    fontWeight: FontWeight.bold,
                      //    letterSpacing: 1,
                      //  ),
                      //),
                    ],
                  ),
                ),
                ExplorerItemsWidget(explorerItems: explorerItems),
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
                    padding: EdgeInsets.all(11),
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
                        Consumer<UserApi>(
                          builder: (context, userApi, _) {
                            return Text(
                              userApi.currentUser?.name != null
                                  ? "Welcome, ${userApi.currentUser!.name}"
                                  : "Welcome",
                            );
                          },
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
}

class ExplorerItemsWidget extends StatefulWidget {
  final List<ExplorerItem> explorerItems;

  const ExplorerItemsWidget({super.key, required this.explorerItems});

  @override
  State<ExplorerItemsWidget> createState() => _ExplorerItemsState();
}

class _ExplorerItemsState extends State<ExplorerItemsWidget> {
  //List<ExplorerItem> explorerItems = [];

  void _navigateToItem(ExplorerItem item) {
    if (AppRoutes.isRouteAllowed(item.route)) {
      context.go(item.route);
    } else {
      _showAccessDeniedDialog(item.route);
    }
  }

  void _toggleExpansion(ExplorerItem item) {
    //print("Hello");
    //print("item: " + item.id);
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
    //explorerItems = AppRoutes.generateExplorerItems(true);

    return Expanded(
      child: ListView(
        padding: EdgeInsets.zero,
        children:
            widget.explorerItems
                .map((item) => _buildExplorerItem(item, 0, currentRoute))
                .toList(),
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
                  ? Theme.of(context).colorScheme.secondary
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
