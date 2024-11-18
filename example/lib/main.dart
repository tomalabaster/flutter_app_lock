import 'package:flutter/material.dart';

import 'app/app.dart';

void main({
  bool initiallyEnabled = false,
  @visibleForTesting
  Duration initialBackgroundLockLatency = const Duration(seconds: 30),
}) {
  runApp(MyApp(
    initiallyEnabled: initiallyEnabled,
    initialBackgroundLockLatency: initialBackgroundLockLatency,
  ));
}
