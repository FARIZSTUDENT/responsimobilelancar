// ============================================================
// models/article.dart  -  MODEL DATA
// ============================================================
// Model = class Dart yang mewakili 1 item data dari API (JSON).
// Satu model dipakai untuk news, blog, DAN report karena
// field-nya sama. Field "type" membedakan ketiganya.
//
// [RECREATE] Ganti nama field sesuai JSON API tema barumu:
//   1. Ubah daftar field (properti) di bawah
//   2. Ubah fromJson  (JSON -> objek)  : j['nama_field_api']
//   3. Ubah toJson    (objek -> JSON)  : untuk simpan favorit
// Tips: buka URL API di browser, lihat nama key JSON-nya.
// ============================================================
class Article {
  final int id;
  final String type; // 'articles' | 'blogs' | 'reports' (nama endpoint API)
  final String title;
  final String newsSite; // dipakai sebagai "author" & dasar filter chip
  final String summary;
  final String url; // link situs asli -> tombol "Buka Web"
  final String imageUrl;
  final String publishedAt;

  const Article({
    required this.id,
    required this.type,
    required this.title,
    required this.newsSite,
    required this.summary,
    required this.url,
    required this.imageUrl,
    required this.publishedAt,
  });

  /// Kunci unik item. Id bisa sama antar endpoint (articles id 5 dan
  /// blogs id 5), jadi digabung dengan type: "articles:5".
  /// Dipakai untuk cek "apakah item ini sudah difavoritkan".
  String get key => '$type:$id';

  /// JSON dari API -> objek Article.
  /// `?? ''` = nilai cadangan bila field null (mis. image_url kosong).
  factory Article.fromJson(Map<String, dynamic> j, String type) {
    return Article(
      id: j['id'] as int,
      type: type,
      title: (j['title'] ?? '') as String,
      newsSite: (j['news_site'] ?? 'Unknown') as String,
      summary: (j['summary'] ?? '') as String,
      url: (j['url'] ?? '') as String,
      imageUrl: (j['image_url'] ?? '') as String,
      publishedAt: (j['published_at'] ?? '') as String,
    );
  }

  /// Objek -> Map JSON, untuk disimpan ke sharedPreferences (favorit).
  /// Key-nya sengaja sama dengan JSON API supaya bisa dibaca fromJson lagi.
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'news_site': newsSite,
        'summary': summary,
        'url': url,
        'image_url': imageUrl,
        'published_at': publishedAt,
      };

  /// Membaca data favorit yang tersimpan (type ikut tersimpan di dalamnya).
  factory Article.fromStored(Map<String, dynamic> j) =>
      Article.fromJson(j, j['type'] as String);
}
