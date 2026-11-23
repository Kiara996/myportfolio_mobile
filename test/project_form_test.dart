import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

Future<void> pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const MyApp());
}

Future<void> openDrawer(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Open navigation menu'));
  await tester.pumpAndSettle();
}

Finder field(String label) => find.widgetWithText(TextFormField, label);

Future<void> fillRequired(WidgetTester tester) async {
  await tester.enterText(field('Nama Proyek'), 'Portofolio Mobile');
  await tester.enterText(field('Deskripsi Proyek'), 'Aplikasi portofolio');
}

void main() {
  group('navigasi', () {
    testWidgets('tombol Tambah Proyek membuka form dan bisa kembali', (
      tester,
    ) async {
      await pumpApp(tester);

      await tester.tap(find.text('Tambah Proyek'));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectFormPage), findsOneWidget);

      // AppBar berdrawer menampilkan ikon menu, jadi kembali lewat tombol Back sistem.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
    });

    testWidgets('drawer berpindah antara Home dan Add Project', (tester) async {
      await pumpApp(tester);

      await openDrawer(tester);
      await tester.tap(find.text('Add Project'));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectFormPage), findsOneWidget);

      await openDrawer(tester);
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(ProjectFormPage), findsNothing);
    });
  });

  group('form tambah proyek', () {
    Future<void> openForm(WidgetTester tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Tambah Proyek'));
      await tester.pumpAndSettle();
    }

    testWidgets('field wajib kosong menampilkan pesan error', (tester) async {
      await openForm(tester);

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('input hanya spasi dianggap kosong', (tester) async {
      await openForm(tester);

      await tester.enterText(field('Nama Proyek'), '   ');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
    });

    testWidgets('tautan tidak valid ditolak, tautan kosong diterima', (
      tester,
    ) async {
      await openForm(tester);
      await fillRequired(tester);

      await tester.enterText(field('Tautan Proyek'), 'bukan-url');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.textContaining('http://'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);

      await tester.enterText(field('Tautan Proyek'), '');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('input valid menampilkan dialog berisi data, OK mereset form', (
      tester,
    ) async {
      await openForm(tester);
      await fillRequired(tester);
      await tester.enterText(field('Teknologi yang Digunakan'), 'Flutter');
      await tester.enterText(field('Tautan Proyek'), 'https://example.com');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
      expect(find.text('Nama Proyek: Portofolio Mobile'), findsOneWidget);
      expect(find.text('Deskripsi: Aplikasi portofolio'), findsOneWidget);
      expect(find.text('Kategori: Web Development'), findsOneWidget);
      expect(find.text('Teknologi: Flutter'), findsOneWidget);
      expect(find.text('Tautan: https://example.com'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Portofolio Mobile'), findsNothing);
    });

    testWidgets('tidak overflow di layar 320 dp', (tester) async {
      await openForm(tester);
      tester.view.physicalSize = const Size(320, 640);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('kategori yang dipilih muncul di dialog', (tester) async {
      await openForm(tester);
      await fillRequired(tester);

      await tester.tap(find.text('Web Development'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Data Science').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Kategori: Data Science'), findsOneWidget);
    });
  });
}
