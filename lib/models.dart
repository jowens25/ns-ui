import 'package:flutter/material.dart';

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
