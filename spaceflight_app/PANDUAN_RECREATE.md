# Panduan Membuat Ulang dengan Tema Lain (untuk Responsi)

## Urutan pengerjaan (ikuti ini saat responsi)
1. **Buka API di browser** -> catat: URL dasar, nama endpoint, nama key JSON.
2. `pubspec.yaml` -> tambah dependency: `http`, `shared_preferences`, `url_launcher` -> `flutter pub get`
3. **models/** -> buat model sesuai key JSON (fromJson, toJson, getter key unik)
4. **services/api_service.dart** -> ganti `_base`, cek apakah list ada di key `results`/`data`/dll
5. **services/auth_service.dart** -> salin apa adanya
6. **services/favorite_service.dart** -> salin apa adanya (ganti nama model jika beda)
7. **widgets/** tile list -> sesuaikan field judul/author/gambar
8. **pages/**: login -> register -> home -> list(+filter) -> detail -> favorite
9. `main.dart` -> SplashGate (cek sesi login)
10. AndroidManifest: permission INTERNET + `<queries>` untuk url_launcher

## Peta konsep soal -> kode
| Ketentuan soal | Di mana / cara |
|---|---|
| Snackbar error merah | `SnackBar(backgroundColor: Colors.red)` |
| Login tersimpan | `AuthService.login` simpan `logged_in_user`; `SplashGate` membacanya |
| AppBar username | `Text('Hai, ${widget.username}!')` di HomePage |
| Logout di bawah menu | `ElevatedButton` merah di akhir ListView HomePage |
| Satu list untuk 3 menu | `ListPage(type: ...)` — `type` = nama endpoint |
| Gambar gagal muncul | `Image.network(errorBuilder: ...)` |
| Filter chip | `FilterChip` + state `_selectedSite` + `.where(...)` |
| Favorit sinkron | `FavoriteService` (ChangeNotifier) + `ListenableBuilder` |
| Detail by id | `ApiService.fetchDetail(type, id)` |
| Launch URL | `launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)` |

## Yang paling sering salah saat responsi
- Lupa permission INTERNET -> data tidak muncul
- Lupa `<queries>` -> launchUrl gagal di Android 11+
- Memanggil API di `build()` -> request berulang; panggil di `initState`
- Pakai `context` setelah `await` tanpa cek `if (!mounted) return;`
- Lupa `notifyListeners()` -> favorit tidak ter-update
- Id bisa sama antar endpoint -> key favorit harus `type:id`
