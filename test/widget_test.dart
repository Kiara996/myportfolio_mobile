// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

import 'support/fake_backend.dart';

Future<FakeBackend> pumpHome(
  WidgetTester tester, {
  Size size = const Size(400, 800),
  bool loggedIn = false,
}) async {
  final backend = FakeBackend();
  await pumpApp(tester, backend, size: size);
  if (loggedIn) await signIn(tester);
  return backend;
}

List<ItemHomepage> itemsOf(WidgetTester tester) =>
    tester.widget<MyHomePage>(find.byType(MyHomePage)).items;

void main() {
  testWidgets('menampilkan identitas pada tiga InfoCard', (tester) async {
    await pumpHome(tester);

    expect(find.byType(InfoCard), findsNWidgets(3));
    for (final label in ['NPM', 'Name', 'Class']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('2506612266'), findsOneWidget);
    expect(find.text('Kevin Fauzan Arjuna'), findsOneWidget);
    expect(find.text('PBP F'), findsOneWidget);
  });

  testWidgets('setiap ItemCard memakai warna uniknya sendiri', (tester) async {
    await pumpHome(tester);

    final items = itemsOf(tester);
    expect(items.length, greaterThanOrEqualTo(3));
    expect(items.map((i) => i.color).toSet().length, items.length);

    for (final item in items) {
      final card = find.widgetWithText(ItemCard, item.name);
      final material = tester.widget<Material>(
        find.descendant(of: card, matching: find.byType(Material)).first,
      );
      expect(material.color, item.color, reason: item.name);
    }
  });

  testWidgets('tombol biasa menampilkan SnackBar sesuai namanya', (
    tester,
  ) async {
    await pumpHome(tester);

    final plainItems = itemsOf(tester)
        .where((i) => i.confirmMessage == null && i.destination == null);
    for (final item in plainItems) {
      await tester.tap(find.text(item.name));
      await tester.pump();

      expect(
        find.text('Kamu telah menekan tombol ${item.name}!'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);
    }
  });

  group('Logout', () {
    testWidgets('belum login hanya menampilkan SnackBar tanpa dialog', (
      tester,
    ) async {
      await pumpHome(tester);

      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(find.text('Kamu belum login.'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('sudah login menampilkan SnackBar dan dialog konfirmasi', (
      tester,
    ) async {
      await pumpHome(tester, loggedIn: true);

      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(find.text('Kamu telah menekan tombol Logout!'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('Batal menutup dialog tanpa logout', (tester) async {
      await pumpHome(tester, loggedIn: true);

      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Logout berhasil.'), findsNothing);
      expect(authOf(tester).isLoggedIn, isTrue);
    });

    testWidgets('konfirmasi mencabut token dan menampilkan SnackBar', (
      tester,
    ) async {
      final backend = await pumpHome(tester, loggedIn: true);

      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Logout'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Logout berhasil.'), findsOneWidget);
      expect(authOf(tester).isLoggedIn, isFalse);
      final request = backend.lastRequestTo('/api/v1/auth/logout/');
      expect(request!.headers['Authorization'], 'Token $validToken');
    });
  });

  group('layout responsif', () {
    const sizes = {
      'ponsel kecil': Size(320, 568),
      'ponsel umum': Size(360, 640),
      'ponsel landscape': Size(640, 360),
      'tablet': Size(800, 1280),
      'desktop': Size(1200, 800),
    };

    for (final entry in sizes.entries) {
      testWidgets('tidak overflow di ${entry.key}', (tester) async {
        await pumpHome(tester, size: entry.value);

        expect(tester.takeException(), isNull);
        expect(find.byType(ItemCard), findsNWidgets(itemsOf(tester).length));
      });
    }

    testWidgets('kolom grid menyesuaikan lebar layar', (tester) async {
      int columns() {
        final grid = tester.widget<GridView>(find.byType(GridView));
        return (grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
            .crossAxisCount;
      }

      await pumpHome(tester, size: const Size(360, 640));
      expect(columns(), 3);

      await pumpHome(tester, size: const Size(1200, 800));
      expect(columns(), 6);
    });
  });
}
