import 'package:flutter/material.dart';

import 'app/app.dart';

void main({
  bool enabled = false,
  Duration backgroundLockLatency = const Duration(seconds: 0),
}) {
  runApp(MyApp(
    key: const Key('MyApp'),
    enabled: enabled,
    backgroundLockLatency: backgroundLockLatency,
  ));
}
