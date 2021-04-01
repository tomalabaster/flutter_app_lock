import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

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
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            ElevatedButton(
              child: Text('Set app lock enabled'),
              onPressed: () => AppLock.of(context).enable(),
            ),
            ElevatedButton(
              child: Text('Set app lock disabled'),
              onPressed: () => AppLock.of(context).disable(),
            ),
            ElevatedButton(
              child: Text('Manually show lock screen'),
              onPressed: () => AppLock.of(context).showLockScreen(),
            ),
            ElevatedButton(
              child: Text('Manually show lock screen (awaiting)'),
              onPressed: () async {
                await AppLock.of(context).showLockScreen();

                print('Did unlock!');
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
