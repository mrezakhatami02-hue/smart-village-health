import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../models/health_facility.dart';

enum GeofenceEventType { entered, exited }

class GeofenceEvent {
  final HealthFacility facility;
  final GeofenceEventType type;
  final double distanceMeters;

  const GeofenceEvent({
    required this.facility,
    required this.type,
    required this.distanceMeters,
  });
}

class GeofenceService {
  GeofenceService({
    this.radiusInMeters = 250,
    this.hysteresisInMeters = 40,
    this.maxAccuracyInMeters = 100,
  }) {
    if (radiusInMeters <= 0) {
      throw ArgumentError.value(
        radiusInMeters,
        'radiusInMeters',
        'Radius harus lebih besar dari nol.',
      );
    }

    if (hysteresisInMeters < 0) {
      throw ArgumentError.value(
        hysteresisInMeters,
        'hysteresisInMeters',
        'Hysteresis tidak boleh negatif.',
      );
    }

    if (maxAccuracyInMeters <= 0) {
      throw ArgumentError.value(
        maxAccuracyInMeters,
        'maxAccuracyInMeters',
        'Batas akurasi harus lebih besar dari nol.',
      );
    }
  }

  // ============================================================
  // KONFIGURASI GEOFENCING
  // ============================================================

  final double radiusInMeters;

  final double hysteresisInMeters;

  final double maxAccuracyInMeters;

  // Radius keluar lebih besar daripada radius masuk.
  double get exitRadiusInMeters => radiusInMeters + hysteresisInMeters;

  // ============================================================
  // STREAM DAN STATUS
  // ============================================================

  final StreamController<GeofenceEvent> _eventController =
      StreamController<GeofenceEvent>.broadcast();

  StreamSubscription<Position>? _positionSubscription;

  // true  = pengguna berada di dalam area.
  // false = pengguna berada di luar area.
  // null  = belum memiliki status awal.
  final Map<String, bool> _insideStates = {};

  bool _isMonitoring = false;
  bool _isDisposed = false;

  Stream<GeofenceEvent> get events => _eventController.stream;

  bool get isMonitoring => _isMonitoring;

  // ============================================================
  // MEMULAI PEMANTAUAN
  // ============================================================

  Future<void> startMonitoring({
    required List<HealthFacility> facilities,
    required Stream<Position> positionStream,
  }) async {
    if (_isDisposed) {
      throw StateError(
        'GeofenceService sudah dibersihkan dan tidak dapat digunakan lagi.',
      );
    }

    // Hentikan pemantauan sebelumnya.
    await stopMonitoring();

    // Hanya fasilitas dengan koordinat valid yang dipantau.
    final monitoredFacilities = facilities
        .where((facility) => facility.hasCoordinates)
        .toList();

    if (monitoredFacilities.isEmpty) {
      throw StateError('Tidak ada fasilitas kesehatan dengan koordinat valid.');
    }

    // Bersihkan status pemantauan sebelumnya.
    _insideStates.clear();

    _isMonitoring = true;

    _positionSubscription = positionStream.listen(
      (position) {
        _checkGeofences(position, monitoredFacilities);
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!_eventController.isClosed) {
          _eventController.addError(error, stackTrace);
        }
      },
      onDone: () {
        _isMonitoring = false;
        _positionSubscription = null;
      },
    );
  }

  // ============================================================
  // VALIDASI POSISI GPS
  // ============================================================

  bool _isValidPosition(Position position) {
    // Pastikan koordinat berada dalam rentang yang benar.
    final validLatitude =
        position.latitude.isFinite &&
        position.latitude >= -90 &&
        position.latitude <= 90;

    final validLongitude =
        position.longitude.isFinite &&
        position.longitude >= -180 &&
        position.longitude <= 180;

    if (!validLatitude || !validLongitude) {
      return false;
    }

    // Pastikan nilai akurasi valid.
    if (!position.accuracy.isFinite || position.accuracy < 0) {
      return false;
    }

    // Abaikan pembacaan GPS yang terlalu tidak akurat.
    if (position.accuracy > maxAccuracyInMeters) {
      return false;
    }

    return true;
  }

  // ============================================================
  // PEMERIKSAAN AREA GEOFENCE
  // ============================================================

  void _checkGeofences(Position position, List<HealthFacility> facilities) {
    if (!_isMonitoring || !_isValidPosition(position)) {
      return;
    }

    for (final facility in facilities) {
      if (!facility.hasCoordinates) {
        continue;
      }

      // Hitung jarak pengguna ke fasilitas kesehatan.
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        facility.latitude!,
        facility.longitude!,
      );

      // Ambil status sebelumnya.
      final wasInside = _insideStates[facility.id];

      // --------------------------------------------------------
      // INISIALISASI STATUS AWAL
      // --------------------------------------------------------

      // Pembacaan GPS pertama hanya menentukan posisi awal.
      // Tidak langsung menghasilkan notifikasi ENTER.
      if (wasInside == null) {
        _insideStates[facility.id] = distance <= radiusInMeters;

        continue;
      }

      // --------------------------------------------------------
      // EVENT ENTER
      // --------------------------------------------------------

      // Pengguna sebelumnya di luar area dan sekarang masuk
      // ke radius 250 meter.
      if (!wasInside && distance <= radiusInMeters) {
        _insideStates[facility.id] = true;

        _emitEvent(
          facility: facility,
          type: GeofenceEventType.entered,
          distance: distance,
        );

        continue;
      }

      // --------------------------------------------------------
      // EVENT EXIT
      // --------------------------------------------------------

      // Pengguna sebelumnya berada di dalam area dan sekarang
      // melewati batas keluar 290 meter.
      if (wasInside && distance >= exitRadiusInMeters) {
        _insideStates[facility.id] = false;

        _emitEvent(
          facility: facility,
          type: GeofenceEventType.exited,
          distance: distance,
        );
      }

      // Di antara 250-290 meter, status sebelumnya dipertahankan.
      // Hal ini mencegah event berulang akibat perubahan GPS kecil.
    }
  }

  // ============================================================
  // MENGIRIM EVENT
  // ============================================================

  void _emitEvent({
    required HealthFacility facility,
    required GeofenceEventType type,
    required double distance,
  }) {
    if (_eventController.isClosed || !_isMonitoring) {
      return;
    }

    _eventController.add(
      GeofenceEvent(facility: facility, type: type, distanceMeters: distance),
    );
  }

  // ============================================================
  // MENGHENTIKAN PEMANTAUAN
  // ============================================================

  Future<void> stopMonitoring() async {
    _isMonitoring = false;

    await _positionSubscription?.cancel();

    _positionSubscription = null;

    _insideStates.clear();
  }

  // ============================================================
  // MEMBERSIHKAN RESOURCE
  // ============================================================

  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }

    await stopMonitoring();

    _isDisposed = true;

    await _eventController.close();
  }
}
