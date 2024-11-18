import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> setAppLifecycleToHidden(WidgetTester widgetTester) async {
  widgetTester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);

  await widgetTester.pumpAndSettle();
}

Future<void> setAppLifecycleToInactive(WidgetTester widgetTester) async {
  widgetTester.binding
      .handleAppLifecycleStateChanged(AppLifecycleState.inactive);

  await widgetTester.pumpAndSettle();
}

Future<void> setAppLifecycleToResumed(WidgetTester widgetTester) async {
  widgetTester.binding
      .handleAppLifecycleStateChanged(AppLifecycleState.resumed);

  await widgetTester.pumpAndSettle();
}

void enableAppLockAfterLaunch(WidgetTester widgetTester) {
  widgetTester.state<AppLockState>(find.byType(AppLock)).enable();
}

OverlayState appLockOverlayState(WidgetTester widgetTester) =>
    widgetTester.firstState(find.byType(Overlay));

OverlayEntry appOverlayEntry(WidgetTester widgetTester) =>
    (widgetTester.state(find.byType(AppLock)) as AppLockState).appOverlayEntry;

OverlayEntry lockScreenOverlayEntry(WidgetTester widgetTester) =>
    (widgetTester.state(find.byType(AppLock)) as AppLockState)
        .lockScreenOverlayEntry;

OverlayEntry inactiveOverlayEntry(WidgetTester widgetTester) =>
    (widgetTester.state(find.byType(AppLock)) as AppLockState)
        .inactiveOverlayEntry;

