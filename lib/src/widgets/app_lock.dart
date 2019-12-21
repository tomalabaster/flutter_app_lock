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
class AppLock extends StatefulWidget {
  final Widget Function(Object) builder;
  final Widget lockScreen;
  final bool enabled;

  const AppLock({
    Key key,
    @required this.builder,
    @required this.lockScreen,
    this.enabled = true,
  }) : super(key: key);

  static _AppLockState of(BuildContext context) =>
      context.findAncestorStateOfType<_AppLockState>();

  @override
  _AppLockState createState() => _AppLockState();
}

class _AppLockState extends State<AppLock> with WidgetsBindingObserver {
  static final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();

  bool _didUnlockForAppLaunch;
  bool _isPaused;
  bool _enabled;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    this._didUnlockForAppLaunch = !this.widget.enabled;
    this._isPaused = false;
    this._enabled = this.widget.enabled;

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!this._enabled) {
      return;
    }

    if (state == AppLifecycleState.paused &&
        (!this._isPaused && this._didUnlockForAppLaunch)) {
      this._showLockScreen();
    }

    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: this.widget.enabled ? this._lockScreen : this.widget.builder(null),
      navigatorKey: _navigatorKey,
      routes: {
        '/lock-screen': (context) => this._lockScreen,
        '/unlocked': (context) =>
            this.widget.builder(ModalRoute.of(context).settings.arguments)
      },
    );
  }

  Widget get _lockScreen {
    return WillPopScope(
      child: this.widget.lockScreen,
      onWillPop: () => Future.value(false),
    );
  }

  void didUnlock([Object args]) {
    if (this._didUnlockForAppLaunch) {
      this._didUnlockOnAppPaused();
    } else {
      this._didUnlockOnAppLaunch(args);
    }
  }

  void setEnabled(bool enabled) {
    if (enabled) {
      this.enable();
    } else {
      this.disable();
    }
  }

  void enable() {
    setState(() {
      this._enabled = true;
    });
  }

  void disable() {
    setState(() {
      this._enabled = false;
    });
  }

  void _didUnlockOnAppLaunch(Object args) {
    this._didUnlockForAppLaunch = true;
    _navigatorKey.currentState
        .pushReplacementNamed('/unlocked', arguments: args);
  }

  void _didUnlockOnAppPaused() {
    this._isPaused = false;
    _navigatorKey.currentState.pop();
  }

  void _showLockScreen() {
    _navigatorKey.currentState.pushNamed('/lock-screen');
    this._isPaused = true;
  }
}
