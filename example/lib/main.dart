import 'package:flutter/material.dart';

import 'app/app.dart';

void main({
  bool enabled = false,
  @visibleForTesting
  Duration backgroundLockLatency = const Duration(seconds: 30),
}) {
  runApp(MyApp(
    enabled: enabled,
    backgroundLockLatency: backgroundLockLatency,
  ));
}
