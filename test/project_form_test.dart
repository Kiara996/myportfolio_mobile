import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

import 'support/fake_backend.dart';

Future<void> openDrawer(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Open navigation menu'));
  await tester.pumpAndSettle();
}

Finder field(String label) => find.widgetWithText(TextFormField, label);

Future<void> openForm(WidgetTester tester, FakeBackend backend) async {
  await pumpApp(tester, backend);
  await signIn(tester);
  await tester.ensureVisible(find.text('Tambah Proyek'));
  await tester.tap(find.text('Tambah Proyek'));
  await tester.pumpAndSettle();
}

Future<void> save(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Simpan'));
  await tester.tap(find.text('Simpan'));
  await tester.pumpAndSettle();
}

Future<void> fillRequired(WidgetTester tester) async {
  await tester.enterText(field('Nama Proyek'), 'Senja di Pelabuhan');
  await tester.enterText(field('Cerita Proyek'), 'Menunggu kapal terakhir');
  await tester.enterText(field('Kamera dan Lensa'), 'Sony A7 III');
  await tester.enterText(
    field('Pengaturan Pemotretan'),
    'f/8, 1/125s, ISO 100',
  );
}

Map<String, dynamic> postedBody(FakeBackend backend) {
  final request = backend.lastRequestTo('/api/v1/projects/');
  return jsonDecode(request!.body) as Map<String, dynamic>;
}

void main() {
  group('navigasi', () {
    testWidgets('tombol Tambah Proyek membuka form dan bisa kembali', (
      tester,
    ) async {
      await openForm(tester, FakeBackend());
      expect(find.byType(ProjectFormPage), findsOneWidget);

      // AppBar berdrawer menampilkan ikon menu, jadi kembali lewat tombol Back sistem.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
    });

    testWidgets('drawer berpindah antara Home dan Add Project', (tester) async {
      await pumpApp(tester, FakeBackend());
      await signIn(tester);

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

  group('validasi', () {
    testWidgets('field wajib kosong menampilkan pesan error', (tester) async {
      final backend = FakeBackend();
      await openForm(tester, backend);

      await save(tester);

      expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Cerita proyek tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Kamera dan lensa tidak boleh kosong!'), findsOneWidget);
      expect(
        find.text('Pengaturan pemotretan tidak boleh kosong!'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);
      expect(backend.lastRequestTo('/api/v1/projects/'), isNull);
    });

    testWidgets('input hanya spasi atau hanya tag HTML ditolak', (
      tester,
    ) async {
      await openForm(tester, FakeBackend());

      await tester.enterText(field('Nama Proyek'), '   ');
      await tester.enterText(field('Cerita Proyek'), '<b></b>');
      await save(tester);

      expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
      expect(
        find.text('Cerita tidak boleh hanya berisi tag HTML!'),
        findsOneWidget,
      );
    });

    testWidgets('URL gambar tidak valid atau Drive non-thumbnail ditolak', (
      tester,
    ) async {
      final backend = FakeBackend();
      await openForm(tester, backend);
      await fillRequired(tester);

      await tester.enterText(field('URL Gambar'), 'bukan-url');
      await save(tester);
      expect(find.textContaining('http://'), findsOneWidget);

      await tester.enterText(
        field('URL Gambar'),
        'https://drive.google.com/file/d/abc/view',
      );
      await save(tester);
      expect(find.textContaining('format thumbnail'), findsOneWidget);
      expect(backend.lastRequestTo('/api/v1/projects/'), isNull);
    });

    testWidgets('tidak overflow di layar 320 dp', (tester) async {
      await openForm(tester, FakeBackend());
      tester.view.physicalSize = const Size(320, 640);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('kirim ke API', () {
    testWidgets('input valid dikirim dengan token lalu tampil dialog', (
      tester,
    ) async {
      final backend = FakeBackend();
      await openForm(tester, backend);
      await fillRequired(tester);

      await save(tester);

      final request = backend.lastRequestTo('/api/v1/projects/')!;
      expect(request.headers['Authorization'], 'Token $validToken');
      expect(request.headers['Content-Type'], contains('application/json'));
      expect(postedBody(backend), {
        'title': 'Senja di Pelabuhan',
        'story': 'Menunggu kapal terakhir',
        'camera_gear': 'Sony A7 III',
        'capture_settings': 'f/8, 1/125s, ISO 100',
        'editing_software': 'lightroom',
      });

      expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
      expect(find.text('Nama: Senja di Pelabuhan'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Senja di Pelabuhan'), findsNothing);
    });

    testWidgets('field opsional, dropdown, dan tanggal ikut terkirim', (
      tester,
    ) async {
      final backend = FakeBackend();
      await openForm(tester, backend);
      await fillRequired(tester);
      await tester.enterText(field('Lokasi'), 'Pelabuhan Sunda Kelapa');
      await tester.enterText(
        field('URL Gambar'),
        'https://drive.google.com/thumbnail?id=abc&sz=w1000',
      );

      await tester.ensureVisible(field('Tanggal Pengambilan'));
      await tester.tap(field('Tanggal Pengambilan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Adobe Lightroom'));
      await tester.tap(find.text('Adobe Lightroom'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Capture One').last);
      await tester.pumpAndSettle();

      await save(tester);

      final body = postedBody(backend);
      expect(body['editing_software'], 'capture-one');
      expect(body['location_taken'], 'Pelabuhan Sunda Kelapa');
      expect(
        body['image_url'],
        'https://drive.google.com/thumbnail?id=abc&sz=w1000',
      );
      expect(body['taken_at'], formatIsoDate(DateTime.now()));
    });

    testWidgets('belum login diarahkan ke layar login dulu', (tester) async {
      final backend = FakeBackend();
      await pumpApp(tester, backend);
      await tester.ensureVisible(find.text('Tambah Proyek'));
      await tester.tap(find.text('Tambah Proyek'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(ProjectFormPage), findsNothing);

      await tester.enterText(field('Username'), 'owner');
      await tester.enterText(field('Password'), validPassword);
      await tester.tap(find.widgetWithText(FilledButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(ProjectFormPage), findsOneWidget);
    });

    testWidgets('401 mengeluarkan sesi dan meminta login ulang', (
      tester,
    ) async {
      final backend = FakeBackend();
      await openForm(tester, backend);
      await fillRequired(tester);
      backend.acceptedToken = 'token-lain';

      await save(tester);

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(authOf(tester).isLoggedIn, isFalse);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('403 menampilkan SnackBar dan sesi tetap aktif', (
      tester,
    ) async {
      final backend = FakeBackend()..createStatus = 403;
      await openForm(tester, backend);
      await fillRequired(tester);

      await save(tester);

      expect(
        find.text('Akun ini tidak punya izin untuk aksi tersebut.'),
        findsOneWidget,
      );
      expect(authOf(tester).isLoggedIn, isTrue);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('server error 500 tidak menampilkan body mentah', (
      tester,
    ) async {
      final backend = FakeBackend()..createStatus = 500;
      await openForm(tester, backend);
      await fillRequired(tester);

      await save(tester);

      expect(find.text('Server sedang bermasalah (kode 500).'), findsOneWidget);
    });
  });
}
