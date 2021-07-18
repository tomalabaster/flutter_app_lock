import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_app_lock_example/main.dart' as app;

final myApp = find.byKey(Key('MyApp'));
final lockScreen = find.byKey(Key('LockScreen'));
final showButton = find.byKey(Key('ShowButton'));
final passwordField = find.byKey(Key('PasswordField'));
final unlockButton = find.byKey(Key('UnlockButton'));

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Given an active lock screen', () {
    group('When entering a correct password', () {
      Future<void> enterCorrectPassword(WidgetTester tester) async {
        await tester.pumpAndSettle();
        await tester.enterText(passwordField, '0000');
        await tester.tap(unlockButton);
        await tester.pumpAndSettle();
      }

      testWidgets('The app is visible', (WidgetTester tester) async {
        app.main(enabled: true);

        await enterCorrectPassword(tester);

        expect(myApp, findsOneWidget);
      });

      testWidgets('The lock screen is no longer visible',
          (WidgetTester tester) async {
        app.main(enabled: true);

        await enterCorrectPassword(tester);

        expect(lockScreen, findsNothing);
      });
    });

    group('When entering an incorrect password', () {
      Future<void> enterIncorrectPassword(WidgetTester tester) async {
        await tester.pumpAndSettle();
        await tester.enterText(passwordField, 'incorrect password');
        await tester.tap(unlockButton);
        await tester.pumpAndSettle();
      }

      testWidgets('The app is still not visible', (WidgetTester tester) async {
        app.main(enabled: true);

        await enterIncorrectPassword(tester);

        expect(myApp, findsNothing);
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
      testWidgets('The app is visible', (WidgetTester tester) async {
        app.main(enabled: false);

        await tester.pumpAndSettle();

        expect(myApp, findsOneWidget);
      });

      testWidgets('The lock screen is not visible',
          (WidgetTester tester) async {
        app.main(enabled: false);

        await tester.pumpAndSettle();

        expect(lockScreen, findsNothing);
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
      testWidgets('The app is not visible', (WidgetTester tester) async {
        app.main(enabled: true);

        await tester.pumpAndSettle();

        expect(myApp, findsNothing);
      });

      testWidgets('The lock screen is visible', (WidgetTester tester) async {
        app.main(enabled: true);

        await tester.pumpAndSettle();

        expect(lockScreen, findsOneWidget);
      });
    });
  });
}
