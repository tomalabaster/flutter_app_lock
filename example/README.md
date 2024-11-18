# flutter_app_lock_example

```dart
void main() {
  runApp(AppLock(
    builder: (args) => MyApp(
      data: args,
    ),
    lockScreenBuilder: (context) => LockScreen(),
    initiallyEnabled: false, // default is true, first app launches you probably want false
    initialBackgroundLockLatency: const Duration(seconds: 30), // default is 0 seconds (immediately)
    inactiveBuilder: (context) => InactiveScreen(),
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
            child: const Text('Set app lock enabled'),
            onPressed: () => AppLock.of(context)!.enable(),
          ),
          ElevatedButton(
            child: const Text('Set app lock disabled'),
            onPressed: () => AppLock.of(context)!.disable(),
          ),
          ElevatedButton(
            child: const Text('Manually show lock screen'),
            onPressed: () => AppLock.of(context)!.showLockScreen(),
          ),
          ElevatedButton(
            child: const Text('Manually show lock screen (awaiting)'),
            onPressed: () async {
              await AppLock.of(context)!.showLockScreen();

              print('Did unlock!');
            },
          ),
          ElevatedButton(
            child: const Text('Changing background lock latency'),
            onPressed: () => AppLock.of(context)!
                .setBackgroundLockLatency(const Duration(seconds: 5)),
          ),
        ],
      ),
    );
  }
}
```
