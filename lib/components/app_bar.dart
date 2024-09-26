import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:io' show Platform;

// ignore: must_be_immutable
class VaAppBar extends StatelessWidget
    implements PreferredSizeWidget, DisposableBuildContext {
  final double height;
  final String title;

  VaAppBar({
    super.key,
    required this.title,
    this.height = kToolbarHeight,
  }) {
    // ad
    if (kIsWeb || Platform.isLinux || Platform.isWindows) {
      ServicesBinding.instance.keyboard.addHandler(_popOnEscape);
    }
  }

  @override
  Size get preferredSize => Size.fromHeight(height);

  bool _popOnEscape(KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      if (_context?.canPop() == true) {
        _context?.pop();
        return true;
      }
    }
    return false;
  }

  late BuildContext? _context;
  @override
  Widget build(BuildContext context) {
    _context = context;
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

  @override
  BuildContext? get context => _context;

  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(_popOnEscape);
  }
}
