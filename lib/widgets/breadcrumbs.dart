
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BreadcrumbItem {
  final String title;
  final String path;
  final VoidCallback? onTap;

  BreadcrumbItem({required this.title, required this.path, this.onTap});
}

class Breadcrumbs extends StatelessWidget {
  final List<BreadcrumbItem> items;

  const Breadcrumbs({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _buildBreadcrumbItems(context),
        ),
      ),
    );
  }

  List<Widget> _buildBreadcrumbItems(BuildContext context) {
    final List<Widget> widgets = [];
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final isLast = i == items.length - 1;

      widgets.add(
        InkWell(
          onTap: item.onTap ?? () => context.go(item.path),
          child: Text(
            item.title,
            style: TextStyle(
              color: isLast ? Colors.black : Colors.blue,
              fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      );

      if (!isLast) {
        widgets.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('/'),
          ),
        );
      }
    }
    return widgets;
  }
}
