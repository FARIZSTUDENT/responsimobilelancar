// ============================================================
// pages/login_page.dart  -  HALAMAN LOGIN (soal no. 1)
// ============================================================
// StatefulWidget karena ada state yang berubah (_loading).
// TextEditingController = "penampung" teks yang diketik di TextField.
//
// [RECREATE] Salin apa adanya; ganti teks/judul/warna saja.
// ============================================================
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userC = TextEditingController();
  final _passC = TextEditingController();
  bool _loading = false; // true saat proses login berjalan (tombol nonaktif)

  // Controller wajib di-dispose agar tidak bocor memori.
  @override
  void dispose() {
    _userC.dispose();
    _passC.dispose();
    super.dispose();
  }

  /// Snackbar error berwarna MERAH (syarat soal).
  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  Future<void> _login() async {
    setState(() => _loading = true); // tampilkan spinner di tombol
    final ok = await AuthService.login(_userC.text, _passC.text);
    // Setelah await, pastikan halaman masih tampil sebelum pakai context.
    if (!mounted) return;
    setState(() => _loading = false);
    if (!ok) {
      _showError('Login Gagal! Pastikan sudah Register atau cek password.');
      return;
    }
    // pushReplacement: ganti halaman login dengan Home
    // (tombol back tidak kembali ke login).
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (_) => HomePage(username: _userC.text.trim())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'), centerTitle: true),
      body: Center(
        // SingleChildScrollView: agar tidak overflow saat keyboard muncul.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Silakan Login',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              TextField(
                controller: _userC,
                decoration: const InputDecoration(
                    labelText: 'Username', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _passC,
                obscureText: true, // sembunyikan password (titik-titik)
                decoration: const InputDecoration(
                    labelText: 'Password', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                // onPressed null = tombol nonaktif
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Login'),
              ),
              TextButton(
                // push: buka halaman Register (ada tombol back otomatis)
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const RegisterPage())),
                child: const Text('Belum punya akun? Daftar di sini'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
