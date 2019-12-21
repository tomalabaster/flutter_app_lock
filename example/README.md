# flutter_app_lock_example

```dart
void main() {
  runApp(AppLock(
    builder: (args) => MyApp(
      data: args,
    ),
    lockScreen: LockScreen(),
    enabled: false,
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
          RaisedButton(
            child: Text('Set app lock enabled'),
            onPressed: () => AppLock.of(context).enable(),
          ),
          RaisedButton(
            child: Text('Set app lock disabled'),
            onPressed: () => AppLock.of(context).disable(),
          ),
        ],
      ),
    );
  }
}
```
