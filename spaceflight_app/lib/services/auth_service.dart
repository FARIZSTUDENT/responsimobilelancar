// ============================================================
// services/auth_service.dart  -  LOGIN / REGISTER / LOGOUT
// ============================================================
// Semua data disimpan lokal pakai sharedPreferences (key-value).
// Ada 2 key:
//   'users'          -> JSON map {username: password} semua akun terdaftar
//   'logged_in_user' -> username yang sedang login (hilang saat logout)
//
// [RECREATE] File ini bisa disalin APA ADANYA ke tema apa pun.
// Method static -> dipanggil tanpa membuat objek: AuthService.login(...)
// ============================================================
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _usersKey = 'users';
  static const _loggedKey = 'logged_in_user';

  /// Baca semua akun terdaftar. Jika belum ada -> map kosong.
  static Future<Map<String, String>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey); // berupa String JSON
    if (raw == null) return {};
    return Map<String, String>.from(jsonDecode(raw) as Map);
  }

  /// REGISTER. Return null = sukses, selain itu = teks pesan error
  /// (nanti ditampilkan di snackbar merah).
  static Future<String?> register(String username, String password) async {
    username = username.trim(); // buang spasi di awal/akhir
    if (username.isEmpty || password.isEmpty) {
      return 'Username dan password wajib diisi.';
    }
    final users = await _loadUsers();
    if (users.containsKey(username)) {
      return 'Username sudah terdaftar.';
    }
    users[username] = password; // tambah akun baru
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users)); // simpan balik
    return null;
  }

  /// LOGIN. Return true bila username terdaftar & password cocok.
  /// Jika berhasil, username disimpan sebagai "sesi login".
  static Future<bool> login(String username, String password) async {
    username = username.trim();
    final users = await _loadUsers();
    if (users[username] == null || users[username] != password) return false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_loggedKey, username);
    return true;
  }

  /// Username yang sedang login (null kalau belum/sudah logout).
  static Future<String?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_loggedKey);
  }

  /// LOGOUT: hapus sesi saja. Akun terdaftar tetap ada.
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedKey);
  }
}
