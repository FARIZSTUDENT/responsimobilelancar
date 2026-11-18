// ============================================================
// pages/home_page.dart  -  HALAMAN UTAMA (soal no. 2)
// ============================================================
// Isi: AppBar "Hai, username!", 3 kartu menu, tombol Log Out.
// Tiap kartu membuka ListPage dengan parameter `type` berbeda
// (nama endpoint API) -> satu ListPage untuk 3 menu.
//
// [RECREATE] Ganti jumlah/isi menu: ubah teks, ikon, dan `type`
// pada pemanggilan _MenuCard di bawah.
// ============================================================
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/favorite_service.dart';
import 'list_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  final String username; // diterima dari halaman login / SplashGate
  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Muat favorit milik user ini begitu masuk Home.
    FavoriteService.instance.load(widget.username);
  }

  Future<void> _logout() async {
    await AuthService.logout(); // hapus sesi di sharedPreferences
    FavoriteService.instance.clear();
    if (!mounted) return;
    // pushAndRemoveUntil: pindah ke Login & hapus SEMUA halaman
    // sebelumnya dari stack (predicate `(_) => false`).
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hai, ${widget.username}!'), // AppBar tampilkan username
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MenuCard(
            icon: Icons.newspaper,
            title: 'News',
            desc:
                'Get an overview of the latest SpaceFlight news, from various sources! Easily link your users to the right websites.',
            onTap: () => _open('articles', 'News'), // 'articles' = endpoint API
          ),
          _MenuCard(
            icon: Icons.article_outlined,
            title: 'Blog',
            desc:
                'Blogs often provide a more detailed overview of launches and missions. A must-have for the serious spaceflight enthusiast.',
            onTap: () => _open('blogs', 'Blog'),
          ),
          _MenuCard(
            icon: Icons.bar_chart,
            title: 'Reports',
            desc:
                'Space stations and other missions often publish their data. With SNAPI, you can include it in your app.',
            onTap: () => _open('reports', 'Reports'),
          ),
          const SizedBox(height: 12),
          // Tombol logout di BAWAH pilihan menu (syarat soal).
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: _logout,
              child: const Text('Log Out'),
            ),
          ),
        ],
      ),
    );
  }

  /// Buka halaman list untuk endpoint [type] dengan judul AppBar [title].
  void _open(String type, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ListPage(type: type, title: title)),
    );
  }
}

/// Kartu menu (ikon + judul + deskripsi) yang bisa diklik.
class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      // InkWell = efek ripple saat disentuh + mendeteksi klik.
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.purple, size: 28),
              ),
              const SizedBox(width: 16),
              // Expanded: teks mengisi sisa lebar & turun baris otomatis.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(desc,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade700)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
