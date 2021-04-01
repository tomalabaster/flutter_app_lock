import 'dart:async';

import 'package:flutter/material.dart';

/// A widget which handles app lifecycle events for showing and hiding a lock screen.
/// This should wrap around a `MyApp` widget (or equivalent).
///
/// [lockScreen] is a [Widget] which should be a screen for handling login logic and
/// calling `AppLock.of(context).didUnlock();` upon a successful login.
///
/// [builder] is a [Function] taking an [Object] as its argument and should return a
/// [Widget]. The [Object] argument is provided by the [lockScreen] calling
/// `AppLock.of(context).didUnlock();` with an argument. [Object] can then be injected
/// in to your `MyApp` widget (or equivalent).
///
/// [enabled] determines wether or not the [lockScreen] should be shown on app launch
/// and subsequent app pauses. This can be changed later on using `AppLock.of(context).enable();`,
/// `AppLock.of(context).disable();` or the convenience method `AppLock.of(context).setEnabled(enabled);`
/// using a bool argument.
///
/// [backgroundLockLatency] determines how much time is allowed to pass when
/// the app is in the background state before the [lockScreen] widget should be
/// shown upon returning. It defaults to instantly.
class AppLock extends StatefulWidget {
  final Widget Function(Object) builder;
  final Widget lockScreen;
  final bool enabled;
  final Duration backgroundLockLatency;
  final ThemeData theme;

  const AppLock({
    Key key,
    @required this.builder,
    @required this.lockScreen,
    this.enabled = true,
    this.backgroundLockLatency = const Duration(seconds: 0),
    this.theme,
  }) : super(key: key);

  static _AppLockState of(BuildContext context) =>
      context.findAncestorStateOfType<_AppLockState>();

  @override
  _AppLockState createState() => _AppLockState();
}

class _AppLockState extends State<AppLock> with WidgetsBindingObserver {
  bool _didUnlockForAppLaunch;
  bool _isLocked;
  bool _enabled;

  Timer _backgroundLockLatencyTimer;

  Completer<void> _completer;

  Widget _child;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    this._didUnlockForAppLaunch = !this.widget.enabled;
    this._isLocked = false;
    this._enabled = this.widget.enabled;

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!this._enabled) {
      return;
    }

    if (state == AppLifecycleState.paused &&
        (!this._isLocked && this._didUnlockForAppLaunch)) {
      this._backgroundLockLatencyTimer =
          Timer(this.widget.backgroundLockLatency, () => this.showLockScreen());
    }

    if (state == AppLifecycleState.resumed) {
      this._backgroundLockLatencyTimer?.cancel();
    }

    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    this._backgroundLockLatencyTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (this._didUnlockForAppLaunch) this._child,
        if (this._isLocked || !this._didUnlockForAppLaunch)
          HeroControllerScope.none(
            child: Navigator(
              pages: [MaterialPage(child: this._lockScreen)],
              onPopPage: (route, result) {
                return route.didPop(result);
              },
            ),
          )
      ],
    );
  }

  Widget get _lockScreen {
    return WillPopScope(
      child: this.widget.lockScreen,
      onWillPop: () => Future.value(false),
    );
  }

  /// Causes `AppLock` to either pop the [lockScreen] if the app is already running
  /// or instantiates widget returned from the [builder] method if the app is cold
  /// launched.
  ///
  /// [args] is an optional argument which will get passed to the [builder] method
  /// when built. Use this when you want to inject objects created from the
  /// [lockScreen] in to the rest of your app so you can better guarantee that some
  /// objects, services or databases are already instantiated before using them.
  void didUnlock([Object args]) {
    if (this._didUnlockForAppLaunch) {
      this._didUnlockOnAppPaused();
    } else {
      this._didUnlockOnAppLaunch(args);
    }
  }

  /// Makes sure that [AppLock] shows the [lockScreen] on subsequent app pauses if
  /// [enabled] is true of makes sure it isn't shown on subsequent app pauses if
  /// [enabled] is false.
  ///
  /// This is a convenience method for calling the [enable] or [disable] method based
  /// on [enabled].
  void setEnabled(bool enabled) {
    if (enabled) {
      this.enable();
    } else {
      this.disable();
    }
  }

  /// Makes sure that [AppLock] shows the [lockScreen] on subsequent app pauses.
  void enable() {
    setState(() {
      this._enabled = true;
    });
  }

  /// Makes sure that [AppLock] doesn't show the [lockScreen] on subsequent app pauses.
  void disable() {
    setState(() {
      this._enabled = false;
    });
  }

  /// Manually show the [lockScreen].
  Future<void> showLockScreen() {
    if (this._completer != null) {
      return this._completer.future;
    }

    this._completer = Completer();

    setState(() {
      this._isLocked = true;
    });

    return this._completer.future;
  }

  void _didUnlockOnAppLaunch(Object args) {
    setState(() {
      this._didUnlockForAppLaunch = true;
      this._child = this.widget.builder(args);
    });
  }

  void _didUnlockOnAppPaused() {
    setState(() {
      this._isLocked = false;
    });

    this._completer?.complete();
    this._completer = null;
  }
}
