import 'package:flutter/foundation.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

/// Menyimpan token sesi di memori dan memberi tahu listener saat berubah.
class AuthState extends ChangeNotifier {
  AuthState(this._apiClient, {String? initialToken}) : _token = initialToken;

  final ApiClient _apiClient;
  String? _token;

  String? get token => _token;
  bool get isLoggedIn => _token != null;

  Future<void> login(String username, String password) async {
    _token = await _apiClient.obtainToken(username, password);
    notifyListeners();
  }

  /// Token lokal selalu dibuang walau permintaan ke server gagal, supaya
  /// pengguna tidak terjebak dalam sesi yang sudah tidak berlaku.
  Future<void> logout() async {
    final current = _token;
    if (current == null) return;

    try {
      await _apiClient.logout(token: current);
    } on ApiException {
      // Token sudah ditolak server, jadi cukup dibersihkan di sisi klien.
    } finally {
      _token = null;
      notifyListeners();
    }
  }
}
