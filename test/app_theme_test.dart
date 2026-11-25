import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/theme/app_theme.dart';

import 'support/fake_backend.dart';

void main() {
  testWidgets('tema memakai palet dari proyek Django', (tester) async {
    await tester.pumpWidget(MyApp(apiClient: FakeBackend().client));

    final theme = Theme.of(tester.element(find.byType(Scaffold)));
    expect(theme.colorScheme.primary, AppColors.ink);
    expect(theme.colorScheme.secondary, AppColors.accent);
    expect(theme.scaffoldBackgroundColor, AppColors.paper);
  });

  testWidgets('AppBar halaman utama dan form memakai warna primary yang sama', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MyApp(apiClient: FakeBackend().client));

    Color? appBarColor() =>
        tester.widget<AppBar>(find.byType(AppBar)).backgroundColor;

    expect(appBarColor(), AppColors.ink);

    await tester.tap(find.text('Tambah Pengalaman'));
    await tester.pumpAndSettle();
    expect(appBarColor(), AppColors.ink);
  });
}
