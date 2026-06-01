import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// [InactiveBehavior] controls whether the widget returned by
/// [AppLock.inactiveBuilder] is shown only when [AppLock] is enabled or
/// whether it should always been shown.
///
/// - [InactiveBehavior.alwaysShow] - show the widget returned by
/// [AppLock.inactiveBuilder] if all of the following conditions are true:
///   - The [AppLifecycleState] is [AppLifecycleState.inactive]
///   - [AppLock.inactiveBuilder] is set
///
/// - [InactiveBehavior.showWhenEnabled] - show the widget returned by
/// [AppLock.inactiveBuilder] if all of the following conditions are true:
///   - The [AppLifecycleState] is [AppLifecycleState.inactive]
///   - [AppLock.inactiveBuilder] is set
///   - [AppLock] is enabled
enum InactiveBehavior {
  alwaysShow,
  showWhenEnabled,
}

/// [AppLock] is a widget that handles app lifecycle events for showing and
/// hiding a lock screen, protecting visual access to your app.
///
/// [builder] returns a [Widget] representing the rest of your app - most
/// likely the `child` parameter of the [MaterialApp.builder],
/// [CupertinoApp.builder] or [WidgetsApp.builder] functions.
///
/// The `launchArg` parameter in [builder] is provided by the [Widget] returned
/// from [lockScreenBuilder] calling `AppLock.of(context)!.didUnlock();` with
/// an argument. `launchArg` can then be used as you see fit.
///
/// [lockScreenBuilder] returns the [Widget] to be shown to users while the app
/// is considered "locked". It should be a screen for handling the verification
/// logic your app needs to consider the app "unlocked", and calls
/// `AppLock.of(context)!.didUnlock();` upon a successful verification.
///
/// [inactiveBuilder] returns the [Widget] to be shown to the user while the
/// app's [AppLifecycleState] is [AppLifecycleState.inactive].
///
/// [inactiveBehavior] controls whether the widget returned by
/// [AppLock.inactiveBuilder] is shown only when [AppLock] is enabled or
/// whether it should always been shown.
///
/// [initiallyEnabled] determines wether or not the the [Widget] returned from
/// [lockScreenBuilder] should be shown on app launch and subsequent app
/// pauses. This can be changed later on using
/// `AppLock.of(context)!.enable();`, `AppLock.of(context)!.disable();` or the
/// convenience method `AppLock.of(context).setEnabled(enabled);` using a
/// [bool] argument.
///
/// [initialBackgroundLockLatency] determines how much time is allowed to pass
/// when the app is in the background state before the [Widget] returned from
/// [lockScreenBuilder] widget should be shown upon returning. It defaults to
/// instantly. This can be changed later on using
/// `AppLock.of(context)!.setBackgroundLockLatency(duration);` using a
/// [Duration] argument.
class AppLock extends StatefulWidget {
  final Widget Function(BuildContext context, Object? launchArg) builder;
  final WidgetBuilder lockScreenBuilder;
  final WidgetBuilder? inactiveBuilder;
  final InactiveBehavior inactiveBehavior;
  final bool initiallyEnabled;
  final Duration initialBackgroundLockLatency;

  const AppLock({
    super.key,
    required this.builder,
    required this.lockScreenBuilder,
    this.inactiveBuilder,
    this.inactiveBehavior = InactiveBehavior.showWhenEnabled,
    this.initiallyEnabled = true,
    this.initialBackgroundLockLatency = Duration.zero,
  });

  static AppLockState? of(BuildContext context) =>
      context.findAncestorStateOfType<AppLockState>();

  @override
  AppLockState createState() => AppLockState();
}

class AppLockState extends State<AppLock> with WidgetsBindingObserver {
  final GlobalKey<OverlayState> _overlayKey = GlobalKey();

  late final OverlayEntry _appOverlayEntry;
  late final OverlayEntry _lockScreenOverlayEntry;
  OverlayEntry? _inactiveOverlayEntry;

  late bool _didUnlockForAppLaunch;
  late bool _locked;
  late bool _enabled;
  late bool _inactive;

