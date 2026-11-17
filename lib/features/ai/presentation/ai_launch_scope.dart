import 'package:flutter/widgets.dart';

import '../data/ai_launch_context.dart';

class AiLaunchScope extends InheritedWidget {
  const AiLaunchScope({
    super.key,
    required this.launchContext,
    required super.child,
  });

  final AiLaunchContext? launchContext;

  static AiLaunchContext? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AiLaunchScope>()
        ?.launchContext;
  }

  @override
  bool updateShouldNotify(AiLaunchScope oldWidget) {
    return oldWidget.launchContext != launchContext;
  }
}
