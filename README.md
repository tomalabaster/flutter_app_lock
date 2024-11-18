# flutter_app_lock

A Flutter package for showing a lock screen on app open and app pause.

If the app is launching, the lock screen is shown first and then the rest of the app is instantiated once a successful login has occured.

If the user is returning to the app after it has already launched, the login screen is shown on top of your app and can't be dismissed until another successful login.

## Getting Started

In your flutter project add the dependency:

```yaml
dependencies:
  ...
  flutter_app_lock: ^4.2.0
```

For help getting started with Flutter, view the online documentation.

## Usage example

```dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  ...

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      ...,
      builder: (context, child) => AppLock(
        builder: (context, arg) => child!,
        lockScreenBuilder: (context) => LockScreen(),
      ),
    );
  }
}
```

Simply use your `MaterialApp`'s `builder` property to return an `AppLock` widget, passing `child` to its own `builder` property.

**Note:** While I mention `MaterialApp` throughout this README, this is also compatible with `CupertinoApp` and `WidgetsApp` widgets.

`LockScreen` is your own widget implementing your own login logic which should call the following once a successful login has occured.

```dart
AppLock.of(context)!.didUnlock();
```

This will now make the `MaterialApp`'s `Navigator` or `Router` the top most widget.

### Theme

Because `AppLock` is expected to be returned within your `MaterialApp`'s `builder` method, your existing `theme` and `theme` variants will style the widget returned from `lockScreenBuilder` automatically.

```dart
MaterialApp(
  ...,
  theme: ThemeData(
    ...,
  ),
  builder: (context, child) => AppLock(
    builder: (context, arg) => child!,
    lockScreenBuilder: (context) => LockScreen(),
  ),
);
```

## Enabling and disabling

It is possible to enable and disable the showing of the widget returned from `lockScreenBuilder` on app launch and on-demand.

```dart
MaterialApp(
  ...,
  builder: (context, child) => AppLock(
    builder: (context, arg) => child!,
    lockScreenBuilder: (context) => LockScreen(),
    enabled: false,
  ),
);
```

The above will cause `child` (your `MaterialApp`'s `Navigator` or `Router`) to be built instantly and the widget returned from `lockScreenBuilder` will never be shown. The default for `enabled` is `true`.

You can then enable the showing of the widget returned from `lockScreenBuilder` later on by doing:

```dart
AppLock.of(context)!.enable();
```

This will now cause the widget returned from `lockScreenBuilder` to be shown on app pauses.

If you wanted to disable the showing of the widget returned from `lockScreenBuilder` again you can simply do:

```dart
AppLock.of(context)!.disable();
```

There is also a convenience method:

```dart
AppLock.of(context)!.setEnabled(true);
AppLock.of(context)!.setEnabled(false);
```

## Passing arguments

In some scenarios, it might be appropriate to unlock a database or create some other objects from the widget returned from `lockScreenBuilder` and then expose them to your app further down the tree, so you can better guarantee that services are instantiated or databases are opened/unlocked.

You can do this by passing in an argument to the `didUnlock` method on `AppLock`:

```dart
var database = await openDatabase(...);

AppLock.of(context)!.didUnlock(database);
```

This object is then available as part of the `AppLock` builder method, `builder`:

```dart
MaterialApp(
  ...,
  builder: (context, child) => AppLock(
    builder: (context, arg) => child!, // arg is the `database` object passed in to `didUnlock`
    lockScreenBuilder: (context) => LockScreen(),
  ),
);
```

It is also available by calling `AppLock.of(context)!.launchArg`.

## Manually showing the lock screen

In some scenarios, you might want to manually trigger the lock screen to show.

You can do this by calling:

```dart
AppLock.of(context)!.showLockScreen();
```

If you want to wait until the user has successfully unlocked again, `showLockScreen` returns a `Future` so you can `await` this method call.

```dart
await AppLock.of(context)!.showLockScreen();

print('Did unlock!');
```

## Background lock latency

It might be useful for apps to not require the lock screen to be shown immediately after entering the background state. You can now specify how long the app is allowed to be in the background before requiring the lock screen to be shown:

```dart
MaterialApp(
  ...,
  builder: (context, child) => AppLock(
    ...,
    backgroundLockLatency: const Duration(seconds: 30),
  ),
);
```

The above example allows the app to be in the background for up to 30 seconds without requiring the lock screen to be shown.

## Inactive statuses (e.g. app switcher)

When the app becomes "inactive", for example by launching the device app switcher or device notification center, you can now configure a widget to be shown when this occurs:

```dart
MaterialApp(
  ...,
  builder: (context, child) => AppLock(
    ...,
    inactiveBuilder: (context) => InactiveScreen(),
  ),
);
```

`InactiveScreen` is your own widget implementing your own requirements for a screen shown while the app is inactive.

[There are limitations to this as noted on issue #6 on GitHub](https://github.com/tomalabaster/flutter_app_lock/issues/6#issuecomment-1872616800).

## Tests

Integration tests have been introduced in the example project and were used to confirm the behaviour hasn't changed since the move to null-safety.

They can be run by running `flutter test integration_test/integration_tests.dart` in a terminal.