  late Duration _backgroundLockLatency;

  Timer? _backgroundLockLatencyTimer;
  bool _pendingBackgroundLock = false;
  bool _overlaySyncScheduled = false;
  bool _isFirstBuild = true;

  Object? _launchArg;

  Completer<void>? _didUnlockCompleter;

  @visibleForTesting
  OverlayEntry get appOverlayEntry => _appOverlayEntry;

  @visibleForTesting
  OverlayEntry get lockScreenOverlayEntry => _lockScreenOverlayEntry;

  @visibleForTesting
  OverlayEntry? get inactiveOverlayEntry => _inactiveOverlayEntry;

  bool get _shouldShowInactive =>
      _inactive &&
      widget.inactiveBuilder != null &&
      (widget.inactiveBehavior == InactiveBehavior.alwaysShow ||
          (widget.inactiveBehavior == InactiveBehavior.showWhenEnabled &&
              _enabled));

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _appOverlayEntry = OverlayEntry(
      maintainState: true,
      builder: (context) => Offstage(
        offstage: _locked || _shouldShowInactive,
        child: widget.builder(context, _launchArg),
      ),
    );

    _lockScreenOverlayEntry = OverlayEntry(
      builder: (context) => _lockScreen,
    );

    if (widget.inactiveBuilder != null) {
      _inactiveOverlayEntry = OverlayEntry(
        builder: (context) => widget.inactiveBuilder!(context),
      );
    }

    _didUnlockForAppLaunch = !widget.initiallyEnabled;
    _locked = widget.initiallyEnabled;
    _enabled = widget.initiallyEnabled;
    _inactive = false;

    _backgroundLockLatency = widget.initialBackgroundLockLatency;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    setState(() {
      _inactive = state == AppLifecycleState.inactive;
    });

    if (state == AppLifecycleState.resumed) {
      _backgroundLockLatencyTimer?.cancel();

      if (_pendingBackgroundLock && _enabled && !_locked) {
        _pendingBackgroundLock = false;
        unawaited(showLockScreen());
      }
    }

    if (!_enabled) {
      _scheduleSyncOverlays();
      return;
    }

    if (state == AppLifecycleState.hidden && !_locked) {
      _backgroundLockLatencyTimer?.cancel();
      _backgroundLockLatencyTimer = Timer(
        _backgroundLockLatency,
        _onBackgroundLockTimerFired,
      );
    }

