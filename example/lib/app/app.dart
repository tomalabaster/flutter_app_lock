import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';

import '../screens/lock_screen.dart';
import '../screens/my_home_page.dart';

class MyApp extends StatelessWidget {
  final bool enabled;
  final Duration backgroundLockLatency;

  const MyApp({
    super.key,
    this.enabled = false,
    this.backgroundLockLatency = const Duration(seconds: 30),
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      builder: (context, child) => AppLock(
        builder: (context, arg) => child!,
        lockScreenBuilder: (context) => const LockScreen(
          key: Key('LockScreen'),
        ),
        enabled: enabled,
        backgroundLockLatency: backgroundLockLatency,
      ),
      home: const MyHomePage(
        key: Key('MyHomePage'),
        title: 'Flutter Demo Home Page',
      ),
    );
  }
}
