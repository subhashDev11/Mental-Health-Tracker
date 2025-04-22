import 'package:flutter/material.dart';

class ResponsiveWidget extends StatelessWidget {
  const ResponsiveWidget({
    super.key,
    required this.mobView,
    required this.deskView,
  });

  final Widget mobView;
  final Widget deskView;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, deviceCons) {
        if (deviceCons.maxWidth <= 600) {
          return mobView;
        } else if (deviceCons.maxWidth >= 800 && deviceCons.maxWidth <= 600) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: mobView,
          );
        } else if (deviceCons.maxHeight >= 800) {
          return deskView;
        } else {
          return deskView;
        }
      },
    );
  }
}
