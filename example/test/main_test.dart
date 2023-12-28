import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app_lock_example/main.dart' as app;

final myHomePage = find.byKey(const Key('MyHomePage'));
final lockScreen = find.byKey(const Key('LockScreen'));
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

  await Future.delayed(duration);

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
      testWidgets(
          'The lock screen is shown when the app has been in background for longer than the specified duration',
          (WidgetTester tester) async {
        app.main(
            enabled: true, backgroundLockLatency: const Duration(seconds: 1));

        await enterCorrectPassword(tester);
        await enableAfterLaunch(tester);
        await enterBackgroundForDuration(tester, const Duration(seconds: 1));

        expect(lockScreen, findsOneWidget);
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
        await enterBackgroundForDuration(tester, const Duration(seconds: 1));

        expect(lockScreen, findsNothing);
      });
    });

    group(
        'When the app has been in the background for less than the specified duration',
        () {
      testWidgets('The lock screen is not visible',
          (WidgetTester tester) async {
        app.main(
            enabled: false, backgroundLockLatency: const Duration(seconds: 1));

        await enableAfterLaunch(tester);
        await enterBackgroundForDuration(tester, const Duration(seconds: 0));

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
        await enterBackgroundForDuration(tester, const Duration(seconds: 1));

        expect(lockScreen, findsOneWidget);
      });
    });
  });
}
