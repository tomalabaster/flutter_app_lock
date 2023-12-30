import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app_lock_example/main.dart' as app;
import 'package:integration_test/integration_test.dart';

final myHomePage = find.byKey(const Key('MyHomePage'));
final lockScreen = find.byKey(const Key('LockScreen'));
final inactiveScreen = find.byKey(const Key('InactiveScreen'));
final showButton = find.byKey(const Key('ShowButton'));
final passwordField = find.byKey(const Key('PasswordField'));
final unlockButton = find.byKey(const Key('UnlockButton'));
final enableButton = find.byKey(const Key('EnableButton'));
final disableButton = find.byKey(const Key('DisableButton'));

Future<void> enterCorrectPassword(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.enterText(passwordField, '0000');
  await tester.tap(unlockButton);
  await tester.pumpAndSettle();
}

Future<void> enterIncorrectPassword(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.enterText(passwordField, 'incorrect password');
  await tester.tap(unlockButton);
  await tester.pumpAndSettle();
}

Future<void> enableAfterLaunch(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.tap(enableButton);
  await tester.pumpAndSettle();
}

Future<void> disableAfterLaunch(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.tap(disableButton);
  await tester.pumpAndSettle();
}

Future<void> enterBackgroundForDuration(
    WidgetTester tester, Duration duration) async {
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);

  if (tester.binding is IntegrationTestWidgetsFlutterBinding) {
    await Future.delayed(duration);
  } else {
    await tester.pumpAndSettle(duration);
  }

  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

  await tester.pumpAndSettle();
}

Future<void> becomeInactiveForDuration(
    WidgetTester tester, Duration duration) async {
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);

  if (tester.binding is IntegrationTestWidgetsFlutterBinding) {
    await Future.delayed(duration);
  } else {
    await tester.pumpAndSettle(duration);
  }

  await tester.pumpAndSettle();
}

Future<void> becomeResumed(WidgetTester tester) async {
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

  await tester.pumpAndSettle();
}

