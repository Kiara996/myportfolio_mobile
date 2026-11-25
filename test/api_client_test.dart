import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

import 'support/fake_backend.dart';

const _project = Project(
  title: 'Judul',
  story: 'Cerita',
  cameraGear: 'Kamera',
  captureSettings: 'f/8',
);

void main() {
  group('getProjects', () {
    test('mengurai daftar dan membaca UTF-8 walau tanpa charset', () async {
      final backend = FakeBackend(
        projects: [projectJson(title: 'Kopi – Pagi ☕ Café')],
      );

      final projects = await backend.client.getProjects();

      expect(projects, hasLength(1));
      expect(projects.single.title, 'Kopi – Pagi ☕ Café');
      final request = backend.requests.single;
      expect(request.url.toString(), 'http://test/api/v1/projects/');
      expect(request.headers['Accept'], 'application/json');
    });

    test('status non-2xx melempar ApiException', () async {
      final backend = FakeBackend()..listStatus = 500;

      await expectLater(
        backend.client.getProjects(),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });
  });

  group('createProject', () {
    test('mengirim JSON dengan header Authorization', () async {
      final backend = FakeBackend();

      final created = await backend.client.createProject(
        _project,
        token: validToken,
      );

      final request = backend.lastRequestTo('/api/v1/projects/')!;
      expect(request.headers['Authorization'], 'Token $validToken');
      expect(request.headers['Content-Type'], contains('application/json'));
      expect(jsonDecode(request.body), containsPair('title', 'Judul'));
      expect(created.title, 'Judul');
      expect(created.id, isNotNull);
    });

    test('token salah melempar ApiException 401', () async {
      final backend = FakeBackend();

      await expectLater(
        backend.client.createProject(_project, token: 'salah'),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });
  });

  group('obtainToken dan logout', () {
    test('obtainToken mengembalikan token dari server', () async {
      final backend = FakeBackend();

      final token = await backend.client.obtainToken('owner', validPassword);

      expect(token, validToken);
      final body = jsonDecode(
        backend.lastRequestTo('/api/v1/auth/token/')!.body,
      ) as Map<String, dynamic>;
      expect(body, {'username': 'owner', 'password': validPassword});
    });

    test('kredensial salah melempar ApiException 400', () async {
      final backend = FakeBackend();

      await expectLater(
        backend.client.obtainToken('owner', 'salah'),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 400),
        ),
      );
    });

    test('logout mengirim token dan menerima 204', () async {
      final backend = FakeBackend();

      await backend.client.logout(token: validToken);

      final request = backend.lastRequestTo('/api/v1/auth/logout/')!;
      expect(request.headers['Authorization'], 'Token $validToken');
    });
  });

  group('pesan error', () {
    test('userMessage tidak membocorkan body mentah', () {
      const error = ApiException(500, '<html>Traceback (most recent call)');

      expect(error.userMessage, isNot(contains('Traceback')));
      expect(error.userMessage, contains('500'));
    });

    test('describeError membedakan error server dan jaringan', () {
      expect(
        describeError(const ApiException(403, '')),
        'Akun ini tidak punya izin untuk aksi tersebut.',
      );
      expect(
        describeError(http.ClientException('putus')),
        'Tidak dapat terhubung ke server.',
      );
    });

    test('baseUrl bawaan mengarah ke emulator Android', () {
      final client = ApiClient(
        client: MockClient((_) async => http.Response('[]', 200)),
      );

      expect(client.baseUrl, 'http://10.0.2.2:8000');
    });
  });
}
