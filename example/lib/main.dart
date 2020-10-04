import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';

import 'app/app.dart';
import 'screens/lock_screen.dart';

void main() {
  runApp(AppLock(
    builder: (args) => MyApp(
      data: args,
    ),
    lockScreen: LockScreen(),
    enabled: false,
    backgroundLockLatency: const Duration(seconds: 30),
  ));
}
