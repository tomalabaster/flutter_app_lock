import 'package:flutter/material.dart';

import 'app/app.dart';

void main({
  bool initiallyEnabled = false,
  @visibleForTesting
  Duration backgroundLockLatency = const Duration(seconds: 30),
}) {
  runApp(MyApp(
    initiallyEnabled: initiallyEnabled,
    backgroundLockLatency: backgroundLockLatency,
  ));
}
