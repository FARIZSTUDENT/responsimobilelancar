// ============================================================
// widgets/article_tile.dart  -  KARTU ITEM (dipakai ulang)
// ============================================================
// Satu widget dipakai di halaman LIST dan halaman FAVORIT
// (prinsip reusable widget -> tidak menulis UI yang sama 2x).
//   leading  : thumbnail gambar (dengan penanganan error)
//   title    : judul (maks 2 baris, lebih -> "...")
//   subtitle : author
//   trailing : opsional (di favorit diisi ikon hati)
// ============================================================
import 'package:flutter/material.dart';

import '../models/article.dart';

class ArticleTile extends StatelessWidget {
  final Article article;
  final VoidCallback onTap; // aksi saat kartu diklik
  final Widget? trailing; // widget opsional di sisi kanan

  const ArticleTile({
    super.key,
    required this.article,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      color: const Color(0xFFF7E8F9),
      child: ListTile(
        onTap: onTap,
        leading: _Thumb(url: article.imageUrl),
        title: Text(article.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(article.newsSite),
        trailing: trailing,
      ),
    );
  }
}

/// Thumbnail dengan EXCEPTION HANDLING gambar (syarat soal no. 3):
///   - url kosong        -> ikon broken_image
///   - gagal dimuat      -> errorBuilder -> ikon broken_image
///   - sedang loading    -> loadingBuilder -> spinner kecil
class _Thumb extends StatelessWidget {
  final String url;
  const _Thumb({required this.url});

  // Tampilan cadangan bila gambar tidak ada.
  Widget _fallback() => const SizedBox(
        width: 90,
        height: 60,
        child: Icon(Icons.broken_image_outlined),
      );

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _fallback();
    return ClipRRect(
      borderRadius: BorderRadius.circular(6), // sudut membulat
      child: Image.network(
        url,
        width: 90,
        height: 60,
        fit: BoxFit.cover, // gambar memenuhi kotak (dipotong bila perlu)
        // Dipanggil otomatis jika gambar gagal diunduh/di-decode.
        errorBuilder: (_, __, ___) => _fallback(),
        // progress == null artinya gambar sudah selesai dimuat.
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : const SizedBox(
                width: 90,
                height: 60,
                child: Center(
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))),
              ),
      ),
    );
  }
}
