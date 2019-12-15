import 'package:flutter/material.dart';

class AppLock extends StatefulWidget {
  final Widget Function(Object) child;
  final Widget lockScreen;

  const AppLock({
    Key key,
    @required this.child,
    @required this.lockScreen,
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

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    this._didUnlockForAppLaunch = false;
    this._isPaused = false;

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
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
      home: this._lockScreen,
      navigatorKey: _navigatorKey,
      routes: {
        '/lock-screen': (context) => this._lockScreen,
        '/unlocked': (context) =>
            this.widget.child(ModalRoute.of(context).settings.arguments)
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
