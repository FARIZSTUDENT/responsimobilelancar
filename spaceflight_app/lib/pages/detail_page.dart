// ============================================================
// pages/detail_page.dart  -  HALAMAN DETIL (soal no. 6 + favorit)
// ============================================================
// Fitur:
//   - Ambil detail dari API berdasarkan id (ApiService.fetchDetail)
//   - Tampilkan gambar, judul, author, tanggal publish, summary
//   - Ikon hati di AppBar -> tambah/hapus favorit (+ snackbar)
//   - FloatingActionButton "Buka Web" -> launch URL situs asli
//
// Data `initial` (dari list) dipakai sebagai CADANGAN: kalau API detail
// gagal, halaman tetap menampilkan data dari list.
//
// [RECREATE] Ubah field yang ditampilkan di bagian body.
// Pastikan AndroidManifest punya <queries> agar launchUrl jalan.
// ============================================================
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/article.dart';
import '../services/api_service.dart';
import '../services/favorite_service.dart';

class DetailPage extends StatefulWidget {
  final Article initial;
  const DetailPage({super.key, required this.initial});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<Article> _future;

  @override
  void initState() {
    super.initState();
    // Detail diakses berdasarkan id (sesuai soal).
    _future = ApiService.fetchDetail(widget.initial.type, widget.initial.id);
  }

  /// Toggle favorit lalu tampilkan snackbar sesuai hasilnya.
  Future<void> _toggleFav(Article a) async {
    final added = await FavoriteService.instance.toggle(a);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar() // hindari snackbar menumpuk bila diklik cepat
      ..showSnackBar(SnackBar(
        content: Text(added ? 'Ditambahkan ke favorite' : 'Dihapus dari favorite'),
      ));
  }

  /// Buka URL di browser eksternal (launch url).
  Future<void> _openWeb(String url) async {
    final ok = await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Tidak dapat membuka situs.'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Article>(
      future: _future,
      builder: (context, snap) {
        final loading = snap.connectionState != ConnectionState.done;
        // Pakai data API bila ada; kalau belum/gagal pakai data dari list.
        final a = snap.data ?? widget.initial;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detail'),
            actions: [
              // ListenableBuilder: ikon hati berubah (kosong/merah) otomatis
              // setiap FavoriteService memanggil notifyListeners().
              ListenableBuilder(
                listenable: FavoriteService.instance,
                builder: (_, __) {
                  final fav = FavoriteService.instance.isFavorite(a);
                  return IconButton(
                    tooltip: 'Favorite',
                    icon: Icon(fav ? Icons.favorite : Icons.favorite_border,
                        color: fav ? Colors.red : Colors.white),
                    onPressed: () => _toggleFav(a),
                  );
                },
              ),
            ],
          ),
          // Tombol melayang "Buka Web"; tooltip muncul saat ditekan lama.
          floatingActionButton: FloatingActionButton(
            tooltip: 'Buka Web',
            onPressed: a.url.isEmpty ? null : () => _openWeb(a.url),
            child: const Icon(Icons.open_in_new),
          ),
          body: Column(
            children: [
              // Garis loading tipis di atas saat detail masih diambil.
              if (loading) const LinearProgressIndicator(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---- Gambar (wajib) rasio 16:9, ada penanganan error ----
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: a.imageUrl.isEmpty
                            ? const Center(
                                child: Icon(Icons.broken_image_outlined,
                                    size: 48))
                            : Image.network(
                                a.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(Icons.broken_image_outlined,
                                        size: 48)),
                              ),
                      ),
                      // bottom 96 = ruang agar teks tidak tertutup tombol FAB
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Judul (wajib)
                            Text(a.title,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            // Author (wajib)
                            Text(a.newsSite,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600)),
                            // Tanggal publish (wajib)
                            Text(a.publishedAt,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600)),
                            const SizedBox(height: 16),
                            // Summary (wajib, soal no. 5)
                            Text(a.summary, style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
