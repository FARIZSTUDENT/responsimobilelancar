// ============================================================
// services/favorite_service.dart  -  STATE FAVORIT (PENTING!)
// ============================================================
// Syarat soal: daftar favorit harus ter-update dari halaman detail
// MAUPUN halaman favorit. Solusinya: satu "sumber data" bersama
// (singleton) berupa ChangeNotifier.
//
// Cara kerja:
//   - Data favorit disimpan di satu objek: FavoriteService.instance
//   - Saat berubah, panggil notifyListeners()
//   - Widget yang dibungkus ListenableBuilder(listenable: instance)
//     otomatis build ulang -> tidak perlu setState/refresh manual.
//
// Favorit disimpan PER USER dengan key 'favorites_<username>'.
//
// [RECREATE] File ini bisa disalin apa adanya selama model-nya
// punya: key, toJson(), fromStored().
// ============================================================
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/article.dart';

class FavoriteService extends ChangeNotifier {
  // Pola singleton: constructor private + satu instance statis.
  FavoriteService._();
  static final FavoriteService instance = FavoriteService._();

  final List<Article> _items = [];
  String? _username;

  /// Getter read-only supaya luar tidak bisa mengubah list langsung.
  List<Article> get items => List.unmodifiable(_items);

  String get _prefsKey => 'favorites_$_username';

  /// Dipanggil saat HomePage dibuka: muat favorit milik user ini.
  Future<void> load(String username) async {
    _username = username;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    _items.clear();
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      _items.addAll(
          list.map((e) => Article.fromStored(e as Map<String, dynamic>)));
    }
    notifyListeners(); // beri tahu UI
  }

  /// Apakah item sudah difavoritkan? (bandingkan lewat key unik)
  bool isFavorite(Article a) => _items.any((e) => e.key == a.key);

  /// Tambah jika belum ada, hapus jika sudah ada (toggle).
  /// Return true = sekarang jadi favorit, false = dihapus.
  Future<bool> toggle(Article a) async {
    final exists = isFavorite(a);
    if (exists) {
      _items.removeWhere((e) => e.key == a.key);
    } else {
      _items.insert(0, a); // taruh paling atas
    }
    notifyListeners(); // <- inilah yang membuat semua halaman ter-update
    // Simpan seluruh list ke sharedPreferences sebagai JSON.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _prefsKey, jsonEncode(_items.map((e) => e.toJson()).toList()));
    return !exists;
  }

  /// Dipanggil saat logout agar favorit user lama tidak tampil.
  void clear() {
    _items.clear();
    _username = null;
    notifyListeners();
  }
}
