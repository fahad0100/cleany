import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cleany_store/app/bootstrap.dart';
import 'package:cleany_store/app/config/app_environment.dart';

/// Live end-to-end exercise. This test deliberately uses the public network API.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'live catalog, cart create/delete, profiles, login/logout and Arabic',
    (tester) async {
      Future<void> waitFor(Finder finder, {int seconds = 70}) async {
        final end = DateTime.now().add(Duration(seconds: seconds));
        while (finder.evaluate().isEmpty && DateTime.now().isBefore(end)) {
          await tester.pump(const Duration(milliseconds: 300));
        }
        expect(finder, findsWidgets, reason: 'Expected $finder before timeout');
        await tester.pump(const Duration(milliseconds: 500));
      }

      Future<void> capture(String name) async {
        if (const bool.fromEnvironment('CAPTURE_SCREENSHOTS')) {
          await binding.takeScreenshot(name);
        }
      }

      Future<void> tapKey(String value) async {
        final finder = find.byKey(Key(value));
        await waitFor(finder);
        await tester.ensureVisible(finder);
        await tester.pump(const Duration(milliseconds: 250));
        await tester.tap(finder);
        await tester.pump(const Duration(milliseconds: 500));
      }

      await bootstrap(AppEnvironment.dev);
      await tester.pump();
      await waitFor(find.byKey(const Key('product-1')));
      expect(find.text('20 items'), findsOneWidget);
      await capture('01-catalog');
      await tester.enterText(
        find.byKey(const Key('product-search')),
        'backpack',
      );
      await tester.pump();
      expect(find.text('1 items'), findsOneWidget);
      await tapKey('product-1');
      await tapKey('quantity-plus');
      expect(
        tester.widget<Text>(find.byKey(const Key('quantity-value'))).data,
        '2',
      );
      await capture('02-product-details');
      await tapKey('detail-add-to-cart');
      await waitFor(find.byKey(const Key('cart-11')));
      expect(find.text('Your new demo cart'), findsOneWidget);
      expect(find.text('×2'), findsWidgets);
      await capture('03-cart-created');
      await tapKey('delete-cart-11');
      final deleteEnd = DateTime.now().add(const Duration(seconds: 50));
      while (find.byKey(const Key('cart-11')).evaluate().isNotEmpty &&
          DateTime.now().isBefore(deleteEnd)) {
        await tester.pump(const Duration(milliseconds: 300));
      }
      expect(find.byKey(const Key('cart-11')), findsNothing);
      await waitFor(find.byKey(const Key('cart-1')));
      await tapKey('nav-users');
      await waitFor(find.byKey(const Key('user-1')));
      await tapKey('user-1');
      await waitFor(find.byKey(const Key('profile-details')));
      expect(
        find.descendant(
          of: find.byKey(const Key('profile-details')),
          matching: find.text('john doe'),
        ),
        findsOneWidget,
      );
      await capture('04-user-profile');
      await tester.tapAt(const Offset(10, 100));
      await tester.pump(const Duration(seconds: 1));
      await tapKey('nav-auth');
      await tapKey('demo-account');
      await tester.enterText(
        find.byKey(const Key('password')),
        'invalid-password',
      );
      await tapKey('sign-in');
      await waitFor(find.byKey(const Key('auth-error')));
      await tapKey('demo-account');
      await tapKey('sign-in');
      await waitFor(find.byKey(const Key('signed-in-panel')));
      expect(find.text('@mor_2314'), findsOneWidget);
      await capture('05-signed-in');
      await tapKey('sign-out');
      await waitFor(find.byKey(const Key('username')));
      expect(find.byKey(const Key('signed-in-panel')), findsNothing);
      await tapKey('language-toggle');
      expect(
        Directionality.of(tester.element(find.byType(NavigationBar))),
        TextDirection.rtl,
      );
      expect(find.text('تسجيل الدخول'), findsOneWidget);
      await tapKey('nav-products');
      await waitFor(find.byKey(const Key('product-1')));
      await capture('06-arabic-catalog');
      expect(tester.takeException(), isNull);
    },
  );
}
