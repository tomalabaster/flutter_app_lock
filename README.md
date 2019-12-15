# flutter_app_lock

A Flutter package for showing a lock screen on app open and app pause.

If the app is launching, the lock screen is shown first and then the rest of the app is instantiated once a successful login has occured.

If the user is returning to the app after it has already launched, the login screen is shown on top of your app and can't be dismissed until another successful login.

## Getting Started

In your flutter project add the dependency:

```yaml
dependencies:
  ...
  flutter_app_lock: ^1.0.0
```

For help getting started with Flutter, view the online documentation.

## Usage example

```dart
void main() {
  runApp(AppLock(
    child: (args) => MyApp(data: args),
    lockScreen: LockScreen(),
  ));
}
```

Simply wrap the initialization of `MyApp` (or your equivalent) in a function and pass it to the `child` property of an `AppLock` widget.

`LockScreen` is your own widget implementing your own login logic which should call the following once a successful login has occured.

```dart
AppLock.of(context).didUnlock();
```

This will instantiate your `MyApp` (or your equivalent) if it's an app launch or simply returns to the current running instance of your app if it's resuming.

## Passing arguments

In some scenarios, it might be appropriate to unlock a database or create some other objects from the `LockScreen` and then inject them in to your `MyApp` or equivalent, so you can better guarantee that services are instantiated or databases are opened/unlocked.

You can do this by passing in an argument to the `didUnlock` method on `AppLock`:

```dart
var database = await openDatabase(...);

AppLock.of(context).didUnlock(database);
```

This object is then available as part of the `AppLock` builder method, `child`:

```dart
...
runApp(AppLock(
  child: (args) => MyApp(database: args), // args is the `database` object passed in to `didUnlock`
  lockScreen: LockScreen(),
));
```
