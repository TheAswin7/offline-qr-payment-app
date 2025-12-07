import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';

class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final bool enableScroll;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final bool extendBodyBehindAppBar;
  final Color? appBarColor;
  final bool automaticallyImplyLeading;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.enableScroll = true,
    this.padding,
    this.backgroundColor,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.extendBodyBehindAppBar = false,
    this.appBarColor,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    final safeAreaBody = SafeArea(
      child: enableScroll
          ? SingleChildScrollView(
              padding: padding ?? ResponsiveUtils.getResponsivePadding(context,
                  left: 16, top: 8, right: 16, bottom: 20),
              child: body,
            )
          : Padding(
              padding: padding ?? ResponsiveUtils.getResponsivePadding(context,
                  left: 16, top: 8, right: 16, bottom: 0),
              child: body,
            ),
    );

    return Scaffold(
      appBar: appBar,
      body: safeAreaBody,
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }
}

// Custom responsive text widget
class ResponsiveText extends StatelessWidget {
  final String text;
  final double baseFontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextDecoration? decoration;

  const ResponsiveText(
    this.text, {
    Key? key,
    this.baseFontSize = 16.0,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseFontSize),
        fontWeight: fontWeight,
        color: color,
        decoration: decoration,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

// Custom responsive button
class ResponsiveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double baseHeight;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double borderRadius;

  const ResponsiveButton({
    Key? key,
    this.onPressed,
    required this.child,
    this.baseHeight = 48.0,
    this.isFullWidth = true,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonWidget = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveUtils.getResponsiveSpacing(context, baseHeight / 4),
          horizontal: ResponsiveUtils.getResponsiveSpacing(context, 16),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: 0,
      ),
      child: child,
    );

    return isFullWidth
        ? Container(
            constraints: const BoxConstraints(maxWidth: 360),
            width: double.infinity,
            child: buttonWidget,
          )
        : buttonWidget;
  }
}
