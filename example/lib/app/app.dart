import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';

import '../screens/lock_screen.dart';
import '../screens/my_home_page.dart';
import '../screens/my_other_page.dart';

class MyApp extends StatelessWidget {
  final String data;

  const MyApp({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (context) => MyHomePage(title: 'Flutter Demo Home Page'),
        '/other-page': (context) => MyOtherPage(),
      },
      builder: (context, child) {
        return AppLock(
          builder: (_) => child,
          lockScreen: LockScreen(),
          enabled: true,
          backgroundLockLatency: const Duration(seconds: 0),
        );
      },
    );
  }
}
