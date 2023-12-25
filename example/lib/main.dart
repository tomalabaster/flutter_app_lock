import 'package:flutter/material.dart';

import 'app/app.dart';

void main({
  bool enabled = false,
  Duration backgroundLockLatency = const Duration(seconds: 30),
}) {
  runApp(MyApp(
    enabled: enabled,
    backgroundLockLatency: backgroundLockLatency,
  ));
}
