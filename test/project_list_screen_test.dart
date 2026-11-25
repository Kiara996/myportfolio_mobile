import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:myportofolio_mobile/screens/project_detail_screen.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';

import 'support/fake_backend.dart';

Future<void> openList(WidgetTester tester, FakeBackend backend) async {
  await pumpApp(tester, backend);
  await tester.ensureVisible(find.text('Lihat Proyek'));
  await tester.tap(find.text('Lihat Proyek'));
  await tester.pumpAndSettle();
}

int listCalls(FakeBackend backend) => backend.requests
    .where((r) => r.method == 'GET' && r.url.path == '/api/v1/projects/')
    .length;

void main() {
  testWidgets('menampilkan indikator loading lalu daftar proyek', (
    tester,
  ) async {
    final backend = FakeBackend(
      projects: [
        projectJson(title: 'Senja di Kota Tua'),
        projectJson(id: '22222222-2222-2222-2222-222222222222', title: 'Pagi'),
      ],
    )..gate = Completer<void>();
    await pumpApp(tester, backend);
    await tester.ensureVisible(find.text('Lihat Proyek'));
    await tester.tap(find.text('Lihat Proyek'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    backend.gate!.complete();
    await tester.pumpAndSettle();

    expect(find.byType(ProjectListScreen), findsOneWidget);
    expect(find.text('Senja di Kota Tua'), findsOneWidget);
    expect(find.text('Pagi'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('bisa dibuka tanpa login dan tidak request ulang saat rebuild', (
    tester,
  ) async {
    final backend = FakeBackend();
    await openList(tester, backend);

    expect(authOf(tester).isLoggedIn, isFalse);
    expect(
      backend.requests.first.headers.containsKey('Authorization'),
      isFalse,
    );

    await tester.pump();
    await tester.pump();
    expect(listCalls(backend), 1);
  });

  testWidgets('daftar kosong menampilkan pesan dan tetap bisa di-refresh', (
    tester,
  ) async {
    final backend = FakeBackend(projects: []);
    await openList(tester, backend);

    expect(find.text('Belum ada proyek.'), findsOneWidget);

    backend.projects = [projectJson(title: 'Baru Muncul')];
    await tester.fling(
      find.byType(Scrollable).first,
      const Offset(0, 300),
      1000,
    );
    await tester.pumpAndSettle();

    expect(find.text('Baru Muncul'), findsOneWidget);
    expect(listCalls(backend), 2);
  });

  testWidgets('error menampilkan pesan ramah dan tombol coba lagi', (
    tester,
  ) async {
    final backend = FakeBackend()..listStatus = 500;
    await openList(tester, backend);

    expect(find.textContaining('Gagal memuat proyek'), findsOneWidget);
    expect(find.textContaining('kode 500'), findsOneWidget);

    backend.listStatus = null;
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();

    expect(find.text('Senja di Kota Tua'), findsOneWidget);
  });

  testWidgets('mengetuk item membuka detail tanpa gambar bila URL kosong', (
    tester,
  ) async {
    await openList(tester, FakeBackend());

    await tester.tap(find.text('Senja di Kota Tua'));
    await tester.pumpAndSettle();

    expect(find.byType(ProjectDetailScreen), findsOneWidget);
    expect(find.text('Memotret suasana sore di Kota Tua.'), findsOneWidget);
    expect(find.text('Fujifilm X-T30 II'), findsOneWidget);
    expect(find.text('Adobe Lightroom'), findsOneWidget);
    expect(find.text('Jakarta'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('detail menampilkan gambar saat URL terisi', (tester) async {
    final backend = FakeBackend(
      projects: [projectJson(imageUrl: 'https://example.com/foto.jpg')],
    );
    await openList(tester, backend);

    await tester.tap(find.text('Senja di Kota Tua'));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
  });
}