void main() {
  group('Given an active lock screen', () {
    group('When entering a correct password', () {
      testWidgets('The home screen is visible', (WidgetTester tester) async {
        app.main(enabled: true);

        await enterCorrectPassword(tester);

        expect(myHomePage, findsOneWidget);
      });

      testWidgets('The lock screen is no longer visible',
          (WidgetTester tester) async {
        app.main(enabled: true);

        await enterCorrectPassword(tester);

        expect(lockScreen, findsNothing);
      });

      testWidgets('Some data is made available to the rest of the app',
          (WidgetTester tester) async {
        app.main(enabled: true);

        await enterCorrectPassword(tester);

        expect(find.textContaining('some data'), findsOneWidget);
      });
    });

    group('When entering an incorrect password', () {
      testWidgets('The home screen is still not visible',
          (WidgetTester tester) async {
        app.main(enabled: true);

        await enterIncorrectPassword(tester);

        expect(myHomePage, findsNothing);
      });

      testWidgets('The lock screen remains visible',
          (WidgetTester tester) async {
        app.main(enabled: true);

        await enterIncorrectPassword(tester);

        expect(lockScreen, findsOneWidget);
      });
    });
  });

  group('Given an app with AppLock disabled', () {
    group('When the app is launched', () {
      testWidgets('The home screen is visible', (WidgetTester tester) async {
        app.main(enabled: false);

        await tester.pumpAndSettle();

        expect(myHomePage, findsOneWidget);
      });

      testWidgets('The lock screen is not visible',
          (WidgetTester tester) async {
        app.main(enabled: false);

        await tester.pumpAndSettle();

        expect(lockScreen, findsNothing);
      });
    });

    group('When enabling it after launch', () {
      group(
          'And the app has been in the background for longer than the specified duration',
          () {
        testWidgets('The lock screen should be shown',
            (WidgetTester tester) async {
          app.main(
              enabled: false,
              backgroundLockLatency: const Duration(seconds: 1));

          await enableAfterLaunch(tester);
          await enterBackgroundForDuration(tester, const Duration(seconds: 2));

          expect(lockScreen, findsOneWidget);
        });
      });

      group('And the app becomes inactive', () {
        group('And there is an inactive builder set', () {
          testWidgets('The widget from the inactive builder should be shown',
              (widgetTester) async {
            app.main(
                enabled: false,
                backgroundLockLatency: const Duration(seconds: 2));

            await enableAfterLaunch(widgetTester);
            await becomeInactiveForDuration(
                widgetTester, const Duration(seconds: 1));

            expect(inactiveScreen, findsOne);
          });

          testWidgets('The lock screen should not be shown',
              (widgetTester) async {
            app.main(
                enabled: false,
                backgroundLockLatency: const Duration(seconds: 2));

            await enableAfterLaunch(widgetTester);
            await becomeInactiveForDuration(
                widgetTester, const Duration(seconds: 1));

            expect(lockScreen, findsNothing);
          });
        });
      });
    });

    group('When asked to show', () {
      testWidgets('The lock screen is visible', (WidgetTester tester) async {
        app.main(enabled: false);

        await tester.pumpAndSettle();
        await tester.tap(showButton);
        await tester.pumpAndSettle();

        expect(lockScreen, findsOneWidget);
      });
    });

    group('When the app becomes inactive', () {
      group('And there is an inactive builder set', () {
        testWidgets('The widget from the inactive builder should not be shown',
            (widgetTester) async {
          app.main(
              enabled: false,
              backgroundLockLatency: const Duration(seconds: 2));

          await becomeInactiveForDuration(
              widgetTester, const Duration(seconds: 1));

          expect(inactiveScreen, findsNothing);
        });

        testWidgets('The lock screen should not be shown',
            (widgetTester) async {
          app.main(
              enabled: false,
              backgroundLockLatency: const Duration(seconds: 2));

          await becomeInactiveForDuration(
              widgetTester, const Duration(seconds: 1));

          expect(lockScreen, findsNothing);
        });
      });
    });
  });

  group('Given an app with AppLock enabled', () {
    group('When the app is launched', () {
      testWidgets('The home screen is not visible',
          (WidgetTester tester) async {
        app.main(enabled: true);

        await tester.pumpAndSettle();

        expect(myHomePage, findsNothing);
      });

      testWidgets('The lock screen is visible', (WidgetTester tester) async {
        app.main(enabled: true);

        await tester.pumpAndSettle();

        expect(lockScreen, findsOneWidget);
      });
    });

    group('When disabling it after launch', () {
      testWidgets(
          'The lock screen isn\'t shown when the app has been in background for longer than the specified duration',
          (WidgetTester tester) async {
        app.main(
            enabled: true, backgroundLockLatency: const Duration(seconds: 1));

        await enterCorrectPassword(tester);
        await disableAfterLaunch(tester);
        await enterBackgroundForDuration(tester, const Duration(seconds: 2));

        expect(lockScreen, findsNothing);
      });
    });

    group(
        'When the app has been in the background for less than the specified duration',
        () {
      testWidgets('The lock screen is not visible',
          (WidgetTester tester) async {
        app.main(
            enabled: false, backgroundLockLatency: const Duration(seconds: 2));

        await enableAfterLaunch(tester);
        await enterBackgroundForDuration(tester, const Duration(seconds: 1));

        expect(lockScreen, findsNothing);
      });
    });

    group(
        'When the app has been in the background for longer than the specified duration',
        () {
      testWidgets('The lock screen is visible', (WidgetTester tester) async {
        app.main(
            enabled: false, backgroundLockLatency: const Duration(seconds: 1));

        await enableAfterLaunch(tester);
        await enterBackgroundForDuration(tester, const Duration(seconds: 2));

        expect(lockScreen, findsOneWidget);
      });
    });

    group('When the app becomes inactive', () {
      group('And there is an inactive builder set', () {
        testWidgets('The widget from the inactive builder should not be shown',
            (widgetTester) async {
          app.main(
              enabled: true, backgroundLockLatency: const Duration(seconds: 2));

          await becomeInactiveForDuration(
              widgetTester, const Duration(seconds: 1));

          expect(inactiveScreen, findsNothing);
        });

        testWidgets('The lock screen should still be shown',
            (widgetTester) async {
          app.main(
              enabled: true, backgroundLockLatency: const Duration(seconds: 2));

          await becomeInactiveForDuration(
              widgetTester, const Duration(seconds: 1));

          expect(lockScreen, findsOneWidget);
        });
      });
    });
  });
}
