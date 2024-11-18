import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';

import '../screens/lock_screen.dart';
import '../screens/my_home_page.dart';

class MyApp extends StatelessWidget {
  final bool initiallyEnabled;

  @visibleForTesting
  final Duration initialBackgroundLockLatency;

  const MyApp({
    super.key,
    this.initiallyEnabled = false,
    required this.initialBackgroundLockLatency,
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
        initiallyEnabled: initiallyEnabled,
        initialBackgroundLockLatency: initialBackgroundLockLatency,
        inactiveBuilder: (context) => const Scaffold(
          key: Key('InactiveScreen'),
          body: Center(
            child: FlutterLogo(size: 80),
          ),
        ),
      ),
      home: const MyHomePage(
        key: Key('MyHomePage'),
        title: 'Flutter Demo Home Page',
      ),
    );
  }
}
