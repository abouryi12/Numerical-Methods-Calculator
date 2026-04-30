import 'package:flutter/material.dart';

/// Breakpoints for responsive layout.
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

/// Returns true if the screen width is >= [Breakpoints.tablet].
bool isWideScreen(BuildContext context) =>
    MediaQuery.of(context).size.width >= Breakpoints.tablet;

/// Returns true if the screen width is >= [Breakpoints.desktop].
bool isDesktop(BuildContext context) =>
    MediaQuery.of(context).size.width >= Breakpoints.desktop;

/// A container that centers its child with a max width on larger screens.
///
/// On mobile the child stretches to the full width.
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 720,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );
  }
}