void main() {
  group('Given an AppLock widget', () {
    group('When it is enabled', () {
      late Widget sut;

      setUp(() {
        sut = MaterialApp(
          builder: (context, child) => AppLock(
            initialBackgroundLockLatency: const Duration(seconds: 1),
            initiallyEnabled: true,
            builder: (context, launchArg) => KeyedSubtree(
              key: const Key('Unlocked'),
              child: child!,
            ),
            lockScreenBuilder: (context) => const Scaffold(
              key: Key('LockScreen'),
            ),
            inactiveBuilder: (context) => const Scaffold(
              key: Key('InactiveScreen'),
            ),
          ),
          home: const Scaffold(),
        );
      });

      testWidgets('The lock screen should be shown', (widgetTester) async {
        await widgetTester.pumpWidget(sut);

        await widgetTester.pumpAndSettle();

        expect(
          lockScreenOverlayEntry(widgetTester).mounted,
          true,
        );
      });

      testWidgets('The unlocked app should not be shown', (widgetTester) async {
        await widgetTester.pumpWidget(sut);

        expect(
          appOverlayEntry(widgetTester).mounted,
          false,
        );
      });

      testWidgets('The inactive screen should not be shown',
          (widgetTester) async {
        await widgetTester.pumpWidget(sut);

        expect(
          inactiveOverlayEntry(widgetTester).mounted,
          false,
        );
      });
    });

    group(
        'When it is enabled and the app becomes inactive without an inactive builder set',
        () {
      late Widget sut;

      setUp(() {
        sut = MaterialApp(
          builder: (context, child) => AppLock(
            initialBackgroundLockLatency: const Duration(seconds: 1),
            initiallyEnabled: true,
            builder: (context, launchArg) => KeyedSubtree(
              key: const Key('Unlocked'),
              child: child!,
            ),
            lockScreenBuilder: (context) => const Scaffold(
              key: Key('LockScreen'),
            ),
          ),
          home: const Scaffold(),
        );
      });

      testWidgets('The lock screen should be shown', (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        await setAppLifecycleToInactive(widgetTester);

        expect(
          lockScreenOverlayEntry(widgetTester).mounted,
          true,
        );
      });

      testWidgets('The unlocked app should not be shown', (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        await setAppLifecycleToInactive(widgetTester);

        expect(
          appOverlayEntry(widgetTester).mounted,
          false,
        );
      });

      testWidgets('The inactive screen should not be shown',
          (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        await setAppLifecycleToInactive(widgetTester);

        expect(
          inactiveOverlayEntry(widgetTester).mounted,
          false,
        );
      });
    });

    group(
        'When it is enabled and the app becomes inactive with an inactive builder set',
        () {
      late Widget sut;

      setUp(() {
        sut = MaterialApp(
          builder: (context, child) => AppLock(
            initialBackgroundLockLatency: const Duration(seconds: 1),
            initiallyEnabled: true,
            builder: (context, launchArg) => KeyedSubtree(
              key: const Key('Unlocked'),
              child: child!,
            ),
            lockScreenBuilder: (context) => const Scaffold(
              key: Key('LockScreen'),
            ),
            inactiveBuilder: (context) => const Scaffold(
              key: Key('InactiveScreen'),
            ),
          ),
          home: const Scaffold(),
        );
      });

      testWidgets('The lock screen should be shown', (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        await setAppLifecycleToInactive(widgetTester);

        expect(
          lockScreenOverlayEntry(widgetTester).mounted,
          true,
        );
      });

      testWidgets('The unlocked app should not be shown', (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        await setAppLifecycleToInactive(widgetTester);

        expect(
          appOverlayEntry(widgetTester).mounted,
          false,
        );
      });

      testWidgets('The inactive screen should not be shown',
          (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        await setAppLifecycleToInactive(widgetTester);

        expect(
          inactiveOverlayEntry(widgetTester).mounted,
          false,
        );
      });
    });

    group('When it is enabled and the app transitions from inactive to resumed',
        () {
      late Widget sut;

      setUp(() {
        sut = MaterialApp(
          builder: (context, child) => AppLock(
            initialBackgroundLockLatency: const Duration(seconds: 1),
            initiallyEnabled: true,
            builder: (context, launchArg) => KeyedSubtree(
              key: const Key('Unlocked'),
              child: child!,
            ),
            lockScreenBuilder: (context) => const Scaffold(
              key: Key('LockScreen'),
            ),
            inactiveBuilder: (context) => const Scaffold(
              key: Key('InactiveScreen'),
            ),
          ),
          home: const Scaffold(),
        );
      });

      testWidgets('The lock screen should be shown', (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToResumed(widgetTester);

        expect(
          lockScreenOverlayEntry(widgetTester).mounted,
          true,
        );
      });

      testWidgets('The unlocked app should not be shown', (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToResumed(widgetTester);

        expect(
          appOverlayEntry(widgetTester).mounted,
          false,
        );
      });

      testWidgets('The inactive screen should not be shown',
          (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToResumed(widgetTester);

        expect(
          inactiveOverlayEntry(widgetTester).mounted,
          false,
        );
      });
    });

    group(
        'When it is enabled and the app transitions from inactive to hidden for longer than the lock duration and back to inactive and resumed',
        () {
      late Widget sut;

      setUp(() {
        sut = MaterialApp(
          builder: (context, child) => AppLock(
            initialBackgroundLockLatency: const Duration(seconds: 1),
            initiallyEnabled: true,
            builder: (context, launchArg) => KeyedSubtree(
              key: const Key('Unlocked'),
              child: child!,
            ),
            lockScreenBuilder: (context) => const Scaffold(
              key: Key('LockScreen'),
            ),
            inactiveBuilder: (context) => const Scaffold(
              key: Key('InactiveScreen'),
            ),
          ),
          home: const Scaffold(),
        );
      });

      testWidgets('The lock screen should be shown', (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToHidden(widgetTester);

        await widgetTester.pumpAndSettle(const Duration(seconds: 2));

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToResumed(widgetTester);

        expect(
          lockScreenOverlayEntry(widgetTester).mounted,
          true,
        );
      });

      testWidgets('The unlocked app should not be shown', (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToHidden(widgetTester);

        await widgetTester.pumpAndSettle(const Duration(seconds: 2));

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToResumed(widgetTester);

        expect(
          appOverlayEntry(widgetTester).mounted,
          false,
        );
      });

      testWidgets('The inactive screen should not be shown',
          (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToHidden(widgetTester);

        await widgetTester.pumpAndSettle(const Duration(seconds: 2));

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToResumed(widgetTester);

        expect(
          inactiveOverlayEntry(widgetTester).mounted,
          false,
        );
      });
    });

    group(
        'When it is enabled and the app transitions from inactive to hidden for less than the lock duration and back to inactive and resumed',
        () {
      late Widget sut;

      setUp(() {
        sut = MaterialApp(
          builder: (context, child) => AppLock(
            initialBackgroundLockLatency: const Duration(seconds: 2),
            initiallyEnabled: true,
            builder: (context, launchArg) => KeyedSubtree(
              key: const Key('Unlocked'),
              child: child!,
            ),
            lockScreenBuilder: (context) => const Scaffold(
              key: Key('LockScreen'),
            ),
            inactiveBuilder: (context) => const Scaffold(
              key: Key('InactiveScreen'),
            ),
          ),
          home: const Scaffold(),
        );
      });

      testWidgets('The lock screen should be shown', (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToHidden(widgetTester);

        await widgetTester.pumpAndSettle(const Duration(seconds: 1));

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToResumed(widgetTester);

        expect(
          lockScreenOverlayEntry(widgetTester).mounted,
          true,
        );
      });

      testWidgets('The unlocked app should not be shown', (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToHidden(widgetTester);

        await widgetTester.pumpAndSettle(const Duration(seconds: 1));

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToResumed(widgetTester);

        expect(
          appOverlayEntry(widgetTester).mounted,
          false,
        );
      });

      testWidgets('The inactive screen should not be shown',
          (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToHidden(widgetTester);

        await widgetTester.pumpAndSettle(const Duration(seconds: 1));

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToResumed(widgetTester);

        expect(
          inactiveOverlayEntry(widgetTester).mounted,
          false,
        );
      });
    });

    group(
        'When it is disabled and then enabled at runtime and the background lock latency is changed at runtime and the app transitions from inactive to hidden for longer than the new lock duration and back to inactive and resumed',
        () {
      late Widget sut;

      final GlobalKey<AppLockState> appLockKey = GlobalKey();

      setUp(() {
        sut = MaterialApp(
          builder: (context, child) => AppLock(
            key: appLockKey,
            initialBackgroundLockLatency: Duration.zero,
            initiallyEnabled: false,
            builder: (context, launchArg) => KeyedSubtree(
              key: const Key('Unlocked'),
              child: child!,
            ),
            lockScreenBuilder: (context) => const Scaffold(
              key: Key('LockScreen'),
            ),
            inactiveBuilder: (context) => const Scaffold(
              key: Key('InactiveScreen'),
            ),
          ),
          home: const Scaffold(),
        );
      });

      testWidgets(
          'The lock screen should be shown if inactive for longer than the new background lock latency',
          (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        enableAppLockAfterLaunch(widgetTester);

        appLockKey.currentState!
            .setBackgroundLockLatency(const Duration(seconds: 5));

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToHidden(widgetTester);

        await widgetTester.pumpAndSettle(const Duration(seconds: 6));

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToResumed(widgetTester);

        expect(find.byKey(const Key('LockScreen')), findsOneWidget);
      });
    });

    group(
        'When it is disabled and then enabled at runtime and the background lock latency is changed at runtime and the app transitions from inactive to hidden for less than the new lock duration and back to inactive and resumed',
        () {
      late Widget sut;

      final GlobalKey<AppLockState> appLockKey = GlobalKey();

      setUp(() {
        sut = MaterialApp(
          builder: (context, child) => AppLock(
            key: appLockKey,
            initialBackgroundLockLatency: Duration.zero,
            initiallyEnabled: false,
            builder: (context, launchArg) => KeyedSubtree(
              key: const Key('Unlocked'),
              child: child!,
            ),
            lockScreenBuilder: (context) => const Scaffold(
              key: Key('LockScreen'),
            ),
            inactiveBuilder: (context) => const Scaffold(
              key: Key('InactiveScreen'),
            ),
          ),
          home: const Scaffold(),
        );
      });

      testWidgets(
          'The lock screen should not be shown if inactive for less than the new background lock latency',
          (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        enableAppLockAfterLaunch(widgetTester);

        appLockKey.currentState!
            .setBackgroundLockLatency(const Duration(seconds: 5));

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToHidden(widgetTester);

        await widgetTester.pumpAndSettle(const Duration(seconds: 2));

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToResumed(widgetTester);

        expect(find.byKey(const Key('LockScreen')), findsNothing);
      });
    });

    group('When it is disabled', () {
      late Widget sut;

      setUp(() {
        sut = MaterialApp(
          builder: (context, child) => AppLock(
            initialBackgroundLockLatency: const Duration(seconds: 1),
            initiallyEnabled: false,
            builder: (context, launchArg) => KeyedSubtree(
              key: const Key('Unlocked'),
              child: child!,
            ),
            lockScreenBuilder: (context) => const Scaffold(
              key: Key('LockScreen'),
            ),
            inactiveBuilder: (context) => const Scaffold(
              key: Key('InactiveScreen'),
            ),
          ),
          home: const Scaffold(),
        );
      });

      testWidgets('The lock screen should not be shown', (widgetTester) async {
        await widgetTester.pumpWidget(sut);

        expect(
          lockScreenOverlayEntry(widgetTester).mounted,
          false,
        );
      });

      testWidgets('The unlocked app should be shown', (widgetTester) async {
        await widgetTester.pumpWidget(sut);

        expect(
          appOverlayEntry(widgetTester).mounted,
          true,
        );
      });

      testWidgets('The inactive screen should not be shown',
          (widgetTester) async {
        await widgetTester.pumpWidget(sut);

        expect(
          inactiveOverlayEntry(widgetTester).mounted,
          false,
        );
      });
    });

    group(
        'When it is disabled and then enabled at runtime and the app becomes inactive without an inactive builder set',
        () {
      late Widget sut;

      setUp(() {
        sut = MaterialApp(
          builder: (context, child) => AppLock(
            initialBackgroundLockLatency: const Duration(seconds: 1),
            initiallyEnabled: false,
            builder: (context, launchArg) => KeyedSubtree(
              key: const Key('Unlocked'),
              child: child!,
            ),
            lockScreenBuilder: (context) => const Scaffold(
              key: Key('LockScreen'),
            ),
          ),
          home: const Scaffold(),
        );
      });

      testWidgets('The lock screen should not be shown', (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        enableAppLockAfterLaunch(widgetTester);

        await setAppLifecycleToInactive(widgetTester);

        expect(
          lockScreenOverlayEntry(widgetTester).mounted,
          false,
        );
      });

      testWidgets('The unlocked app should be shown', (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        enableAppLockAfterLaunch(widgetTester);

        await setAppLifecycleToInactive(widgetTester);

        expect(
          appOverlayEntry(widgetTester).mounted,
          true,
        );
      });

      testWidgets('The inactive screen should not be shown',
          (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        enableAppLockAfterLaunch(widgetTester);

        await setAppLifecycleToInactive(widgetTester);

        expect(
          inactiveOverlayEntry(widgetTester).mounted,
          false,
        );
      });
    });

    group(
        'When it is disabled and then enabled at runtime and the app becomes inactive with an inactive builder set',
        () {
      late Widget sut;

      setUp(() {
        sut = MaterialApp(
          builder: (context, child) => AppLock(
            initialBackgroundLockLatency: const Duration(seconds: 1),
            initiallyEnabled: false,
            builder: (context, launchArg) => KeyedSubtree(
              key: const Key('Unlocked'),
              child: child!,
            ),
            lockScreenBuilder: (context) => const Scaffold(
              key: Key('LockScreen'),
            ),
            inactiveBuilder: (context) => const Scaffold(
              key: Key('InactiveScreen'),
            ),
          ),
          home: const Scaffold(),
        );
      });

      testWidgets('The lock screen should not be shown', (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        enableAppLockAfterLaunch(widgetTester);

        await setAppLifecycleToInactive(widgetTester);

        expect(
          lockScreenOverlayEntry(widgetTester).mounted,
          false,
        );
      });

      testWidgets('The unlocked app should not be shown', (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        enableAppLockAfterLaunch(widgetTester);

        await setAppLifecycleToInactive(widgetTester);

        expect(
          appOverlayEntry(widgetTester).mounted,
          true, // Ok as this is behind the lock screen overlay
        );

        expect(
          appLockOverlayState(widgetTester)
              .debugIsVisible(appOverlayEntry(widgetTester)),
          false,
        );
      });

      testWidgets('The inactive screen should be shown', (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        enableAppLockAfterLaunch(widgetTester);

        await setAppLifecycleToInactive(widgetTester);

        expect(
          inactiveOverlayEntry(widgetTester).mounted,
          true,
        );
      });
    });

    group(
        'When it is disabled and then enabled at runtime and the app transitions from inactive to resumed',
        () {
      late Widget sut;

      setUp(() {
        sut = MaterialApp(
          builder: (context, child) => AppLock(
            initialBackgroundLockLatency: const Duration(seconds: 1),
            initiallyEnabled: false,
            builder: (context, launchArg) => KeyedSubtree(
              key: const Key('Unlocked'),
              child: child!,
            ),
            lockScreenBuilder: (context) => const Scaffold(
              key: Key('LockScreen'),
            ),
            inactiveBuilder: (context) => const Scaffold(
              key: Key('InactiveScreen'),
            ),
          ),
          home: const Scaffold(),
        );
      });

      testWidgets('The lock screen should not be shown', (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        enableAppLockAfterLaunch(widgetTester);

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToResumed(widgetTester);

        expect(
          lockScreenOverlayEntry(widgetTester).mounted,
          false,
        );
      });

      testWidgets('The unlocked app should be shown', (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        enableAppLockAfterLaunch(widgetTester);

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToResumed(widgetTester);

        expect(
          appOverlayEntry(widgetTester).mounted,
          true,
        );
      });

      testWidgets('The inactive screen should not be shown',
          (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        enableAppLockAfterLaunch(widgetTester);

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToResumed(widgetTester);

        expect(
          inactiveOverlayEntry(widgetTester).mounted,
          false,
        );
      });
    });

    group(
        'When it is disabled and then enabled at runtime and the app transitions from inactive to hidden for longer than the lock duration and back to inactive and resumed',
        () {
      late Widget sut;

      setUp(() {
        sut = MaterialApp(
          builder: (context, child) => AppLock(
            initialBackgroundLockLatency: const Duration(seconds: 1),
            initiallyEnabled: false,
            builder: (context, launchArg) => KeyedSubtree(
              key: const Key('Unlocked'),
              child: child!,
            ),
            lockScreenBuilder: (context) => const Scaffold(
              key: Key('LockScreen'),
            ),
            inactiveBuilder: (context) => const Scaffold(
              key: Key('InactiveScreen'),
            ),
          ),
          home: const Scaffold(),
        );
      });

      testWidgets('The lock screen should be shown', (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        enableAppLockAfterLaunch(widgetTester);

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToHidden(widgetTester);

        await widgetTester.pumpAndSettle(const Duration(seconds: 2));

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToResumed(widgetTester);

        expect(
          lockScreenOverlayEntry(widgetTester).mounted,
          true,
        );
      });

      testWidgets('The unlocked app should not be shown', (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        enableAppLockAfterLaunch(widgetTester);

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToHidden(widgetTester);

        await widgetTester.pumpAndSettle(const Duration(seconds: 2));

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToResumed(widgetTester);

        expect(
          appOverlayEntry(widgetTester).mounted,
          true, // Ok as this is behind the lock screen overlay
        );

        expect(
          appLockOverlayState(widgetTester)
              .debugIsVisible(appOverlayEntry(widgetTester)),
          false,
        );
      });

      testWidgets('The inactive screen should not be shown',
          (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        enableAppLockAfterLaunch(widgetTester);

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToHidden(widgetTester);

        await widgetTester.pumpAndSettle(const Duration(seconds: 2));

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToResumed(widgetTester);

        expect(
          inactiveOverlayEntry(widgetTester).mounted,
          false,
        );
      });
    });

    group(
        'When it is disabled and then enabled at runtime and the app transitions from inactive to hidden for less than the lock duration and back to inactive and resumed',
        () {
      late Widget sut;

      setUp(() {
        sut = MaterialApp(
          builder: (context, child) => AppLock(
            initialBackgroundLockLatency: const Duration(seconds: 2),
            initiallyEnabled: false,
            builder: (context, launchArg) => KeyedSubtree(
              key: const Key('Unlocked'),
              child: child!,
            ),
            lockScreenBuilder: (context) => const Scaffold(
              key: Key('LockScreen'),
            ),
            inactiveBuilder: (context) => const Scaffold(
              key: Key('InactiveScreen'),
            ),
          ),
          home: const Scaffold(),
        );
      });

      testWidgets('The lock screen should not be shown', (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        enableAppLockAfterLaunch(widgetTester);

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToHidden(widgetTester);

        await widgetTester.pumpAndSettle(const Duration(seconds: 1));

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToResumed(widgetTester);

        expect(
          lockScreenOverlayEntry(widgetTester).mounted,
          false,
        );
      });

      testWidgets('The unlocked app should be shown', (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        enableAppLockAfterLaunch(widgetTester);

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToHidden(widgetTester);

        await widgetTester.pumpAndSettle(const Duration(seconds: 1));

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToResumed(widgetTester);

        expect(
          appOverlayEntry(widgetTester).mounted,
          true,
        );
      });

      testWidgets('The inactive screen should not be shown',
          (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        enableAppLockAfterLaunch(widgetTester);

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToHidden(widgetTester);

        await widgetTester.pumpAndSettle(const Duration(seconds: 1));

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToResumed(widgetTester);

        expect(
          inactiveOverlayEntry(widgetTester).mounted,
          false,
        );
      });
    });
  });
}
