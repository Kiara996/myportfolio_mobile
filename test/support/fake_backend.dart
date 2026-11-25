import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

const validPassword = 'rahasia';
const validToken = 'token-owner';

/// Peta contoh satu proyek seperti balasan ProjectSerializer di Django.
Map<String, dynamic> projectJson({
  String id = '11111111-1111-1111-1111-111111111111',
  String title = 'Senja di Kota Tua',
  String? imageUrl,
  int starCount = 2,
}) => {
  'id': id,
  'title': title,
  'story': 'Memotret suasana sore di Kota Tua.',
  'camera_gear': 'Fujifilm X-T30 II',
  'capture_settings': 'f/2.0, 1/500s, ISO 200',
  'editing_software': 'lightroom',
  'editing_software_display': 'Adobe Lightroom',
  'location_taken': 'Jakarta',
  'taken_at': '2026-03-14',
  'image_url': imageUrl,
  'star_count': starCount,
  'is_starred': false,
  'starred_by_names': '',
};

/// Server Django tiruan. Semua permintaan dicatat di [requests].
class FakeBackend {
  FakeBackend({List<Map<String, dynamic>>? projects})
    : projects = projects ?? [projectJson()];

  List<Map<String, dynamic>> projects;
  final List<http.Request> requests = [];

  /// Kalau diisi, GET daftar proyek gagal dengan status ini.
  int? listStatus;

  /// Kalau diisi, POST proyek dibalas dengan status ini.
  int? createStatus;

  /// Kalau diisi, GET daftar proyek menunggu sampai gate ini selesai.
  Completer<void>? gate;

  /// Token yang dianggap sah oleh server.
  String acceptedToken = validToken;

  late final ApiClient client = ApiClient(
    client: MockClient(_handle),
    baseUrl: 'http://test',
  );

  http.Request? lastRequestTo(String path, {String method = 'POST'}) {
    for (final request in requests.reversed) {
      if (request.url.path == path && request.method == method) return request;
    }
    return null;
  }

  Future<http.Response> _handle(http.Request request) async {
    requests.add(request);
    final path = request.url.path;

    if (path == '/api/v1/projects/' && request.method == 'GET') {
      await gate?.future;
      if (listStatus != null) return http.Response('error', listStatus!);
      return _json(projects);
    }

    if (path == '/api/v1/auth/token/') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      if (body['password'] == validPassword) {
        return _json({'token': acceptedToken});
      }
      return _json({
        'non_field_errors': ['Unable to log in with provided credentials.'],
      }, 400);
    }

    if (path == '/api/v1/auth/logout/') {
      return request.headers['Authorization'] == 'Token $acceptedToken'
          ? http.Response('', 204)
          : http.Response('', 401);
    }

    if (path == '/api/v1/projects/' && request.method == 'POST') {
      if (request.headers['Authorization'] != 'Token $acceptedToken') {
        return http.Response('', 401);
      }
      if (createStatus != null) return http.Response('', createStatus!);
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      return _json({
        ...projectJson(title: body['title'] as String),
        ...body,
      }, 201);
    }

    return http.Response('not found', 404);
  }

  // Tanpa charset, sama seperti balasan DRF.
  http.Response _json(Object body, [int status = 200]) => http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    status,
    headers: {'content-type': 'application/json'},
  );
}

Future<void> pumpApp(
  WidgetTester tester,
  FakeBackend backend, {
  Size size = const Size(400, 900),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MyApp(apiClient: backend.client));
}

AuthState authOf(WidgetTester tester) =>
    tester.element(find.byType(Scaffold).first).read<AuthState>();

/// Login langsung lewat AuthState tanpa melewati layar login.
Future<void> signIn(WidgetTester tester) async {
  await authOf(tester).login('owner', validPassword);
  await tester.pumpAndSettle();
}
