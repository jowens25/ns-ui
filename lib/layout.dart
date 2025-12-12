import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nct/api/TimeApi.dart';
import 'package:nct/api/PublicApi.dart';
import 'package:nct/routes.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'custom/custom.dart';
import 'log.dart';

// Main Layout with Drawer
class ExplorerLayout extends StatelessWidget {
  final Widget child;

  const ExplorerLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimeApi>(
      builder: (context, timeApi, _) {
        if (timeApi.session_valid) {
          return _main(context);
        } else {
          return AbsorbPointer(
            absorbing: true,
            child: Container(
              color: Colors.black45,
              child: Column(
                children: [
                  Text(
                    timeApi.debugMessgae,
                    style: TextStyle(color: Colors.black),
                  ),
                  Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Add menu icon button to open drawer
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          IconButton(
            icon: SvgPicture.asset('images/NOVUS_LOGO.svg', width: 180),
            padding: EdgeInsets.all(0),
            constraints: const BoxConstraints(),
            onPressed: () {
              launchUrl(Uri.parse("https://novuspower.com"));
            },
          ),
          Consumer<PublicApi>(
            builder: (context, userApi, _) {
              return Text(
                userApi.currentUser?.name != null
                    ? "Welcome, ${userApi.currentUser!.name}"
                    : "Welcome",
              );
            },
          ),
          Consumer<TimeApi>(
            builder: (context, timeApi, _) {
              return Text(timeApi.time);
            },
          ),
        ],
      ),
    );
  }

  Widget _drawer(BuildContext context) {
    return Drawer(
      child: Consumer<PublicApi>(
        builder: (context, userApi, _) {
          // final explorerItems = AppRouter.generateExplorerItems(
          //  userApi.isLoggedIn,
          //);
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Navigation',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    ),
                  ],
                ),
              ),

              ///...explorerItems.map(
              // (item) => _buildDrawerItem(context, item, 0),
              //),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, ExplorerItem item, int depth) {
    String currentRoute = GoRouterState.of(context).uri.path;
    bool isSelected = currentRoute == item.route;
    bool hasChildren = item.children.isNotEmpty;

    return Column(
      children: [
        ListTile(
          leading: Icon(
            item.icon,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
          title: Text(
            item.name,
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          contentPadding: EdgeInsets.only(
            left: 16.0 + (depth * 16.0),
            right: 16.0,
          ),
          selected: isSelected,
          onTap: () {
            context.go(item.route);
            Navigator.pop(context); // Close drawer after navigation
          },
          trailing: hasChildren
              ? Icon(
                  Icons.keyboard_arrow_right,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                )
              : null,
        ),
        if (hasChildren)
          ...item.children.map(
            (child) => _buildDrawerItem(context, child, depth + 1),
          ),
      ],
    );
  }

  Widget _page(BuildContext context) {
    return Expanded(child: child);
  }

  Widget _main(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _header(context),
          Expanded(child: _page(context)),
        ],
      ),
      drawer: _drawer(context),
    );
  }
}
