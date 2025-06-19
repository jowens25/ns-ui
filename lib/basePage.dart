import 'package:flutter/material.dart';

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
