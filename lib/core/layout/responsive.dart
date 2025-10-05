import 'package:flutter/widgets.dart';

class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

bool isMobile(BuildContext context) => MediaQuery.sizeOf(context).width < Breakpoints.mobile;
bool isTablet(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  return w >= Breakpoints.mobile && w < Breakpoints.desktop;
}
bool isDesktop(BuildContext context) => MediaQuery.sizeOf(context).width >= Breakpoints.desktop;

class CenterConstrained extends StatelessWidget {
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final Widget child;
  const CenterConstrained({super.key, this.maxWidth = 1200, this.padding = EdgeInsets.zero, required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

