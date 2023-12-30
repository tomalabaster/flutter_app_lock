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

void main() {
  group('Given an AppLock widget', () {
    group('When it is enabled', () {
      late Widget sut;

      setUp(() {
        sut = MaterialApp(
          builder: (context, child) => AppLock(
            backgroundLockLatency: const Duration(seconds: 1),
            enabled: true,
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

        expect(find.byKey(const Key('LockScreen')), findsOneWidget);
      });

      testWidgets('The unlocked app should not be shown', (widgetTester) async {
        await widgetTester.pumpWidget(sut);

        expect(find.byKey(const Key('Unlocked')), findsNothing);
      });

      testWidgets('The inactive screen should not be shown',
          (widgetTester) async {
        await widgetTester.pumpWidget(sut);

        expect(find.byKey(const Key('InactiveScreen')), findsNothing);
      });
    });

    group(
        'When it is enabled and the app becomes inactive without an inactive builder set',
        () {
      late Widget sut;

      setUp(() {
        sut = MaterialApp(
          builder: (context, child) => AppLock(
            backgroundLockLatency: const Duration(seconds: 1),
            enabled: true,
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

        expect(find.byKey(const Key('LockScreen')), findsOneWidget);
      });

      testWidgets('The unlocked app should not be shown', (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        await setAppLifecycleToInactive(widgetTester);

        expect(find.byKey(const Key('Unlocked')), findsNothing);
      });

      testWidgets('The inactive screen should not be shown',
          (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        await setAppLifecycleToInactive(widgetTester);

        expect(find.byKey(const Key('InactiveScreen')), findsNothing);
      });
    });

    group(
        'When it is enabled and the app becomes inactive with an inactive builder set',
        () {
      late Widget sut;

      setUp(() {
        sut = MaterialApp(
          builder: (context, child) => AppLock(
            backgroundLockLatency: const Duration(seconds: 1),
            enabled: true,
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

        expect(find.byKey(const Key('LockScreen')), findsOneWidget);
      });

      testWidgets('The unlocked app should not be shown', (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        await setAppLifecycleToInactive(widgetTester);

        expect(find.byKey(const Key('Unlocked')), findsNothing);
      });

      testWidgets('The inactive screen should not be shown',
          (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        await setAppLifecycleToInactive(widgetTester);

        expect(find.byKey(const Key('InactiveScreen')), findsNothing);
      });
    });

    group('When it is enabled and the app transitions from inactive to resumed',
        () {
      late Widget sut;

      setUp(() {
        sut = MaterialApp(
          builder: (context, child) => AppLock(
            backgroundLockLatency: const Duration(seconds: 1),
            enabled: true,
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

        expect(find.byKey(const Key('LockScreen')), findsOneWidget);
      });

      testWidgets('The unlocked app should not be shown', (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        await setAppLifecycleToInactive(widgetTester);
        await setAppLifecycleToResumed(widgetTester);

        expect(find.byKey(const Key('Unlocked')), findsNothing);
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

        expect(find.byKey(const Key('InactiveScreen')), findsNothing);
      });
    });

    group(
        'When it is enabled and the app transitions from inactive to hidden for longer than the lock duration and back to inactive and resumed',
        () {
      late Widget sut;

      setUp(() {
        sut = MaterialApp(
          builder: (context, child) => AppLock(
            backgroundLockLatency: const Duration(seconds: 1),
            enabled: true,
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

        expect(find.byKey(const Key('LockScreen')), findsOneWidget);
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

        expect(find.byKey(const Key('Unlocked')), findsNothing);
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

        expect(find.byKey(const Key('InactiveScreen')), findsNothing);
      });
    });

    group(
        'When it is enabled and the app transitions from inactive to hidden for less than the lock duration and back to inactive and resumed',
        () {
      late Widget sut;

      setUp(() {
        sut = MaterialApp(
          builder: (context, child) => AppLock(
            backgroundLockLatency: const Duration(seconds: 2),
            enabled: true,
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

        expect(find.byKey(const Key('LockScreen')), findsOneWidget);
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

        expect(find.byKey(const Key('Unlocked')), findsNothing);
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

        expect(find.byKey(const Key('InactiveScreen')), findsNothing);
      });
    });

    group('When it is disabled', () {
      late Widget sut;

      setUp(() {
        sut = MaterialApp(
          builder: (context, child) => AppLock(
            backgroundLockLatency: const Duration(seconds: 1),
            enabled: false,
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

        expect(find.byKey(const Key('LockScreen')), findsNothing);
      });

      testWidgets('The unlocked app should be shown', (widgetTester) async {
        await widgetTester.pumpWidget(sut);

        expect(find.byKey(const Key('Unlocked')), findsOneWidget);
      });

      testWidgets('The inactive screen should not be shown',
          (widgetTester) async {
        await widgetTester.pumpWidget(sut);

        expect(find.byKey(const Key('InactiveScreen')), findsNothing);
      });
    });

    group(
        'When it is disabled and then enabled at runtime and the app becomes inactive without an inactive builder set',
        () {
      late Widget sut;

      setUp(() {
        sut = MaterialApp(
          builder: (context, child) => AppLock(
            backgroundLockLatency: const Duration(seconds: 1),
            enabled: false,
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

        expect(find.byKey(const Key('LockScreen')), findsNothing);
      });

      testWidgets('The unlocked app should be shown', (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        enableAppLockAfterLaunch(widgetTester);

        await setAppLifecycleToInactive(widgetTester);

        expect(find.byKey(const Key('Unlocked')), findsOneWidget);
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

        expect(find.byKey(const Key('InactiveScreen')), findsNothing);
      });
    });

    group(
        'When it is disabled and then enabled at runtime and the app becomes inactive with an inactive builder set',
        () {
      late Widget sut;

      setUp(() {
        sut = MaterialApp(
          builder: (context, child) => AppLock(
            backgroundLockLatency: const Duration(seconds: 1),
            enabled: false,
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

        expect(find.byKey(const Key('LockScreen')), findsNothing);
      });

      testWidgets('The unlocked app should not be shown', (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        enableAppLockAfterLaunch(widgetTester);

        await setAppLifecycleToInactive(widgetTester);

        expect(find.byKey(const Key('Unlocked')), findsNothing);
      });

      testWidgets('The inactive screen should be shown', (widgetTester) async {
        addTearDown(() {
          widgetTester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        });

        await widgetTester.pumpWidget(sut);

        enableAppLockAfterLaunch(widgetTester);

        await setAppLifecycleToInactive(widgetTester);

        expect(find.byKey(const Key('InactiveScreen')), findsOneWidget);
      });
    });

    group(
        'When it is disabled and then enabled at runtime and the app transitions from inactive to resumed',
        () {
      late Widget sut;

      setUp(() {
        sut = MaterialApp(
          builder: (context, child) => AppLock(
            backgroundLockLatency: const Duration(seconds: 1),
            enabled: false,
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

        expect(find.byKey(const Key('LockScreen')), findsNothing);
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

        expect(find.byKey(const Key('Unlocked')), findsOneWidget);
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

        expect(find.byKey(const Key('InactiveScreen')), findsNothing);
      });
    });

    group(
        'When it is disabled and then enabled at runtime and the app transitions from inactive to hidden for longer than the lock duration and back to inactive and resumed',
        () {
      late Widget sut;

      setUp(() {
        sut = MaterialApp(
          builder: (context, child) => AppLock(
            backgroundLockLatency: const Duration(seconds: 1),
            enabled: false,
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

        expect(find.byKey(const Key('LockScreen')), findsOneWidget);
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

        expect(find.byKey(const Key('Unlocked')), findsNothing);
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

        expect(find.byKey(const Key('InactiveScreen')), findsNothing);
      });
    });

    group(
        'When it is disabled and then enabled at runtime and the app transitions from inactive to hidden for less than the lock duration and back to inactive and resumed',
        () {
      late Widget sut;

      setUp(() {
        sut = MaterialApp(
          builder: (context, child) => AppLock(
            backgroundLockLatency: const Duration(seconds: 2),
            enabled: false,
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

        expect(find.byKey(const Key('LockScreen')), findsNothing);
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

        expect(find.byKey(const Key('Unlocked')), findsOneWidget);
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

        expect(find.byKey(const Key('InactiveScreen')), findsNothing);
      });
    });
  });
}
