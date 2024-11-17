import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app_lock/src/no_animation_page.dart';

/// A widget which handles app lifecycle events for showing and hiding a lock screen.
/// This should wrap around a `MyApp` widget (or equivalent).
///
/// [lockScreen] (or preferably the [Widget] returned from [lockScreenBuilder]) is a [Widget] which should be a screen for handling login logic and
/// calling `AppLock.of(context).didUnlock();` upon a successful login.
///
/// [builder] is a [Function] taking an [Object] as its argument and should return a
/// [Widget]. The [Object] argument is provided by the [lockScreen] (or preferably the [Widget] returned from [lockScreenBuilder]) calling
/// `AppLock.of(context).didUnlock();` with an argument. [Object] can then be injected
/// in to your `MyApp` widget (or equivalent).
///
/// [enabled] determines wether or not the [lockScreen] (or preferably the [Widget] returned from [lockScreenBuilder]) should be shown on app launch
/// and subsequent app pauses. This can be changed later on using `AppLock.of(context).enable();`,
/// `AppLock.of(context).disable();` or the convenience method `AppLock.of(context).setEnabled(enabled);`
/// using a bool argument.
///
/// [backgroundLockLatency] determines how much time is allowed to pass when
/// the app is in the background state before the [lockScreen] (or preferably the [Widget] returned from [lockScreenBuilder]) widget should be
/// shown upon returning. It defaults to instantly.
class AppLock extends StatefulWidget {
  final Widget Function(BuildContext context, Object? launchArg) builder;
  final Widget? lockScreen;
  final WidgetBuilder? lockScreenBuilder;
  final WidgetBuilder? inactiveBuilder;
  final bool _initiallyEnabled;
  final Duration _initialBackgroundLockLatency;

  const AppLock({
    super.key,
    required this.builder,
    @Deprecated(
        'Use `lockScreenBuilder` instead. `lockScreen` will be removed in version 5.0.0.')
    this.lockScreen,
    this.lockScreenBuilder,
    this.inactiveBuilder,
    @Deprecated(
        'Use `initiallyEnabled` instead. `enabled` will be removed in version 5.0.0.')
    bool? enabled,
    bool? initiallyEnabled,
    @Deprecated(
        'Use `initialBackgroundLockLatency` instead. `backgroundLockLatency` will be removed in version 5.0.0.')
    Duration? backgroundLockLatency,
    Duration? initialBackgroundLockLatency,
  })  : _initiallyEnabled = initiallyEnabled ?? enabled ?? true,
        _initialBackgroundLockLatency = initialBackgroundLockLatency ??
            backgroundLockLatency ??
            Duration.zero,
        assert(
            (lockScreen == null && lockScreenBuilder != null) ||
                (lockScreen != null && lockScreenBuilder == null),
            'Only 1 of either `lockScreenBuilder` or `lockScreen` should be set.'),
        assert(
            (enabled == null && initiallyEnabled != null) ||
                (enabled != null && initiallyEnabled == null),
            'Only 1 of either `initiallyEnabled` or `enabled` should be set.'),
        assert(
            (backgroundLockLatency == null &&
                    initialBackgroundLockLatency != null) ||
                (backgroundLockLatency != null &&
                    initialBackgroundLockLatency == null),
            'Only 1 of either `initialBackgroundLockLatency` or `backgroundLockLatency` should be set.');

  static AppLockState? of(BuildContext context) =>
      context.findAncestorStateOfType<AppLockState>();

  @override
  AppLockState createState() => AppLockState();
}

class AppLockState extends State<AppLock> with WidgetsBindingObserver {
  late bool _didUnlockForAppLaunch;
  late bool _locked;
  late bool _enabled;
  late bool _inactive;

  Timer? _backgroundLockLatencyTimer;

  Object? _launchArg;

  Completer? _didUnlockCompleter;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _didUnlockForAppLaunch = !widget._initiallyEnabled;
    _locked = widget._initiallyEnabled;
    _enabled = widget._initiallyEnabled;
    _inactive = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (!_enabled) {
      return;
    }

    if (state == AppLifecycleState.hidden && !_locked) {
      _backgroundLockLatencyTimer?.cancel();
      _backgroundLockLatencyTimer =
          Timer(widget._initialBackgroundLockLatency, () => showLockScreen());
    }

    if (state == AppLifecycleState.resumed) {
      _backgroundLockLatencyTimer?.cancel();
    }

    setState(() {
      _inactive = state == AppLifecycleState.inactive;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _backgroundLockLatencyTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onPopPage: (route, result) => route.didPop(result),
      pages: [
        if (_didUnlockForAppLaunch)
          MaterialPage(
            key: const ValueKey('App'),
            child: widget.builder(context, _launchArg),
          ),
        if (_locked)
          MaterialPage(
            key: const ValueKey('LockScreen'),
            child: _lockScreen,
          )
        else if (_inactive && widget.inactiveBuilder != null)
          NoAnimationPage(
            key: const ValueKey('InactiveScreen'),
            child: widget.inactiveBuilder!(context),
          ),
      ],
    );
  }

  Widget get _lockScreen {
    return PopScope(
      canPop: false,
      child: (widget.lockScreenBuilder?.call(context) ?? widget.lockScreen)!,
    );
  }

  /// Causes `AppLock` to either pop the [lockScreen] (or preferably the [Widget] returned from [lockScreenBuilder]) if the app is already running
  /// or instantiates widget returned from the [builder] method if the app is cold
  /// launched.
  ///
  /// [launchArg] is an optional argument which will get passed to the [builder] method
  /// when built. Use this when you want to inject objects created from the
  /// [lockScreen] (or preferably the [Widget] returned from [lockScreenBuilder]) in to the rest of your app so you can better guarantee that some
  /// objects, services or databases are already instantiated before using them.
  void didUnlock([Object? launchArg]) {
    if (_didUnlockForAppLaunch) {
      _didUnlockOnAppPaused();
    } else {
      _didUnlockOnAppLaunch(launchArg);
    }

    _didUnlockCompleter?.complete();
  }

  /// Makes sure that [AppLock] shows the [lockScreen] (or preferably the [Widget] returned from [lockScreenBuilder]) on subsequent app pauses if
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

  /// Makes sure that [AppLock] shows the [lockScreen] (or preferably the [Widget] returned from [lockScreenBuilder]) on subsequent app pauses.
  void enable() {
    setState(() {
      _enabled = true;
    });
  }

  /// Makes sure that [AppLock] doesn't show the [lockScreen] (or preferably the [Widget] returned from [lockScreenBuilder]) on subsequent app pauses.
  void disable() {
    setState(() {
      _enabled = false;
    });
  }

  /// Manually show the [lockScreen] (or preferably the [Widget] returned from [lockScreenBuilder]).
  Future<void> showLockScreen() async {
    if (_locked && _didUnlockCompleter != null) {
      return _didUnlockCompleter!.future;
    }

    _didUnlockCompleter = Completer();

    setState(() {
      _locked = true;
    });

    return _didUnlockCompleter!.future;
  }

  /// An argument that is passed to [didUnlock] for the first time after showing
  /// [lockScreen] (or preferably the [Widget] returned from [lockScreenBuilder]) on launch.
  Object? get launchArg => _launchArg;

  void _didUnlockOnAppLaunch(Object? launchArg) {
    setState(() {
      _launchArg = launchArg;
      _didUnlockForAppLaunch = true;
      _locked = false;
    });
  }

  void _didUnlockOnAppPaused() {
    setState(() {
      _locked = false;
    });
  }
}
