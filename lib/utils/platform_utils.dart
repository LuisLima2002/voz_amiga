import 'package:flutter/material.dart';

class FormFactor {
  static double desktop = 900;
  static double tablet = 600;
  static double handset = 300;
}

enum ScreenType {
  watch,
  handset,
  tablet,
  desktop,
}

extension MediaQueryExtensions on MediaQueryData {
  ScreenType get screenType {
    // Use .shortestSide to detect device type regardless of orientation
    double deviceWidth = size.shortestSide;
    if (deviceWidth > FormFactor.desktop) return ScreenType.desktop;
    if (deviceWidth > FormFactor.tablet) return ScreenType.tablet;
    if (deviceWidth > FormFactor.handset) return ScreenType.handset;
    return ScreenType.watch;
  }
}
