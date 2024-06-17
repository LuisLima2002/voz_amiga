import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final String title;
  const VaAppBar({
    super.key,
    required this.title,
    this.height = kToolbarHeight,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: true,
      leading: context.canPop()
          ? IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
            )
          : null,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      // actions: [_menu()],
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );
  }
}
