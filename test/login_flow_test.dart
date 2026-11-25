import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/menu.dart';

import 'support/fake_backend.dart';

/// Teks di dalam drawer, supaya tidak tertukar dengan kartu di halaman utama.
Finder inDrawer(String text) =>
    find.descendant(of: find.byType(Drawer), matching: find.text(text));

Finder field(String label) => find.widgetWithText(TextFormField, label);

Future<void> openDrawer(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Open navigation menu'));
  await tester.pumpAndSettle();
}

Future<void> submitLogin(
  WidgetTester tester, {
  String username = 'owner',
  String password = validPassword,
}) async {
  await tester.enterText(field('Username'), username);
  await tester.enterText(field('Password'), password);
  await tester.tap(find.widgetWithText(FilledButton, 'Login'));
  await tester.pumpAndSettle();
}

void main() {
  group('LoginScreen', () {
    Future<FakeBackend> openLogin(WidgetTester tester) async {
      final backend = FakeBackend();
      await pumpApp(tester, backend);
      await openDrawer(tester);
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      return backend;
    }

    testWidgets('field kosong ditolak tanpa request ke server', (tester) async {
      final backend = await openLogin(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Username tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Password tidak boleh kosong!'), findsOneWidget);
      expect(backend.requests, isEmpty);
    });

    testWidgets('kredensial salah menampilkan SnackBar dan tetap di layar', (
      tester,
    ) async {
      await openLogin(tester);

      await submitLogin(tester, password: 'salah');

      expect(find.text('Username atau password salah.'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(authOf(tester).isLoggedIn, isFalse);
    });

    testWidgets('password disembunyikan', (tester) async {
      await openLogin(tester);

      final editable = tester.widget<EditableText>(
        find.descendant(
          of: field('Password'),
          matching: find.byType(EditableText),
        ),
      );
      expect(editable.obscureText, isTrue);
    });

    testWidgets('login berhasil menutup layar dan drawer', (tester) async {
      await openLogin(tester);

      await submitLogin(tester);

      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(authOf(tester).isLoggedIn, isTrue);
      expect(find.text('My Portfolio'), findsNothing);
    });
  });

  group('drawer', () {
    testWidgets('menampilkan Login saat belum masuk dan Logout setelahnya', (
      tester,
    ) async {
      await pumpApp(tester, FakeBackend());

      await openDrawer(tester);
      expect(find.text('Login'), findsOneWidget);
      expect(inDrawer('Logout'), findsNothing);
      await tester.tapAt(const Offset(390, 400));
      await tester.pumpAndSettle();

      await signIn(tester);
      await openDrawer(tester);
      expect(inDrawer('Logout'), findsOneWidget);
      expect(inDrawer('Login'), findsNothing);
    });

    testWidgets('Logout di drawer mencabut token dan menutup drawer', (
      tester,
    ) async {
      final backend = FakeBackend();
      await pumpApp(tester, backend);
      await signIn(tester);

      await openDrawer(tester);
      await tester.tap(inDrawer('Logout'));
      await tester.pumpAndSettle();

      expect(authOf(tester).isLoggedIn, isFalse);
      expect(find.text('Kamu sudah logout.'), findsOneWidget);
      expect(backend.lastRequestTo('/api/v1/auth/logout/'), isNotNull);
    });

    testWidgets('Add Project tanpa login membuka layar login dulu', (
      tester,
    ) async {
      await pumpApp(tester, FakeBackend());

      await openDrawer(tester);
      await tester.tap(find.text('Add Project'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('membatalkan login membiarkan pengguna di halaman semula', (
      tester,
    ) async {
      await pumpApp(tester, FakeBackend());

      await tester.ensureVisible(find.text('Tambah Proyek'));
      await tester.tap(find.text('Tambah Proyek'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(MyHomePage), findsOneWidget);
      expect(authOf(tester).isLoggedIn, isFalse);
    });
  });
}
