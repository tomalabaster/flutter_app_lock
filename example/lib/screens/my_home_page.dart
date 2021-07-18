import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
    this.title,
    this.data,
  }) : super(key: key);

  final String title;
  final String data;

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
            Text('App unlocked with the following data: ${this.widget.data}'),
            ElevatedButton(
              key: Key('EnableButton'),
              child: Text('Set app lock enabled'),
              onPressed: () => AppLock.of(context).enable(),
            ),
            ElevatedButton(
              key: Key('DisableButton'),
              child: Text('Set app lock disabled'),
              onPressed: () => AppLock.of(context).disable(),
            ),
            ElevatedButton(
              key: Key('ShowButton'),
              child: Text('Manually show lock screen'),
              onPressed: () => AppLock.of(context).showLockScreen(),
            ),
            ElevatedButton(
              key: Key('AwaitShowButton'),
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
