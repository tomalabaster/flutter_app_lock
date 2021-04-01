# flutter_app_lock_example

```dart
void main() {
  runApp(AppLock(
    builder: (args) => MyApp(
      data: args,
    ),
    lockScreen: LockScreen(),
    enabled: false, // default is true, first app launches you probably want false
    backgroundLockLatency: const Duration(seconds: 30), // default is 0 seconds (immediately)
  ));
}
```

```dart
class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
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
    );
  }
}
```
