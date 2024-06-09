import 'package:flutter/material.dart';

class UpdateAppbar extends Notification {
  final String title;
  final Widget? leading;

  UpdateAppbar({
    this.title = 'Voz Amiga',
    this.leading,
  });
}
