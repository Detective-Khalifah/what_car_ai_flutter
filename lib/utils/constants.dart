import 'package:flutter/widgets.dart';

class Constants {
  static final MediaQueryData _mediaQuery = MediaQueryData.fromView(
      WidgetsBinding.instance.platformDispatcher.views.first);

  static double get screenWidth => _mediaQuery.size.width;
  static double get screenHeight => _mediaQuery.size.height;
}
