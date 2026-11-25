import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';

import 'support/fake_backend.dart';

void main() {
  test('login menyimpan token dan memberi tahu listener', () async {
    final auth = AuthState(FakeBackend().client);
    var notified = 0;
    auth.addListener(() => notified++);

    expect(auth.isLoggedIn, isFalse);
    await auth.login('owner', validPassword);

    expect(auth.token, validToken);
    expect(auth.isLoggedIn, isTrue);
    expect(notified, 1);
  });

  test('login gagal tidak mengubah state', () async {
    final auth = AuthState(FakeBackend().client);
    var notified = 0;
    auth.addListener(() => notified++);

    await expectLater(
      auth.login('owner', 'salah'),
      throwsA(isA<ApiException>()),
    );

    expect(auth.isLoggedIn, isFalse);
    expect(notified, 0);
  });

  test('logout menghapus token dan memanggil server', () async {
    final backend = FakeBackend();
    final auth = AuthState(backend.client);
    await auth.login('owner', validPassword);

    await auth.logout();

    expect(auth.isLoggedIn, isFalse);
    expect(backend.lastRequestTo('/api/v1/auth/logout/'), isNotNull);
  });

  test('logout tetap membersihkan token walau server menolak', () async {
    final backend = FakeBackend();
    final auth = AuthState(backend.client, initialToken: 'kedaluwarsa');
    var notified = 0;
    auth.addListener(() => notified++);

    await auth.logout();

    expect(auth.isLoggedIn, isFalse);
    expect(notified, 1);
  });

  test('logout saat belum login tidak melakukan apa-apa', () async {
    final backend = FakeBackend();
    final auth = AuthState(backend.client);

    await auth.logout();

    expect(backend.requests, isEmpty);
  });
}
