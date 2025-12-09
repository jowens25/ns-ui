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

// Main Layout with Explorer
class ExplorerLayout extends StatelessWidget {
  final Widget child;
  static const double explorerWidth = 200.0;

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

  Widget _menu(BuildContext context) {
    return Container(
      width: explorerWidth,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Consumer<PublicApi>(
        builder: (context, userApi, _) {
          final explorerItems = AppRouter.generateExplorerItems(
            userApi.isLoggedIn,
          );
          return ExplorerItemsWidget(explorerItems: explorerItems);
        },
      ),
    );
  }

  Widget _page(BuildContext context) {
    return Expanded(child: child);
  }

  Widget _footer(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: LogViewerPage()),
          Expanded(child: Placeholder(child: Text("terminal"))),
        ],
      ),
    );
  }

  Widget _main(BuildContext context) {
    return _ResizableFooterScaffold(
      header: _header(context),
      menu: _menu(context),
      page: _page(context),
      footer: _footer(context),
    );
  }
}

// Separate stateful widget for footer resizing only
class _ResizableFooterScaffold extends StatefulWidget {
  final Widget header;
  final Widget menu;
  final Widget page;
  final Widget footer;

  const _ResizableFooterScaffold({
    required this.header,
    required this.menu,
    required this.page,
    required this.footer,
  });

  @override
  State<_ResizableFooterScaffold> createState() =>
      _ResizableFooterScaffoldState();
}

class _ResizableFooterScaffoldState extends State<_ResizableFooterScaffold> {
  double footerHeight = 200.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          widget.header,
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [widget.menu, widget.page],
            ),
          ),
          DragBar(
            onDragUpdate: (deltaY) {
              setState(() {
                footerHeight -= deltaY;
                footerHeight = footerHeight.clamp(5.0, 500.0);
              });
            },
          ),
          SizedBox(height: footerHeight, child: widget.footer),
        ],
      ),
    );
  }
}

// nested menu class
class ExplorerItemsWidget extends StatefulWidget {
  final List<ExplorerItem> explorerItems;

  const ExplorerItemsWidget({super.key, required this.explorerItems});

  @override
  State<ExplorerItemsWidget> createState() => _ExplorerItemsState();
}

class _ExplorerItemsState extends State<ExplorerItemsWidget> {
  void _toggleExpansion(ExplorerItem item) {
    setState(() {
      item.isExpanded = !item.isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    String currentRoute = GoRouterState.of(context).uri.path;
    return ListView(
      padding: EdgeInsets.zero,
      children: widget.explorerItems
          .map((item) => _buildExplorerItem(item, 0, currentRoute))
          .toList(),
    );
  }

  Widget _buildExplorerItem(ExplorerItem item, int depth, String currentRoute) {
    bool isSelected = currentRoute == item.route;
    bool hasChildren = item.children.isNotEmpty;
    if (hasChildren &&
        currentRoute.startsWith(item.route) &&
        item.route != '/') {
      item.isExpanded = true;
    }

    return Column(
      children: [
        Material(
          color: isSelected
              ? Theme.of(context).colorScheme.secondary
              : Colors.transparent,
          child: InkWell(
            onTap: () => context.go(item.route),
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
                    color: isSelected
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
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.w500
                            : FontWeight.normal,
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
