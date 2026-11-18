# Spaceflight App (Flutter)

## Cara menjalankan
1. `flutter create .`  (jalankan di dalam folder ini agar folder android/ios dibuat; file lib/ & pubspec.yaml tetap dipakai)
2. `flutter pub get`
3. Tambahkan di `android/app/src/main/AndroidManifest.xml`:
   - sebelum `<application>`:
     `<uses-permission android:name="android.permission.INTERNET"/>`
   - setelah `<application>...</application>` (di dalam `<manifest>`):
     ```xml
     <queries>
       <intent>
         <action android:name="android.intent.action.VIEW"/>
         <data android:scheme="https"/>
       </intent>
     </queries>
     ```
4. `flutter run`

## Struktur
- lib/main.dart            : entry + cek sesi login (sharedPreferences)
- lib/pages/               : login, register, home, list (+filter chip), detail, favorite
- lib/services/            : auth, api, favorite (ChangeNotifier)
- lib/models/article.dart  : model News/Blog/Report
- lib/widgets/             : tile list dengan error handling gambar
