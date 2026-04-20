import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class Responsive {
  static double _screenWidth = 0;
  static double _screenHeight = 0;

  static double get screenWidth {
    if (_screenWidth == 0) {
      final view = ui.PlatformDispatcher.instance.views.first;
      _screenWidth = view.physicalSize.width / view.devicePixelRatio;
    }
    return _screenWidth;
  }

  static double get screenHeight {
    if (_screenHeight == 0) {
      final view = ui.PlatformDispatcher.instance.views.first;
      _screenHeight = view.physicalSize.height / view.devicePixelRatio;
    }
    return _screenHeight;
  }

  static void init(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
  }

  static double s(double size) => getFontSize(size);

  static double getFontSize(double size) {
    final width = screenWidth;
    if (width < 360) {
      return size * 0.85;
    } else if (width < 600) {
      return size;
    } else {
      return size * 1.2;
    }
  }

  static double getIconSize(double size) => getFontSize(size);
  static double getContainerSize(double size) => getFontSize(size);
  static double getCardSize(double size) => getFontSize(size);
}
