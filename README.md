# flutter_app_lock

A Flutter package for shwoing a lock screen on app open and app pause.

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
    child: () => MyApp(),
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
