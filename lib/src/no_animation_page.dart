import 'package:flutter/material.dart';

class NoAnimationPage<T> extends Page<T> {
  const NoAnimationPage({
    required this.child,
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.allowSnapshotting = true,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;
  final bool maintainState;
  final bool fullscreenDialog;
  final bool allowSnapshotting;

  @override
  Route<T> createRoute(BuildContext context) => _NoAnimationPageRoute<T>(
      page: this, allowSnapshotting: allowSnapshotting);
}

class _NoAnimationPageRoute<T> extends PageRoute<T> {
  _NoAnimationPageRoute({
    required NoAnimationPage<T> page,
    super.allowSnapshotting,
  }) : super(settings: page) {
    assert(opaque);
  }

  NoAnimationPage<T> get _page => settings as NoAnimationPage<T>;

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) =>
      _page.child;

  @override
  Duration get transitionDuration => Duration.zero;
}
