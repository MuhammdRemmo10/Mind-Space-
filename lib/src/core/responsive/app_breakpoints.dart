import 'package:flutter/widgets.dart';

class AppBreakpoints {
  const AppBreakpoints._();

  static const double compact = 600;
  static const double medium = 840;
  static const double expanded = 1200;

  static bool isCompact(BuildContext context) {
    return MediaQuery.sizeOf(context).width < compact;
  }

  static bool isMedium(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= compact && width < medium;
  }

  static bool isExpanded(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= medium;
  }
}
