// ignore_for_file: library_private_types_in_public_api

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
  static const String lockScreenRoute = '/lock-screen';
  static const String defaultUnlockedRoute = '/unlocked';

  final Widget lockScreen;
  final bool enabled;
  final Duration backgroundLockLatency;
  final LockedAppBuilder appBuilder;
  final String initialRoute;
  final Map<String, Widget Function(BuildContext)> routes;

  AppLock({
    Key? key,
    required Widget Function(Object? arg) builder,
    required Widget lockScreen,
    bool enabled = true,
    Duration backgroundLockLatency = const Duration(seconds: 0),
    ThemeData? theme,
  }) : this.builder(
          key: key,
          appBuilder: (navigatorKey, initialRoute, routes) => MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            routes: routes,
            initialRoute: initialRoute,
            theme: theme,
          ),
          initialRoute: defaultUnlockedRoute,
          routes: {
            defaultUnlockedRoute: (context) =>
                builder(ModalRoute.of(context)!.settings.arguments),
          },
          lockScreen: lockScreen,
          enabled: enabled,
          backgroundLockLatency: backgroundLockLatency,
        );

  const AppLock.builder({
    Key? key,
    required this.appBuilder,
    required this.initialRoute,
    required this.routes,
    required this.lockScreen,
    this.enabled = true,
    this.backgroundLockLatency = const Duration(seconds: 0),
  }) : super(key: key);

  static _AppLockState? of(BuildContext context) =>
      context.findAncestorStateOfType<_AppLockState>();

  @override
  _AppLockState createState() => _AppLockState();
}

class _AppLockState extends State<AppLock> with WidgetsBindingObserver {
  static final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();

  late bool _didUnlockForAppLaunch;
  late bool _isLocked;
  late bool _enabled;

  Timer? _backgroundLockLatencyTimer;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    _didUnlockForAppLaunch = !widget.enabled;
    _isLocked = false;
    _enabled = widget.enabled;

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_enabled) {
      return;
    }

    if (state == AppLifecycleState.paused &&
        (!_isLocked && _didUnlockForAppLaunch)) {
      _backgroundLockLatencyTimer =
          Timer(widget.backgroundLockLatency, () => showLockScreen());
    }

    if (state == AppLifecycleState.resumed) {
      _backgroundLockLatencyTimer?.cancel();
    }

    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _backgroundLockLatencyTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.appBuilder.call(
      _navigatorKey,
      widget.enabled ? AppLock.lockScreenRoute : widget.initialRoute,
      widget.routes
        ..addAll({AppLock.lockScreenRoute: (context) => _lockScreen}),
    );
  }

  Widget get _lockScreen {
    return WillPopScope(
      child: widget.lockScreen,
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
  void didUnlock([Object? args]) {
    if (_didUnlockForAppLaunch) {
      _didUnlockOnAppPaused();
    } else {
      _didUnlockOnAppLaunch(args);
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
      enable();
    } else {
      disable();
    }
  }

  /// Makes sure that [AppLock] shows the [lockScreen] on subsequent app pauses.
  void enable() {
    setState(() {
      _enabled = true;
    });
  }

  /// Makes sure that [AppLock] doesn't show the [lockScreen] on subsequent app pauses.
  void disable() {
    setState(() {
      _enabled = false;
    });
  }

  /// Manually show the [lockScreen].
  Future<void> showLockScreen() {
    _isLocked = true;
    return _navigatorKey.currentState!.pushNamed(AppLock.lockScreenRoute);
  }

  void _didUnlockOnAppLaunch(Object? args) {
    _didUnlockForAppLaunch = true;
    _navigatorKey.currentState!
        .pushReplacementNamed(widget.initialRoute, arguments: args);
  }

  void _didUnlockOnAppPaused() {
    _isLocked = false;
    _navigatorKey.currentState!.pop();
  }
}

typedef LockedAppBuilder = Widget Function(
  GlobalKey<NavigatorState> navigatorKey,
  String initialRoute,
  Map<String, Widget Function(BuildContext)> routes,
);
