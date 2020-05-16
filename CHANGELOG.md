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
