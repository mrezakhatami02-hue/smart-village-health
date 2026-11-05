import 'package:geolocator/geolocator.dart';

import '../models/health_facility.dart';

class LocationService {
  /// Memastikan GPS aktif dan izin lokasi tersedia.
  Future<void> _checkLocationPermission() async {
    // 1. Periksa apakah GPS aktif.
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('GPS belum aktif. Silakan aktifkan lokasi perangkat.');
    }

    // 2. Periksa izin lokasi.
    LocationPermission permission = await Geolocator.checkPermission();

    // 3. Minta izin jika belum diberikan.
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // 4. Jika izin ditolak.
    if (permission == LocationPermission.denied) {
      throw Exception('Izin lokasi ditolak. Aplikasi membutuhkan akses GPS.');
    }

    // 5. Jika izin ditolak secara permanen.
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Izin lokasi ditolak permanen. '
        'Silakan aktifkan melalui pengaturan aplikasi.',
      );
    }

    // 6. Pastikan izin sudah diberikan.
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      throw Exception('Izin lokasi belum tersedia.');
    }
  }

  /// Mengambil posisi GPS pengguna saat ini.
  Future<Position> getCurrentLocation() async {
    await _checkLocationPermission();

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  /// Memantau perubahan posisi GPS pengguna.
  Stream<Position> watchPosition() async* {
    await _checkLocationPermission();

    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  /// Menghitung jarak pengguna ke fasilitas dalam meter.
  double? calculateDistance(Position userPosition, HealthFacility facility) {
    if (!facility.hasCoordinates) {
      return null;
    }

    return Geolocator.distanceBetween(
      userPosition.latitude,
      userPosition.longitude,
      facility.latitude!,
      facility.longitude!,
    );
  }

  /// Mengurutkan fasilitas berdasarkan jarak terdekat.
  List<HealthFacility> sortByNearest({
    required Position userPosition,
    required List<HealthFacility> facilities,
  }) {
    final result = facilities
        .where((facility) => facility.hasCoordinates)
        .toList();

    result.sort((a, b) {
      final distanceA = calculateDistance(userPosition, a)!;

      final distanceB = calculateDistance(userPosition, b)!;

      return distanceA.compareTo(distanceB);
    });

    return result;
  }

  /// Membuka pengaturan GPS perangkat.
  Future<bool> openLocationSettings() {
    return Geolocator.openLocationSettings();
  }

  /// Membuka pengaturan izin aplikasi.
  Future<bool> openAppSettings() {
    return Geolocator.openAppSettings();
  }

  /// Memeriksa status GPS.
  Future<bool> isLocationEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }
}
