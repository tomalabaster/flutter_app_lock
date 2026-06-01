import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:flutter_test/flutter_test.dart';

OverlayEntry appOverlayEntry(WidgetTester widgetTester) =>
    widgetTester.state<AppLockState>(find.byType(AppLock)).appOverlayEntry;

OverlayEntry lockScreenOverlayEntry(WidgetTester widgetTester) =>
    widgetTester
        .state<AppLockState>(find.byType(AppLock))
        .lockScreenOverlayEntry;

OverlayEntry? inactiveOverlayEntry(WidgetTester widgetTester) =>
    widgetTester
        .state<AppLockState>(find.byType(AppLock))
        .inactiveOverlayEntry;

void enableAppLockAfterLaunch(WidgetTester widgetTester) {
  widgetTester.state<AppLockState>(find.byType(AppLock)).enable();
}

Widget appLockHarness({
  required bool initiallyEnabled,
  Duration initialBackgroundLockLatency = Duration.zero,
  InactiveBehavior inactiveBehavior = InactiveBehavior.showWhenEnabled,
  WidgetBuilder? inactiveBuilder,
  required Widget home,
}) {
  return MaterialApp(
    builder: (context, child) => AppLock(
      initiallyEnabled: initiallyEnabled,
      initialBackgroundLockLatency: initialBackgroundLockLatency,
      inactiveBehavior: inactiveBehavior,
      builder: (context, launchArg) => child!,
      lockScreenBuilder: (context) => const Scaffold(
        key: Key('LockScreen'),
      ),
      inactiveBuilder: inactiveBuilder,
    ),
    home: home,
  );
}

void main() {
  group('Overlay-based AppLock', () {
    testWidgets('shows the lock overlay on launch when initially enabled',
        (widgetTester) async {
      await widgetTester.pumpWidget(
        appLockHarness(
          initiallyEnabled: true,
          home: const Scaffold(key: Key('Home')),
        ),
      );
      await widgetTester.pumpAndSettle();

      expect(lockScreenOverlayEntry(widgetTester).mounted, isTrue);
      expect(appOverlayEntry(widgetTester).mounted, isFalse);
      expect(find.byKey(const Key('LockScreen')), findsOneWidget);
    });

    testWidgets('shows the app overlay after unlock on launch',
        (widgetTester) async {
      await widgetTester.pumpWidget(
        appLockHarness(
          initiallyEnabled: true,
          home: const Scaffold(key: Key('Home')),
        ),
      );
      await widgetTester.pumpAndSettle();

      widgetTester.state<AppLockState>(find.byType(AppLock)).didUnlock();
      await widgetTester.pumpAndSettle();

      expect(appOverlayEntry(widgetTester).mounted, isTrue);
      expect(lockScreenOverlayEntry(widgetTester).mounted, isFalse);
      expect(find.byKey(const Key('Home')), findsOneWidget);
    });

    testWidgets('defers background lock until the app resumes',
        (widgetTester) async {
      await widgetTester.pumpWidget(
        appLockHarness(
          initiallyEnabled: false,
          initialBackgroundLockLatency: const Duration(seconds: 1),
          home: const Scaffold(key: Key('Home')),
        ),
      );
      await widgetTester.pumpAndSettle();

      enableAppLockAfterLaunch(widgetTester);

      widgetTester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      await widgetTester.pump(const Duration(seconds: 2));

      expect(lockScreenOverlayEntry(widgetTester).mounted, isFalse);

      widgetTester.binding
          .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await widgetTester.pumpAndSettle();

      expect(lockScreenOverlayEntry(widgetTester).mounted, isTrue);
      expect(find.byKey(const Key('LockScreen')), findsOneWidget);
    });

    testWidgets('shows inactive overlay when disabled and alwaysShow',
        (widgetTester) async {
      await widgetTester.pumpWidget(
        appLockHarness(
          initiallyEnabled: false,
          inactiveBehavior: InactiveBehavior.alwaysShow,
          inactiveBuilder: (context) => const Scaffold(
            key: Key('InactiveScreen'),
          ),
          home: const Scaffold(key: Key('Home')),
        ),
      );
      await widgetTester.pumpAndSettle();

      widgetTester.binding
          .handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await widgetTester.pumpAndSettle();

      expect(inactiveOverlayEntry(widgetTester)?.mounted, isTrue);
      expect(find.byKey(const Key('InactiveScreen')), findsOneWidget);
      expect(find.byKey(const Key('Home')), findsNothing);
    });
  });

  group('AppLock navigation regressions', () {
    testWidgets('hero navigation works through AppLock', (widgetTester) async {
      await widgetTester.pumpWidget(
        appLockHarness(
          initiallyEnabled: false,
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Hero(
                    tag: 'hero-tag',
                    child: Material(
                      child: Text('Hero source'),
                    ),
                  ),
                  Builder(
                    builder: (context) => ElevatedButton(
                      key: const Key('PushHeroRoute'),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => const Scaffold(
                            key: Key('DetailScreen'),
                            body: Hero(
                              tag: 'hero-tag',
                              child: Material(
                                child: Text('Hero destination'),
                              ),
                            ),
                          ),
                        ),
                      ),
                      child: const Text('Open detail'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await widgetTester.pumpAndSettle();

      await widgetTester.tap(find.byKey(const Key('PushHeroRoute')));
      await widgetTester.pumpAndSettle();

      expect(find.byKey(const Key('DetailScreen')), findsOneWidget);
      expect(find.byType(Hero), findsOneWidget);
    });

    testWidgets('android back pops the route after a dialog is dismissed',
        (widgetTester) async {
      await widgetTester.pumpWidget(
        appLockHarness(
          initiallyEnabled: false,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  key: const Key('OpenSecondScreen'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => Scaffold(
                        key: const Key('SecondScreen'),
                        body: Center(
                          child: ElevatedButton(
                            key: const Key('ShowDialog'),
                            onPressed: () async {
                              await showDialog<void>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  content: const Text('Dialog content'),
                                  actions: [
                                    TextButton(
                                      key: const Key('CloseDialog'),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text('Show dialog'),
                          ),
                        ),
                      ),
                    ),
                  ),
                  child: const Text('Open second screen'),
                ),
              ),
            ),
          ),
        ),
      );
      await widgetTester.pumpAndSettle();

      await widgetTester.tap(find.byKey(const Key('OpenSecondScreen')));
      await widgetTester.pumpAndSettle();

      await widgetTester.tap(find.byKey(const Key('ShowDialog')));
      await widgetTester.pumpAndSettle();

      await widgetTester.tap(find.byKey(const Key('CloseDialog')));
      await widgetTester.pumpAndSettle();

      expect(find.byKey(const Key('SecondScreen')), findsOneWidget);

      final didPop = await widgetTester.binding.handlePopRoute();
      await widgetTester.pumpAndSettle();

      expect(didPop, isTrue);
      expect(find.byKey(const Key('SecondScreen')), findsNothing);
      expect(find.byKey(const Key('OpenSecondScreen')), findsOneWidget);
    });
  });
}
