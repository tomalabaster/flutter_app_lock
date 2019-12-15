import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';

import 'app/app.dart';
import 'screens/lock_screen.dart';

void main() {
  runApp(AppLock(
    child: (args) => MyApp(
      data: args,
    ),
    lockScreen: LockScreen(),
  ));
}
