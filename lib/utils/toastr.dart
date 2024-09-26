import 'package:flutter/material.dart';

final class Toastr {
  static const Color _defaultBg = Color(0xDD232323);
  static const Color _defaultTextcolor = Colors.white;

  static success(
    BuildContext context,
    String message,
  ) {
    toast(
      context,
      message: message,
      backgroundColor: const Color(0x8A005700),
      icon: Icons.playlist_add_check_circle_sharp,
      textColor: Colors.white,
    );
  }

  static toast(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
    IconData? icon,
    Color? textColor,
  }) {
    final scaffold = ScaffoldMessenger.of(context);

    final Widget messageBox = icon == null
        ? Text(
            message,
            style: TextStyle(
              color: textColor ?? _defaultTextcolor,
            ),
          )
        : Row(
            children: [
              Icon(
                Icons.check_circle_sharp,
                color: textColor ?? _defaultTextcolor,
              ),
              const SizedBox(width: 4),
              Text(
                message,
                style: TextStyle(
                  color: textColor ?? _defaultTextcolor,
                ),
              ),
            ],
          );

    scaffold.showSnackBar(
      snackBarAnimationStyle: AnimationStyle(
        curve: Curves.easeOut,
        duration: const Duration(seconds: 1),
      ),
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 1),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(30),
                ),
                color: backgroundColor ?? _defaultBg,
              ),
              child: messageBox,
            ),
          ],
        ),
        // action: SnackBarAction(
        //   label: 'UNDO',
        //   onPressed: scaffold.hideCurrentSnackBar,
        // ),
      ),
    );
  }
}
