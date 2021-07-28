import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';

import 'app/app.dart';
import 'screens/lock_screen.dart';

void main({
  @visibleForTesting bool enabled = false,
  @visibleForTesting
      Duration backgroundLockLatency = const Duration(seconds: 30),
}) {
  runApp(AppLock(
    builder: (args) => MyApp(
      key: Key('MyApp'),
      data: args,
    ),
    lockScreen: LockScreen(
      key: Key('LockScreen'),
    ),
    enabled: enabled,
    backgroundLockLatency: backgroundLockLatency,
  ));
}
