## 4.0.1 - 25th December 2023

- **Breaking change:** requires Flutter 3.16.0 or greater
- **Breaking change:** requires Dart 3.0.0 or greater
- Using `AppLifecycleState.hidden` instead of `AppLifecycleState.paused`
- Package upgrades and deprecation fixes

## 4.0.0 - 25th December 2023

Version `4.0.0` general availabilty, see changes in `4.0.0-dev.0 - 21st November 2022` below.

## 4.0.0-dev.0 - 21st November 2022

**`MaterialApp` is no longer used under the hood!**

Version `4.0.0` uses a `Navigator` directly instead of a `MaterialApp`. The new required use of `AppLock` allows you to make use of your own `MaterialApp`'s theming.

Old:
```dart
void main() {
  runApp(AppLock(
    builder: (arg) => MyApp(data: arg),
    lockScreen: LockScreen(),
  ));
}
```

New:
```dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  ...

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      ...
      builder: (context, child) => AppLock(
        builder: (context, arg) => child!,
        lockScreen: LockScreen(),
      ),
      ...
    );
  }
}
```

**Breaking changes:**
- `builder` now requires a callback which receives a `BuildContext` and an `Object?`
- `theme` is no longer available

**Non-breaking changes:**
- `AppLock` now exposes a `launchArg` property which is an `Object?`

## 3.0.0 - 28th October 2022

Flutter 3 support!

Flutter 3 was always supported, but the `!` operator has been removed from calls to `WidgetsBinding.instance` which was causing an annoying warning.

All packages have been upgraded and the example project has also been upgraded.

## 2.0.0 - 28th July 2021

Migrated to null-safety!

There are now also integration tests in the example project which can be run using `flutter test integration_test/integration_tests.dart`.

## 1.5.0 - 1st April 2021

Added the ability to override the `theme` property of the `MaterialApp` which `AppLock` uses internally.

```dart
runApp(AppLock(
  ...
  theme: ThemeData(
    textTheme: TextTheme(
      headline1: TextStyle(fontSize: 32),
    ),
  ),
));
```

`debugShowCheckedModeBanner` has also been set to false.

## 1.4.0+1 - 4th Oct 2020

Minor updates to docs.

## 1.4.0 - 4th Oct 2020

New functionality to specify a period of time between the app going into the background state and when the lock screen should be shown.

```dart
runApp(AppLock(
  ...,
  backgroundLockLatency: const Duration(seconds: 30),
));
```

This allows the app to go into the background state for the specified duration without causing the lock screen to be shown.

## 1.3.1 - 16th May 2020

`showLockScreen` is now a `Future`.

```dart
await AppLock.of(context).showLockScreen();

print('Did unlock!');
```

## 1.3.0 - 16th May 2020

New functionality to show the lock screen on-demand.

```dart
AppLock.of(context).showLockScreen();
```

## 1.2.0+1 - 21st Feb 2020

Update to description.

## 1.2.0 - 21st Dec 2019

New functionality to enable or disable the `lockScreen` at launch and on-demand.

```dart
runApp(AppLock(
  builder: ...,
  lockScreen: ...,
  enabled: false,
));
```

```dart
AppLock.of(context).enable();
AppLock.of(context).disable();
```

## 1.1.0+2 - 21st Dec 2019

- Removing deprecating `child` method in preference for the `builder` method.
- Updating Flutter version constraints

## 1.1.0+1 - 15th Dec 2019

Deprecating `child` method in preference for the `builder` method - simply a name change.

## 1.1.0 - 15th Dec 2019

**Breaking change**

An argument can now be passed in to the `AppLock` method `didUnlock` and is accessible through the builder method, `child` - this should be considered a **breaking change** as the builder method, `child` requires a parameter even if null is passed in to `didUnlock`.

## 1.0.0 - 15th Dec 2019

Initial release

Use `AppLock` to provide lock screen functionality to you Flutter apps.