    _scheduleSyncOverlays();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _backgroundLockLatencyTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isFirstBuild) {
      _isFirstBuild = false;

      return Overlay(
        key: _overlayKey,
        initialEntries: _overlayEntriesForCurrentState(),
      );
    }

    _scheduleSyncOverlays();

    return Overlay(
      key: _overlayKey,
      initialEntries: const [],
    );
  }

  List<OverlayEntry> _overlayEntriesForCurrentState() {
    final entries = <OverlayEntry>[];

    if (_didUnlockForAppLaunch) {
      entries.add(_appOverlayEntry);
    }

    if (_locked) {
      entries.add(_lockScreenOverlayEntry);
    } else if (_shouldShowInactive && _inactiveOverlayEntry != null) {
      entries.add(_inactiveOverlayEntry!);
    }

    return entries;
  }

  Widget get _lockScreen {
    return PopScope(
      canPop: false,
      child: widget.lockScreenBuilder(context),
    );
  }

  /// Causes `AppLock` to either hide the [Widget] returned from
  /// [AppLock.lockScreenBuilder] if the app is already running or instantiates
  /// widget returned from the [AppLock.builder] method if the app is cold
  /// launched.
  ///
  /// [launchArg] is an optional argument which will get passed to the
  /// [AppLock.builder] method when built. Use this when you want to inject
  /// objects created from the [Widget] returned from [AppLock.lockScreenBuilder]
  /// in to the rest of your app so you can better guarantee that some objects,
  /// services or databases are already instantiated before using them.
  void didUnlock([Object? launchArg]) {
    if (_didUnlockForAppLaunch) {
      _didUnlockOnAppPaused();
    } else {
      _didUnlockOnAppLaunch(launchArg);
    }

    _didUnlockCompleter?.complete();
    _scheduleSyncOverlays();
  }

  /// Makes sure that [AppLock] shows the [Widget] returned from
  /// [AppLock.lockScreenBuilder] on subsequent app pauses if [enabled] is true
  /// of makes sure it isn't shown on subsequent app pauses if [enabled] is
  /// false.
  ///
  /// This is a convenience method for calling the [enable] or [disable] method
  /// based on [enabled].
  void setEnabled(bool enabled) {
    if (enabled) {
      enable();
    } else {
      disable();
    }
  }

  /// Makes sure that [AppLock] shows the [Widget] returned from
  /// [lockScreenBuilder] on subsequent app pauses.
  void enable() {
    setState(() {
      _enabled = true;
    });

    _scheduleSyncOverlays();
  }

  /// Makes sure that [AppLock] doesn't show the [Widget] returned from
  /// [AppLock.lockScreenBuilder] on subsequent app pauses.
  void disable() {
    setState(() {
      _enabled = false;
    });

    _scheduleSyncOverlays();
  }

  /// Manually show the [Widget] returned from [AppLock.lockScreenBuilder].
  Future<void> showLockScreen() async {
    if (_locked && _didUnlockCompleter != null) {
      return _didUnlockCompleter!.future;
    }

    _didUnlockCompleter = Completer<void>();

    setState(() {
      _locked = true;
      _pendingBackgroundLock = false;
    });

    _scheduleSyncOverlays();

    return _didUnlockCompleter!.future;
  }

  /// Change the background lock latency after `AppLock` has been created.
  void setBackgroundLockLatency(Duration backgroundLockLatency) =>
      _backgroundLockLatency = backgroundLockLatency;

  /// An argument that is passed to [didUnlock] for the first time after showing
  /// the [Widget] returned from [AppLock.lockScreenBuilder] on launch.
  Object? get launchArg => _launchArg;

  void _onBackgroundLockTimerFired() {
    if (!mounted || _locked || !_enabled) {
      return;
    }

    if (SchedulerBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      unawaited(showLockScreen());
      return;
    }

    _pendingBackgroundLock = true;
  }

  void _scheduleSyncOverlays() {
    if (_overlaySyncScheduled) {
      return;
    }

    _overlaySyncScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _overlaySyncScheduled = false;

      if (!mounted) {
        return;
      }

      _syncOverlays();
    });
  }

  void _syncOverlays() {
    final overlay = _overlayKey.currentState;
    if (overlay == null) {
      return;
    }

    if (_didUnlockForAppLaunch) {
      if (!_appOverlayEntry.mounted) {
        overlay.insert(_appOverlayEntry);
      } else {
        _appOverlayEntry.markNeedsBuild();
      }
    } else if (_appOverlayEntry.mounted) {
      _appOverlayEntry.remove();
    }

    if (_locked) {
      if (!_lockScreenOverlayEntry.mounted) {
        overlay.insert(_lockScreenOverlayEntry);
      }

      if (_inactiveOverlayEntry?.mounted ?? false) {
        _inactiveOverlayEntry!.remove();
      }

      if (_appOverlayEntry.mounted) {
        _appOverlayEntry.markNeedsBuild();
      }
      return;
    }

    if (_lockScreenOverlayEntry.mounted) {
      _lockScreenOverlayEntry.remove();
    }

    final inactiveOverlayEntry = _inactiveOverlayEntry;
    if (_shouldShowInactive && inactiveOverlayEntry != null) {
      if (!inactiveOverlayEntry.mounted) {
        overlay.insert(inactiveOverlayEntry);
      }
    } else if (inactiveOverlayEntry?.mounted ?? false) {
      inactiveOverlayEntry!.remove();
    }

    if (_appOverlayEntry.mounted) {
      _appOverlayEntry.markNeedsBuild();
    }
  }

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
