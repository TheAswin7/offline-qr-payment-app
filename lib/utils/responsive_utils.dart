import 'package:flutter/material.dart';

class ResponsiveUtils {
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final double screenWidth = MediaQuery.of(context).size.width;
    // Base font size at 375px (iPhone standard)
    double scale = screenWidth / 375.0;
    // Clamp the scale between 0.8 and 1.4 for better readability
    scale = scale.clamp(0.8, 1.4);
    return baseSize * scale;
  }

  static double getResponsiveSpacing(BuildContext context, double baseSize) {
    final double screenWidth = MediaQuery.of(context).size.width;
    double scale = screenWidth / 375.0;
    scale = scale.clamp(0.8, 1.2);
    return baseSize * scale;
  }

  static double getResponsiveIconSize(BuildContext context, double baseSize) {
    final double screenWidth = MediaQuery.of(context).size.width;
    double scale = screenWidth / 375.0;
    scale = scale.clamp(0.9, 1.3);
    return baseSize * scale;
  }

  static EdgeInsets getResponsivePadding(BuildContext context, {
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    double scale = screenWidth / 375.0;
    scale = scale.clamp(0.8, 1.2);
    return EdgeInsets.only(
      left: left * scale,
      top: top * scale,
      right: right * scale,
      bottom: bottom * scale,
    );
  }

  static BoxConstraints getMaxWidthConstraints(double maxWidth) {
    return BoxConstraints(maxWidth: maxWidth);
  }

  static Widget responsiveGestureDetector({
    required Widget child,
    required VoidCallback onTap,
    HitTestBehavior behavior = HitTestBehavior.opaque,
  }) {
    return GestureDetector(
      behavior: behavior,
      onTap: onTap,
      child: child,
    );
  }

  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 375;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  static double getBottomPadding(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }
}
