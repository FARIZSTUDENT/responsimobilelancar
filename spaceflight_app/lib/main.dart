// ============================================================
// main.dart  -  TITIK MASUK APLIKASI
// ============================================================
// Alur: main() -> MyApp -> SplashGate -> (HomePage | LoginPage)
//
// [RECREATE] Yang biasanya diganti saat tema beda:
//   - title & warna tema (colorSchemeSeed / appBarTheme)
//   - Selain itu file ini hampir selalu sama.
// ============================================================
import 'package:flutter/material.dart';

import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'services/auth_service.dart';

void main() {
  // Wajib dipanggil bila ada proses async (sharedPreferences) sebelum runApp.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spaceflight App',
      debugShowCheckedModeBanner: false, // hilangkan pita "debug"
      theme: ThemeData(
        useMaterial3: true,
        // Warna dasar; seluruh warna Material 3 diturunkan dari sini.
        colorSchemeSeed: const Color(0xFF5560FF),
        // Gaya AppBar global (biru, teks putih) -> berlaku di semua halaman.
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF5560FF),
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
      ),
      home: const SplashGate(),
    );
  }
}

/// "Gerbang" awal: cek apakah user sudah pernah login (data di
/// sharedPreferences). Jika ya -> langsung ke Home, jika belum -> Login.
/// Inilah yang memenuhi syarat "keluar tanpa logout tetap bisa masuk lagi".
class SplashGate extends StatelessWidget {
  const SplashGate({super.key});

  @override
  Widget build(BuildContext context) {
    // FutureBuilder = widget yang menunggu hasil proses async (Future).
    return FutureBuilder<String?>(
      future: AuthService.currentUser(), // baca username yang tersimpan
      builder: (context, snap) {
        // Selama masih membaca -> tampilkan loading.
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final user = snap.data; // null kalau belum login
        if (user != null) return HomePage(username: user);
        return const LoginPage();
      },
    );
  }
}
