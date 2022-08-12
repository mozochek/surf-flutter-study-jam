import 'package:flutter/material.dart';

class OverscrollGlowDisabler extends StatelessWidget {
  final Widget child;

  const OverscrollGlowDisabler({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (notification) {
        if (notification is OverscrollIndicatorNotification) {
          notification.disallowIndicator();
        }

        return false;
      },
      child: child,
    );
  }
}
