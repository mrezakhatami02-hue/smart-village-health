# Smart Village Health

Aplikasi mobile berbasis Flutter untuk membantu masyarakat
menemukan informasi dan lokasi fasilitas kesehatan di
Kecamatan Kebon Jeruk, Jakarta Barat.

## Fitur Utama

- Welcome Screen
- Informasi dan pencarian fasilitas kesehatan
- Filter rumah sakit, puskesmas, dan klinik
- Detail fasilitas kesehatan
- Location Based Service (LBS)
- Peta digital OpenStreetMap
- Penghitungan jarak fasilitas menggunakan GPS
- Petunjuk arah melalui Google Maps
- Pengelolaan fasilitas Favorit
- Geofencing dengan radius ENTER 250 meter
  dan EXIT 290 meter
- Halaman Profil aplikasi

## Data Fasilitas

Total 30 fasilitas kesehatan:
- 8 Rumah Sakit
- 8 Puskesmas
- 14 Klinik

Wilayah implementasi:
Kecamatan Kebon Jeruk, Jakarta Barat, DKI Jakarta.

## Teknologi

- Flutter
- Dart
- Geolocator
- Flutter Map
- OpenStreetMap
- Latlong2
- URL Launcher
- SharedPreferences

## Cara Menjalankan Aplikasi

1. Clone repository ini.
2. Buka folder proyek di Android Studio atau VS Code.
3. Jalankan perintah:

   flutter pub get

4. Jalankan aplikasi:

   flutter run

## Catatan

Pemantauan Geofencing berjalan ketika fitur diaktifkan
dan pengguna berada pada halaman Peta. Aplikasi belum
menjalankan pemantauan lokasi sebagai layanan latar
belakang ketika ditutup.

Koordinat fasilitas perlu divalidasi lebih lanjut
melalui pemeriksaan lapangan.