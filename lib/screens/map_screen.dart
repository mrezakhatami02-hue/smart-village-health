import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../data/facility_data.dart';
import '../models/health_facility.dart';
import '../services/geofence_service.dart';
import '../services/location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  final LocationService _locationService = LocationService();

  final GeofenceService _geofenceService = GeofenceService(radiusInMeters: 250);

  // Titik tengah awal Kecamatan Kebon Jeruk.
  static const LatLng _kebonJerukCenter = LatLng(-6.1900, 106.7700);

  // Data posisi GPS pengguna.
  Position? _currentPosition;

  bool _isLoadingLocation = true;
  bool _isMapReady = false;

  // Zoom terakhir untuk memperbarui pengelompokan marker.
  double? _lastMarkerZoom;

  String? _locationError;

  // Status Geofencing.
  bool _isGeofencingEnabled = false;
  bool _isGeofencingBusy = false;

  // Subscription untuk pemantauan GPS dan Geofencing.
  StreamSubscription<GeofenceEvent>? _geofenceEventSubscription;

  StreamSubscription<Position>? _mapPositionSubscription;

  // ==========================================
  // GEOFENCE NOTIFICATION QUEUE
  // ==========================================

  bool _isShowingGeofenceDialog = false;

  final List<GeofenceEvent> _pendingGeofenceEvents = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  // ============================================================
  // 1. LOCATION SERVICE
  // ============================================================

  Future<void> _loadCurrentLocation() async {
    if (!mounted) return;

    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      final position = await _locationService.getCurrentLocation();

      if (!mounted) return;

      setState(() {
        _currentPosition = position;
      });

      if (_isMapReady) {
        _moveToCurrentLocation(position);
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _locationError = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  void _handleMapReady() {
    if (!mounted) return;

    setState(() {
      _isMapReady = true;
      _lastMarkerZoom = _mapController.camera.zoom;
    });

    final position = _currentPosition;

    if (position != null) {
      _moveToCurrentLocation(position);
    }
  }

  // Perbarui pengelompokan marker hanya ketika tingkat zoom berubah.
  // Pergerakan/pan biasa tidak perlu menghitung ulang cluster.
  void _handleMapPositionChanged(
      MapCamera camera,
      bool hasGesture,
      ) {
    if (!mounted || !_isMapReady) return;

    final currentZoom = camera.zoom;
    final previousZoom = _lastMarkerZoom;

    if (previousZoom == null ||
        (currentZoom - previousZoom).abs() >= 0.25) {
      _lastMarkerZoom = currentZoom;
      setState(() {});
    }
  }

  void _moveToCurrentLocation(Position position) {
    _mapController.move(LatLng(position.latitude, position.longitude), 15);
  }

  // Mengubah tingkat zoom dengan tetap mempertahankan pusat peta.
  void _changeZoom(double delta) {
    if (!_isMapReady) return;

    final camera = _mapController.camera;
    final nextZoom = (camera.zoom + delta).clamp(10.0, 18.0).toDouble();

    if (nextZoom == camera.zoom) return;

    _mapController.move(camera.center, nextZoom);
  }

  Widget _buildZoomControls() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Perbesar peta',
            onPressed: _isMapReady ? () => _changeZoom(1) : null,
            icon: const Icon(Icons.add),
          ),
          Divider(
            height: 1,
            indent: 8,
            endIndent: 8,
            color: Colors.grey.shade300,
          ),
          IconButton(
            tooltip: 'Perkecil peta',
            onPressed: _isMapReady ? () => _changeZoom(-1) : null,
            icon: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }

  // Lingkaran 250 meter ditampilkan ketika pemantauan aktif.
  List<CircleMarker> _buildGeofenceCircles() {
    if (!_isGeofencingEnabled) return [];

    return facilityData
        .where((facility) => facility.hasCoordinates)
        .map(
          (facility) => CircleMarker(
        point: LatLng(facility.latitude!, facility.longitude!),
        radius: _geofenceService.radiusInMeters,
        useRadiusInMeter: true,
        color: const Color(0xFF1976D2).withValues(alpha: 0.10),
        borderColor: const Color(0xFF1976D2).withValues(alpha: 0.65),
        borderStrokeWidth: 1.5,
      ),
    )
        .toList();
  }

  // ============================================================
  // 2. GEOFENCING SERVICE
  // ============================================================

  Future<void> _toggleGeofencing(bool enabled) async {
    if (_isGeofencingBusy || !mounted) return;

    setState(() {
      _isGeofencingBusy = true;
    });

    try {
      if (enabled) {
        // Memastikan GPS dan izin lokasi tersedia.
        final initialPosition = await _locationService.getCurrentLocation();

        if (!mounted) return;

        setState(() {
          _currentPosition = initialPosition;
          _locationError = null;
        });

        // Mendengarkan event masuk dan keluar geofence.
        await _geofenceEventSubscription?.cancel();

        _geofenceEventSubscription = _geofenceService.events.listen(
          _handleGeofenceEvent,
          onError: (Object error) {
            _showGeofenceMessage(
              'Terjadi masalah saat memantau lokasi: $error',
            );
          },
        );

        // Membuat satu stream GPS yang dapat digunakan
        // oleh marker peta dan GeofenceService.
        final positionStream = _locationService
            .watchPosition()
            .asBroadcastStream();

        // Memperbarui marker lokasi pengguna.
        _mapPositionSubscription = positionStream.listen(
              (position) {
            if (!mounted) return;

            setState(() {
              _currentPosition = position;
            });
          },
          onError: (Object error) {
            _showGeofenceMessage('Gagal memperbarui posisi GPS: $error');
          },
        );

        // Memulai pemantauan area fasilitas kesehatan.
        await _geofenceService.startMonitoring(
          facilities: facilityData,
          positionStream: positionStream,
        );

        if (!mounted) return;

        setState(() {
          _isGeofencingEnabled = true;
        });

        _showGeofenceMessage('Geofencing aktif. Radius pemantauan 250 meter.');
      } else {
        // Menghentikan pemantauan Geofencing.
        await _geofenceService.stopMonitoring();

        // Menghentikan stream GPS.
        await _mapPositionSubscription?.cancel();
        _mapPositionSubscription = null;

        // Menghentikan pendengar event.
        await _geofenceEventSubscription?.cancel();
        _geofenceEventSubscription = null;

        if (!mounted) return;

        setState(() {
          _isGeofencingEnabled = false;
        });

        _showGeofenceMessage('Geofencing berhasil dinonaktifkan.');
      }
    } catch (error) {
      // Membersihkan subscription jika proses gagal.
      await _geofenceService.stopMonitoring();

      await _mapPositionSubscription?.cancel();
      _mapPositionSubscription = null;

      await _geofenceEventSubscription?.cancel();
      _geofenceEventSubscription = null;

      if (!mounted) return;

      setState(() {
        _isGeofencingEnabled = false;
      });

      _showGeofenceMessage(
        enabled
            ? 'Geofencing gagal diaktifkan: $error'
            : 'Geofencing gagal dihentikan: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGeofencingBusy = false;
        });
      }
    }
  }


  // ==========================================
  // HANDLE GEOFENCE EVENT
  // ==========================================

  void _handleGeofenceEvent(GeofenceEvent event) {
    if (!mounted) return;

    _pendingGeofenceEvents.add(event);

    if (!_isShowingGeofenceDialog) {
      unawaited(_showNextGeofenceEvent());
    }
  }

  // ==========================================
  // GEOFENCE NOTIFICATION BOTTOM SHEET
  // ==========================================

  Future<void> _showNextGeofenceEvent() async {
    if (!mounted ||
        _isShowingGeofenceDialog ||
        _pendingGeofenceEvents.isEmpty) {
      return;
    }

    _isShowingGeofenceDialog = true;

    final event = _pendingGeofenceEvents.removeAt(0);

    final isEntering = event.type == GeofenceEventType.entered;

    final Color eventColor =
    isEntering ? Colors.green : Colors.orange;

    final IconData eventIcon =
    isEntering ? Icons.location_on : Icons.location_off;

    final String title = isEntering
        ? 'Anda Memasuki Area Geofencing'
        : 'Anda Meninggalkan Area Geofencing';

    final String description = isEntering
        ? 'Selamat! Anda telah memasuki area fasilitas kesehatan.'
        : 'Anda telah keluar dari area pemantauan fasilitas kesehatan.';

    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25),
          ),
        ),
        builder: (sheetContext) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // HANDLE
                  Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // EVENT ICON
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: eventColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      eventIcon,
                      size: 42,
                      color: eventColor,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // TITLE
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF123B64),
                    ),
                  ),

                  const SizedBox(height: 9),

                  // DESCRIPTION
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // FACILITY INFORMATION
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F7FC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi Fasilitas Kesehatan',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),

                        const SizedBox(height: 9),

                        Text(
                          event.facility.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF123B64),
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          event.facility.address,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Icon(
                              Icons.near_me,
                              size: 17,
                              color: eventColor,
                            ),

                            const SizedBox(width: 7),

                            Text(
                              'Jarak: '
                                  '${event.distanceMeters.round()} meter',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: eventColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // VIEW LOCATION BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: () {
                        if (_isMapReady &&
                            event.facility.hasCoordinates) {
                          _mapController.move(
                            LatLng(
                              event.facility.latitude!,
                              event.facility.longitude!,
                            ),
                            16,
                          );
                        }

                        Navigator.pop(sheetContext);
                      },
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Lihat Lokasi'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 9),

                  // CLOSE BUTTON
                  TextButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                    },
                    child: const Text('Tutup'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } finally {
      _isShowingGeofenceDialog = false;

      // Menampilkan event berikutnya jika masih ada antrean.
      if (mounted && _pendingGeofenceEvents.isNotEmpty) {
        unawaited(_showNextGeofenceEvent());
      }
    }
  }


  // Menampilkan notifikasi di dalam aplikasi.
  void _showGeofenceMessage(String message) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
  }

  // ============================================================
  // 3. MAP MARKERS
  // ============================================================

  // ============================================================
  // 3. MAP MARKERS DAN CLUSTERING
  // ============================================================

  // Mengelompokkan fasilitas yang terlalu berdekatan di layar.
  // Posisi dihitung dalam proyeksi peta pada zoom saat ini.
  List<List<HealthFacility>> _buildFacilityClusters() {
    final facilities = facilityData
        .where((facility) => facility.hasCoordinates)
        .toList();

    if (!_isMapReady || facilities.length < 2) {
      return facilities.map((facility) => [facility]).toList();
    }

    final camera = _mapController.camera;

    final projectedPoints = facilities.map((facility) {
      return camera.projectAtZoom(
        LatLng(
          facility.latitude!,
          facility.longitude!,
        ),
        camera.zoom,
      );
    }).toList();

    // Jarak dalam logical pixel. Marker lebih dekat dari nilai ini
    // digabung hanya saat benar-benar rapat/berpotensi saling menutupi.
    const double clusterDistance = 42.0;

    final visited = List<bool>.filled(facilities.length, false);
    final clusters = <List<HealthFacility>>[];

    for (int i = 0; i < facilities.length; i++) {
      if (visited[i]) continue;

      visited[i] = true;
      final group = <HealthFacility>[facilities[i]];

      // Gunakan fasilitas pertama sebagai titik acuan kelompok.
      // Ini mencegah penggabungan berantai yang terlalu luas.
      for (int j = i + 1; j < facilities.length; j++) {
        if (visited[j]) continue;

        final screenDistance =
            (projectedPoints[i] - projectedPoints[j]).distance;

        if (screenDistance <= clusterDistance) {
          visited[j] = true;
          group.add(facilities[j]);
        }
      }

      clusters.add(group);
    }

    return clusters;
  }

  // Menghitung titik tengah kelompok dalam proyeksi peta.
  LatLng _getClusterCenter(List<HealthFacility> facilities) {
    final camera = _mapController.camera;

    double totalX = 0;
    double totalY = 0;

    for (final facility in facilities) {
      final projected = camera.projectAtZoom(
        LatLng(
          facility.latitude!,
          facility.longitude!,
        ),
        camera.zoom,
      );

      totalX += projected.dx;
      totalY += projected.dy;
    }

    final center = Offset(
      totalX / facilities.length,
      totalY / facilities.length,
    );

    return camera.unprojectAtZoom(center, camera.zoom);
  }

  // Marker fasilitas tunggal dengan area sentuh lebih besar.
  Widget _buildSingleFacilityMarker(HealthFacility facility) {
    final color = _getFacilityColor(facility.type);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showFacilityInfo(facility),
      child: SizedBox(
        width: 60,
        height: 60,
        child: Center(
          child: Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: color,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              _getFacilityIcon(facility.type),
              color: color,
              size: 29,
            ),
          ),
        ),
      ),
    );
  }

  // Marker kelompok menampilkan jumlah fasilitas yang berdekatan.
  Widget _buildClusterMarker(List<HealthFacility> facilities) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showClusterFacilities(facilities),
      child: SizedBox(
        width: 60,
        height: 60,
        child: Center(
          child: Container(
            width: 49,
            height: 49,
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.24),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${facilities.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'lokasi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Ketika cluster ditekan, pengguna memilih fasilitas tertentu.
  Future<void> _showClusterFacilities(
      List<HealthFacility> facilities,
      ) async {
    final selectedFacility = await showModalBottomSheet<HealthFacility>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  'Pilih Fasilitas Kesehatan',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF123B64),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  '${facilities.length} fasilitas berada pada '
                      'lokasi yang berdekatan.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 15),

                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight:
                    MediaQuery.of(sheetContext).size.height * 0.50,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: facilities.length,
                    separatorBuilder: (_, _) =>
                    const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final facility = facilities[index];
                      final color = _getFacilityColor(facility.type);

                      return Material(
                        color: const Color(0xFFF5F8FC),
                        borderRadius: BorderRadius.circular(14),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                            color.withValues(alpha: 0.12),
                            child: Icon(
                              _getFacilityIcon(facility.type),
                              color: color,
                            ),
                          ),
                          title: Text(
                            facility.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${facility.type.label} • '
                                '${facility.kelurahan}',
                            style: const TextStyle(fontSize: 11),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                          ),
                          onTap: () {
                            Navigator.of(sheetContext).pop(facility);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedFacility != null && mounted) {
      _showFacilityInfo(selectedFacility);
    }
  }

  // Bangun seluruh marker fasilitas dan posisi pengguna.
  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    // 1. Marker lokasi pengguna ditambahkan terlebih dahulu.
    // IgnorePointer memastikan marker GPS tidak menghalangi klik
    // marker fasilitas jika kedua posisi sangat berdekatan.
    if (_currentPosition != null) {
      markers.add(
        Marker(
          key: const ValueKey('user_location_marker'),
          point: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          width: 44,
          height: 44,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // 2. Marker fasilitas. Fasilitas yang berdekatan akan
    // digabung menjadi satu marker cluster yang dapat dipilih.
    final clusters = _buildFacilityClusters();

    for (final group in clusters) {
      final isCluster = group.length > 1;

      final markerPoint = isCluster
          ? _getClusterCenter(group)
          : LatLng(
        group.first.latitude!,
        group.first.longitude!,
      );

      markers.add(
        Marker(
          key: ValueKey(
            'facility_${group.map((facility) => facility.id).join("_")}',
          ),
          point: markerPoint,
          width: 60,
          height: 60,
          alignment: Alignment.center,
          child: isCluster
              ? _buildClusterMarker(group)
              : _buildSingleFacilityMarker(group.first),
        ),
      );
    }

    return markers;
  }

  IconData _getFacilityIcon(FacilityType type) {
    switch (type) {
      case FacilityType.hospital:
        return Icons.local_hospital;

      case FacilityType.puskesmas:
        return Icons.health_and_safety;

      case FacilityType.clinic:
        return Icons.medical_services;
    }
  }

  Color _getFacilityColor(FacilityType type) {
    switch (type) {
      case FacilityType.hospital:
        return Colors.red;

      case FacilityType.puskesmas:
        return Colors.green;

      case FacilityType.clinic:
        return Colors.orange;
    }
  }

  // ============================================================
  // 4. FACILITY INFORMATION
  // ============================================================

  void _showFacilityInfo(HealthFacility facility) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: _getFacilityColor(facility.type)
                            .withValues(alpha: 0.12),
                        child: Icon(
                          _getFacilityIcon(facility.type),
                          color: _getFacilityColor(facility.type),
                          size: 27,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              facility.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              facility.type.label,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  _infoRow(
                    Icons.location_on_outlined,
                    'Alamat',
                    facility.address,
                  ),

                  const SizedBox(height: 14),

                  _infoRow(Icons.map_outlined, 'Kelurahan', facility.kelurahan),

                  const SizedBox(height: 14),

                  _infoRow(
                    Icons.access_time,
                    'Jam Operasional',
                    facility.openingHours,
                  ),

                  if (facility.phone != null) ...[
                    const SizedBox(height: 14),

                    _infoRow(Icons.phone_outlined, 'Telepon', facility.phone!),
                  ],

                  if (facility.services.isNotEmpty) ...[
                    const SizedBox(height: 20),

                    const Text(
                      'Layanan Kesehatan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: facility.services.map((service) {
                        return Chip(
                          label: Text(service),
                          backgroundColor: Colors.blue.shade50,
                          side: BorderSide.none,
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue, size: 21),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 5. MAP LEGEND
  // ============================================================

  Widget _buildMapLegend() {
    return Card(
      elevation: 3,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _legendItem(Colors.red, 'Rumah Sakit'),

            const SizedBox(height: 7),

            _legendItem(Colors.green, 'Puskesmas'),

            const SizedBox(height: 7),

            _legendItem(Colors.orange, 'Klinik'),

            const SizedBox(height: 7),

            _legendItem(Colors.blue, 'Lokasi Saya'),
            if (_isGeofencingEnabled) ...[
              const SizedBox(height: 7),
              _legendItem(
                Colors.blue,
                'Radius 250 m',
                icon: Icons.radio_button_unchecked,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _legendItem(
      Color color,
      String label, {
        IconData icon = Icons.location_on,
      }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),

        const SizedBox(width: 6),

        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  // ============================================================
  // 6. GEOFENCING CONTROL
  // ============================================================

  Widget _buildGeofencingControl() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.radar,
            color: _isGeofencingEnabled ? Colors.green : Colors.blue,
            size: 24,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Geofencing',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),

                Text(
                  _isGeofencingEnabled
                      ? 'Aktif - Radius 250 meter'
                      : 'Nonaktif - Aktifkan pemantauan',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          if (_isGeofencingBusy)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Switch.adaptive(
              value: _isGeofencingEnabled,
              onChanged: _toggleGeofencing,
            ),
        ],
      ),
    );
  }

  // ============================================================
  // 7. CLEANUP
  // ============================================================

  Future<void> _cleanupGeofencing() async {
    await _geofenceService.stopMonitoring();

    await _mapPositionSubscription?.cancel();
    _mapPositionSubscription = null;

    await _geofenceEventSubscription?.cancel();
    _geofenceEventSubscription = null;

    await _geofenceService.dispose();
  }

  @override
  void dispose() {
    unawaited(_cleanupGeofencing());
    _mapController.dispose();
    super.dispose();
  }

  // ============================================================
  // 8. MAIN UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final mappedFacilityCount = facilityData
        .where((facility) => facility.hasCoordinates)
        .length;

    return SafeArea(
      top: true,
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header halaman peta.
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Peta Fasilitas Kesehatan',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 5),

                Text(
                  'Wilayah Kecamatan Kebon Jeruk, Jakarta Barat',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    const Icon(Icons.location_on, size: 17, color: Colors.blue),

                    const SizedBox(width: 5),

                    Text(
                      '$mappedFacilityCount dari ${facilityData.length} '
                          'fasilitas memiliki koordinat',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),

                if (mappedFacilityCount < facilityData.length)
                  Padding(
                    padding: const EdgeInsets.only(left: 22, top: 4),
                    child: Text(
                      '${facilityData.length - mappedFacilityCount} '
                          'fasilitas belum dapat diberi marker karena koordinat '
                          'belum diverifikasi.',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),

                // Kontrol Geofencing berada di header,
                // bukan di dalam informasi fasilitas.
                const SizedBox(height: 12),

                _buildGeofencingControl(),
              ],
            ),
          ),

          // Area peta.
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _kebonJerukCenter,
                    initialZoom: 13.5,
                    minZoom: 10,
                    maxZoom: 18,
                    onMapReady: _handleMapReady,
                    onPositionChanged: _handleMapPositionChanged,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.smart_village_health',
                    ),

                    if (_isGeofencingEnabled)
                      CircleLayer(circles: _buildGeofenceCircles()),

                    MarkerLayer(markers: _buildMarkers()),

                    const RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution('© OpenStreetMap contributors'),
                      ],
                    ),
                  ],
                ),

                // Legenda peta.
                Positioned(left: 12, top: 12, child: _buildMapLegend()),

                // Kontrol zoom dan tombol lokasi GPS.
                Positioned(
                  right: 14,
                  bottom: 22,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildZoomControls(),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        heroTag: 'my_location_map_button',
                        mini: true,
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                        onPressed: _isLoadingLocation
                            ? null
                            : _loadCurrentLocation,
                        child: _isLoadingLocation
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                            : const Icon(Icons.my_location),
                      ),
                    ],
                  ),
                ),

                // Pesan ketika GPS belum tersedia.
                if (_locationError != null)
                  Positioned(
                    left: 12,
                    right: 70,
                    bottom: 24,
                    child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          'Lokasi GPS belum tersedia. '
                              'Aktifkan GPS dan izinkan akses lokasi.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
