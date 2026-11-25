import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/config.dart';
import 'package:myportofolio_mobile/models/project.dart';

/// Dilempar saat server membalas dengan status di luar 2xx.
class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  /// Pesan ramah pengguna. Body mentah tidak ditampilkan karena bisa berisi
  /// halaman error HTML atau stack trace saat DEBUG Django menyala.
  String get userMessage {
    switch (statusCode) {
      case 400:
        return 'Data yang dikirim ditolak server, periksa lagi isiannya.';
      case 401:
        return 'Sesi login tidak valid, silakan login lagi.';
      case 403:
        return 'Akun ini tidak punya izin untuk aksi tersebut.';
      case 404:
        return 'Data yang diminta tidak ditemukan.';
      default:
        return statusCode >= 500
            ? 'Server sedang bermasalah (kode $statusCode).'
            : 'Permintaan gagal (kode $statusCode).';
    }
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Teks error untuk ditampilkan ke pengguna, termasuk saat server tak terjangkau.
String describeError(Object error) => error is ApiException
    ? error.userMessage
    : 'Tidak dapat terhubung ke server.';

/// Klien HTTP untuk backend Django REST Framework MyPortfolio.
class ApiClient {
  ApiClient({http.Client? client, this.baseUrl = apiBaseUrl})
    : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<List<Project>> getProjects() async {
    final response = await _client.get(
      _uri('/api/v1/projects/'),
      headers: const {'Accept': 'application/json'},
    );
    _ensureSuccess(response);

    final decoded = _decode(response) as List<dynamic>;
    return decoded
        .map((item) => Project.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Project> createProject(
    Project project, {
    required String token,
  }) async {
    final response = await _client.post(
      _uri('/api/v1/projects/'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $token',
      },
      body: jsonEncode(project.toJson()),
    );
    _ensureSuccess(response);

    return Project.fromJson(_decode(response) as Map<String, dynamic>);
  }

  Future<String> obtainToken(String username, String password) async {
    final response = await _client.post(
      _uri('/api/v1/auth/token/'),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'username': username, 'password': password}),
    );
    _ensureSuccess(response);

    final decoded = _decode(response) as Map<String, dynamic>;
    return decoded['token'] as String;
  }

  Future<void> logout({required String token}) async {
    final response = await _client.post(
      _uri('/api/v1/auth/logout/'),
      headers: {'Authorization': 'Token $token'},
    );
    _ensureSuccess(response);
  }

  // DRF tidak mengirim charset, sedangkan response.body membaca latin1
  // kalau charset kosong. Bytes-nya didekode manual sebagai UTF-8.
  dynamic _decode(http.Response response) =>
      jsonDecode(utf8.decode(response.bodyBytes));

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    throw ApiException(response.statusCode, response.body);
  }
}
