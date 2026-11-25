import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

import 'support/fake_backend.dart';

Future<void> pumpApp(
  WidgetTester tester, {
  Size size = const Size(400, 900),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MyApp(apiClient: FakeBackend().client));
}

Future<void> openDrawer(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Open navigation menu'));
  await tester.pumpAndSettle();
}

Future<void> openFormFromCard(WidgetTester tester, {Size? size}) async {
  await pumpApp(tester, size: size ?? const Size(400, 900));
  // Di layar pendek kartunya ada di bawah lipatan, jadi scroll dulu.
  await tester.ensureVisible(find.text('Tambah Pengalaman'));
  await tester.tap(find.text('Tambah Pengalaman'));
  await tester.pumpAndSettle();
}

Finder field(String label) => find.widgetWithText(TextFormField, label);

Future<void> save(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Simpan'));
  await tester.tap(find.text('Simpan'));
  await tester.pumpAndSettle();
}

/// Buka date picker lewat field lalu konfirmasi tanggal default (hari ini).
Future<void> pickToday(WidgetTester tester, String label) async {
  await tester.ensureVisible(field(label));
  await tester.tap(field(label));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

Future<void> fillRequired(WidgetTester tester) async {
  await tester.enterText(field('Nama Pengalaman'), 'Magang Backend');
  await tester.enterText(field('Deskripsi Pengalaman'), 'Bikin REST API');
  await pickToday(tester, 'Tanggal Mulai');
}

void main() {
  group('navigasi', () {
    testWidgets('kartu Tambah Pengalaman membuka form dan bisa kembali', (
      tester,
    ) async {
      await openFormFromCard(tester);
      expect(find.byType(ExperienceFormPage), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
    });

    testWidgets('drawer membuka form Pengalaman dan Home membawa kembali', (
      tester,
    ) async {
      await pumpApp(tester);

      await openDrawer(tester);
      await tester.tap(find.text('Add Experience'));
      await tester.pumpAndSettle();
      expect(find.byType(ExperienceFormPage), findsOneWidget);

      await openDrawer(tester);
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(ExperienceFormPage), findsNothing);
    });

    testWidgets('drawer di form Pengalaman bisa pindah ke Add Project', (
      tester,
    ) async {
      await openFormFromCard(tester);
      await signIn(tester);

      await openDrawer(tester);
      await tester.tap(find.text('Add Project'));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectFormPage), findsOneWidget);
    });
  });

  group('validasi', () {
    testWidgets('field wajib kosong menampilkan pesan error tanpa dialog', (
      tester,
    ) async {
      await openFormFromCard(tester);
      await save(tester);

      expect(find.text('Nama pengalaman tidak boleh kosong!'), findsOneWidget);
      expect(
        find.text('Deskripsi pengalaman tidak boleh kosong!'),
        findsOneWidget,
      );
      expect(find.text('Tanggal mulai wajib dipilih!'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('input hanya spasi dianggap kosong', (tester) async {
      await openFormFromCard(tester);
      await tester.enterText(field('Nama Pengalaman'), '    ');
      await save(tester);

      expect(find.text('Nama pengalaman tidak boleh kosong!'), findsOneWidget);
    });

    testWidgets('nama yang cuma tag HTML ditolak', (tester) async {
      await openFormFromCard(tester);
      await fillRequired(tester);
      await tester.enterText(field('Nama Pengalaman'), '<b></b>');
      await save(tester);

      expect(
        find.text('Nama pengalaman tidak boleh hanya berisi tag HTML!'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('nama lebih dari 255 karakter ditolak', (tester) async {
      await openFormFromCard(tester);
      await fillRequired(tester);
      await tester.enterText(field('Nama Pengalaman'), 'a' * 256);
      await save(tester);

      expect(
        find.text('Nama pengalaman maksimal 255 karakter!'),
        findsOneWidget,
      );
    });

    testWidgets('thumbnail bukan URL ditolak, kosong diterima', (tester) async {
      await openFormFromCard(tester);
      await fillRequired(tester);

      await tester.enterText(field('URL Thumbnail'), 'bukan-url');
      await save(tester);
      expect(find.textContaining('http://'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);

      await tester.enterText(field('URL Thumbnail'), '');
      await save(tester);
      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });

  group('dialog ringkasan', () {
    testWidgets('input valid menampilkan data, tanpa tanggal selesai', (
      tester,
    ) async {
      await openFormFromCard(tester);
      await fillRequired(tester);
      await tester.enterText(
        field('URL Thumbnail'),
        'https://example.com/a.png',
      );
      await save(tester);

      expect(find.text('Pengalaman berhasil ditambahkan!'), findsOneWidget);
      expect(find.text('Nama: Magang Backend'), findsOneWidget);
      expect(find.text('Deskripsi: Bikin REST API'), findsOneWidget);
      expect(find.text('Kategori: Full-Time'), findsOneWidget);
      expect(find.text('Thumbnail: https://example.com/a.png'), findsOneWidget);
      expect(find.text('Mulai: ${formatDate(DateTime.now())}'), findsOneWidget);
      expect(find.text('Selesai: Sedang berlangsung'), findsOneWidget);
    });

    testWidgets('tanggal selesai dan kategori pilihan ikut tampil', (
      tester,
    ) async {
      await openFormFromCard(tester);
      await fillRequired(tester);
      await pickToday(tester, 'Tanggal Selesai');

      await tester.tap(find.text('Full-Time'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Research').last);
      await tester.pumpAndSettle();
      await save(tester);

      expect(find.text('Kategori: Research'), findsOneWidget);
      expect(
        find.text('Selesai: ${formatDate(DateTime.now())}'),
        findsOneWidget,
      );
    });

    testWidgets('OK menutup dialog dan mereset form', (tester) async {
      await openFormFromCard(tester);
      await fillRequired(tester);
      await save(tester);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Magang Backend'), findsNothing);
      expect(find.text(formatDate(DateTime.now())), findsNothing);
    });
  });

  testWidgets('tanggal selesai bisa dihapus lewat ikon clear', (tester) async {
    await openFormFromCard(tester);
    await pickToday(tester, 'Tanggal Selesai');
    expect(find.text(formatDate(DateTime.now())), findsOneWidget);

    await tester.tap(find.byTooltip('Hapus tanggal selesai'));
    await tester.pumpAndSettle();
    expect(find.text(formatDate(DateTime.now())), findsNothing);
  });

  testWidgets('tombol Simpan tetap terjangkau di layar sempit', (tester) async {
    await openFormFromCard(tester, size: const Size(320, 480));
    expect(tester.takeException(), isNull);

    await fillRequired(tester);
    await save(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(AlertDialog), findsOneWidget);
  });
}
