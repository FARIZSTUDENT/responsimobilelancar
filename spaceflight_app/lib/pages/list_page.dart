// ============================================================
// pages/list_page.dart  -  HALAMAN LIST + FILTER (soal no. 3 & 5)
// ============================================================
// Alur data:
//   1. initState  -> panggil API (simpan Future di _future)
//   2. FutureBuilder -> loading / error / sukses
//   3. Saat sukses: bentuk daftar chip dari data (news_site unik),
//      lalu tampilkan hanya item yang cocok dengan chip aktif.
//
// FILTER: cukup satu variabel state `_selectedSite`
//   null        -> tampilkan semua
//   "NASA" dst  -> tampilkan yang news_site-nya sama
//
// [RECREATE] Untuk filter berdasarkan field lain (mis. kategori),
// ganti `e.newsSite` di bagian `sites` dan `shown`.
// ============================================================
import 'package:flutter/material.dart';

import '../models/article.dart';
import '../services/api_service.dart';
import '../widgets/article_tile.dart';
import 'detail_page.dart';
import 'favorite_page.dart';

class ListPage extends StatefulWidget {
  final String type; // endpoint API: articles | blogs | reports
  final String title; // judul AppBar
  const ListPage({super.key, required this.type, required this.title});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  late Future<List<Article>> _future; // hasil panggilan API
  String? _selectedSite; // chip yang aktif (null = semua)

  @override
  void initState() {
    super.initState();
    // Panggil API SEKALI di initState (bukan di build, supaya tidak
    // terpanggil ulang setiap setState saat chip diklik).
    _future = ApiService.fetchList(widget.type);
  }

  /// Dipakai tombol "Coba lagi" saat gagal memuat.
  void _reload() {
    setState(() => _future = ApiService.fetchList(widget.type));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          // Ikon hati di AppBar -> buka halaman favorit.
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Favorite',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const FavoritePage())),
          ),
        ],
      ),
      body: FutureBuilder<List<Article>>(
        future: _future,
        builder: (context, snap) {
          // 1) Masih memuat
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2) Gagal (tidak ada internet, server error, dsb.)
          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Gagal memuat data. Periksa koneksi internet.'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                      onPressed: _reload, child: const Text('Coba lagi')),
                ],
              ),
            );
          }
          // 3) Sukses
          final all = snap.data!;
          // .toSet() menghapus duplikat -> daftar author unik untuk chip.
          final sites = all.map((e) => e.newsSite).toSet().toList()..sort();
          // Terapkan filter: semua data, atau hanya yang cocok chip aktif.
          final shown = _selectedSite == null
              ? all
              : all.where((e) => e.newsSite == _selectedSite).toList();

          return Column(
            children: [
              // ---- Baris chip filter (scroll horizontal) ----
              SizedBox(
                height: 56,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  itemCount: sites.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final site = sites[i];
                    return FilterChip(
                      label: Text(site),
                      selected: _selectedSite == site, // chip aktif ada centang
                      // sel = true saat dipilih, false saat dilepas.
                      // Dipilih -> simpan nama; dilepas -> null (semua).
                      onSelected: (sel) =>
                          setState(() => _selectedSite = sel ? site : null),
                    );
                  },
                ),
              ),
              // ---- Daftar item ----
              // Expanded: ListView butuh tinggi terbatas di dalam Column.
              Expanded(
                child: shown.isEmpty
                    ? const Center(child: Text('Tidak ada data.'))
                    : ListView.builder(
                        itemCount: shown.length,
                        // itemBuilder dipanggil per item yang terlihat (hemat memori).
                        itemBuilder: (_, i) => ArticleTile(
                          article: shown[i],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => DetailPage(initial: shown[i])),
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
