// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
                'App unlocked with the following data: ${AppLock.of(context)!.launchArg}'),
            ElevatedButton(
              key: const Key('EnableButton'),
              child: const Text('Set app lock enabled'),
              onPressed: () => AppLock.of(context)!.enable(),
            ),
            ElevatedButton(
              key: const Key('DisableButton'),
              child: const Text('Set app lock disabled'),
              onPressed: () => AppLock.of(context)!.disable(),
            ),
            ElevatedButton(
              key: const Key('ShowButton'),
              child: const Text('Manually show lock screen'),
              onPressed: () => AppLock.of(context)!.showLockScreen(),
            ),
            ElevatedButton(
              key: const Key('AwaitShowButton'),
              child: const Text('Manually show lock screen (awaiting)'),
              onPressed: () async {
                await AppLock.of(context)!.showLockScreen();

                if (kDebugMode) {
                  print('Did unlock!');
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
