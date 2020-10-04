# flutter_app_lock

A Flutter package for showing a lock screen on app open and app pause.

If the app is launching, the lock screen is shown first and then the rest of the app is instantiated once a successful login has occured.

If the user is returning to the app after it has already launched, the login screen is shown on top of your app and can't be dismissed until another successful login.

## Getting Started

In your flutter project add the dependency:

```yaml
dependencies:
  ...
  flutter_app_lock: ^1.3.0
```

For help getting started with Flutter, view the online documentation.

## Usage example

```dart
void main() {
  runApp(AppLock(
    builder: (args) => MyApp(data: args),
    lockScreen: LockScreen(),
  ));
}
```

Simply wrap the initialization of `MyApp` (or your equivalent) in a function and pass it to the `builder` property of an `AppLock` widget.

`LockScreen` is your own widget implementing your own login logic which should call the following once a successful login has occured.

```dart
AppLock.of(context).didUnlock();
```

This will instantiate your `MyApp` (or your equivalent) if it's an app launch or simply returns to the current running instance of your app if it's resuming.

## Enabling and disabling

It is possible to enable and disable the `lockScreen` on app launch and on-demand.

```dart
runApp(AppLock(
  builder: (args) => MyApp(data: args),
  lockScreen: LockScreen(),
  enabled: false,
));
```

The above will cause `MyApp` to be built instantly and `lockScreen` will never be shown. The default for `enabled` is `true`.

You can then enable `lockScreen` later on by doing:

```dart
AppLock.of(context).enable();
```

This will now cause the `lockScreen` to be shown on app pauses.

If you wanted to disable the `lockScreen` again you can simply do:

```dart
AppLock.of(context).disable();
```

There is also a convenience method:

```dart
AppLock.of(context).setEnabled(true);
AppLock.of(context).setEnabled(false);
```

## Passing arguments

In some scenarios, it might be appropriate to unlock a database or create some other objects from the `lockScreen` and then inject them in to your `MyApp` or equivalent, so you can better guarantee that services are instantiated or databases are opened/unlocked.

You can do this by passing in an argument to the `didUnlock` method on `AppLock`:

```dart
var database = await openDatabase(...);

AppLock.of(context).didUnlock(database);
```

This object is then available as part of the `AppLock` builder method, `builder`:

```dart
...
runApp(AppLock(
  builder: (args) => MyApp(database: args), // args is the `database` object passed in to `didUnlock`
  lockScreen: LockScreen(),
));
```

## Manually showing the lock screen

In some scenarios, you might want to manually trigger the lock screen to show.

You can do this by calling:

```dart
AppLock.of(context).showLockScreen();
```

If you want to wait until the user has successfully unlocked again, `showLockScreen` returns a `Future` so you can `await` this method call.

```dart
await AppLock.of(context).showLockScreen();

print('Did unlock!');
```

## Background lock latency

It might be useful for apps to not require the lock screen to be shown immediately after entering the background state. You can now specify how long the app is allowed to be in the background before requiring the lock screen to be shown:

```dart
void main() {
  runApp(AppLock(
    ...,
    backgroundLockLatency: const Duration(seconds: 30),
  ));
}
```

The above example allows the app to be in the background for up to 30 seconds without requiring the lock screen to be shown.
