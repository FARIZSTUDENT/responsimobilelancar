// ============================================================
// services/api_service.dart  -  PANGGIL API (HTTP GET)
// ============================================================
// Dua fungsi:
//   fetchList   -> ambil banyak data   (halaman list)
//   fetchDetail -> ambil 1 data via id (halaman detail)
//
// [RECREATE] Yang diganti:
//   - _base  : URL dasar API tema barumu
//   - struktur JSON: di API ini list dibungkus key 'results'.
//     Jika API-mu langsung berupa array / key lain (mis. 'data',
//     'meals'), ubah bagian `json['results']`.
//   - format URL detail ('$_base/$type/$id/') sesuaikan dokumentasi API.
// ============================================================
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/article.dart';

class ApiService {
  static const _base = 'https://api.spaceflightnewsapi.net/v4';

  /// [type] = nama endpoint: 'articles' | 'blogs' | 'reports'.
  /// ?limit=50 -> minta 50 data sekaligus (default API hanya 10).
  static Future<List<Article>> fetchList(String type, {int limit = 50}) async {
    final res = await http
        .get(Uri.parse('$_base/$type/?limit=$limit'))
        .timeout(const Duration(seconds: 20)); // batas waktu tunggu
    // 200 = sukses. Selain itu lempar Exception -> ditangkap FutureBuilder.
    if (res.statusCode != 200) {
      throw Exception('Gagal memuat data (${res.statusCode})');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>; // String -> Map
    final results = json['results'] as List; // array data ada di key 'results'
    // Ubah tiap elemen JSON menjadi objek Article.
    return results
        .map((e) => Article.fromJson(e as Map<String, dynamic>, type))
        .toList();
  }

  /// Detail diakses berdasarkan id: /v4/{menu}/{id}/  (sesuai soal).
  static Future<Article> fetchDetail(String type, int id) async {
    final res = await http
        .get(Uri.parse('$_base/$type/$id/'))
        .timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) {
      throw Exception('Gagal memuat detail (${res.statusCode})');
    }
    // Detail = 1 objek langsung (bukan dibungkus 'results').
    return Article.fromJson(jsonDecode(res.body) as Map<String, dynamic>, type);
  }
}
