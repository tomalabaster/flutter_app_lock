## 4.2.0+2 - 18th November 2024

**NOTE:** Use 4.2.0 or 4.2.0+2 only as 4.2.0+1 was mistakenly published from a WIP branch

- Ability to change the background lock latency from a descendant using `AppLock.of(context).setBackgroundLockLatency(duration);` (closes [pull request #27](https://github.com/tomalabaster/flutter_app_lock/pull/27))
- **Deprecation:** `enabled` is now deprecated and will be removed in the next major versions, please use `initiallyEnabled` instead (provides clarity based on discussion on [pull request #27](https://github.com/tomalabaster/flutter_app_lock/pull/27))
- **Deprecation:** `backgroundLockLatency` is now deprecated and will be removed in the next major versions, please use `initalBackgroundLockLatency` instead (provides clarity based on discussion on [pull request #27](https://github.com/tomalabaster/flutter_app_lock/pull/27))

Thank you to [@jakobleck](https://github.com/jakobleck) and [@Bptmn](https://github.com/Bptmn) for helping to drive this forward through an initial pull request, suggestions and conversation!

## 4.2.0+1 - 18th November 2024

- Due to an admin error, 4.2.0+1 was meant to only contain documentation updates but instead was published with a WIP rewrite at [this git commit](https://github.com/tomalabaster/flutter_app_lock/tree/8a767af95823ca21e43184bc3544ac37ebfe89aa)

## 4.2.0 - 18th November 2024

- Exact same code as 4.2.0+2 above just without all of the documentation updates

## 4.1.1+1 - 30th December 2023

- Updates to README

## 4.1.1 - 30th December 2023

- Fix for app still locking if the app resumes before the end of the background lock latency

## 4.1.0 - 30th December 2023

- Inactive state!
  - When the app becomes inactive (e.g. viewing the device's recent app switcher or notification center) you can now show a custom screen (see [issue #6](https://github.com/tomalabaster/flutter_app_lock/issues/6) for limitations)
  - This can be used instead of or along side the existing lock screen mechanism
- **Deprecation:** `lockScreen` is now deprecated and will be removed in the next major version, please use `lockScreenBuilder` instead (closes [issue #23](https://github.com/tomalabaster/flutter_app_lock/issues/23))

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

Thank you to [@vishnukvmd](https://github.com/vishnukvmd) and [@dshukertjr](https://github.com/dshukertjr) for contributing these changes!

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

Thank you to [@rdev-software](https://github.com/rdev-software) for contributing this change!

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
