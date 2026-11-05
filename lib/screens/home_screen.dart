import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'hospital_list_screen.dart';
import 'facility_detail_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import 'dart:async';
import 'favorites_screen.dart';

import '../services/favorite_service.dart';
import '../data/facility_data.dart';
import '../models/health_facility.dart';
import '../services/location_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();

  int selectedIndex = 0;

  Position? _currentPosition;
  bool _isLoadingLocation = false;
  String? _locationError;

  String _searchQuery = '';
  FacilityType? _selectedType;

  List<HealthFacility> _nearestFacilities = [];

  @override
  void initState() {
    super.initState();

    unawaited(FavoriteService.instance.initialize());

    _loadCurrentLocation();
  }

  // ==========================================
  // GPS: AMBIL LOKASI PENGGUNA
  // ==========================================

  Future<void> _loadCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      final position = await _locationService.getCurrentLocation();

      final nearest = _locationService.sortByNearest(
        userPosition: position,
        facilities: facilityData,
      );

      if (!mounted) return;

      setState(() {
        _currentPosition = position;
        _nearestFacilities = nearest;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _locationError = e.toString().replaceFirst('Exception: ', '');
        _currentPosition = null;
        _nearestFacilities = [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  // ==========================================
  // FORMAT JARAK
  // ==========================================

  String _formatDistance(double? distance) {
    if (distance == null) {
      return 'Jarak belum tersedia';
    }

    if (distance < 1000) {
      return '${distance.round()} meter';
    }

    return '${(distance / 1000).toStringAsFixed(1)} km';
  }

  // ==========================================
  // HITUNG JARAK FASILITAS
  // ==========================================

  double? _getDistance(HealthFacility facility) {
    if (_currentPosition == null || !facility.hasCoordinates) {
      return null;
    }

    return _locationService.calculateDistance(_currentPosition!, facility);
  }

  // ==========================================
  // TOGGLE FAVORIT
  // ==========================================

  Future<void> _toggleFavorite(HealthFacility facility) async {
    try {
      final added = await FavoriteService.instance.toggle(facility);

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              added
                  ? '${facility.name} ditambahkan ke Favorit.'
                  : '${facility.name} dihapus dari Favorit.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memperbarui daftar Favorit.'),
        ),
      );
    }
  }

  // ==========================================
  // HOME PAGE
  // ==========================================

  Widget _buildHome() {
    final hospitalCount = facilityData
        .where((f) => f.type == FacilityType.hospital)
        .length;

    final puskesmasCount = facilityData
        .where((f) => f.type == FacilityType.puskesmas)
        .length;

    final clinicCount = facilityData
        .where((f) => f.type == FacilityType.clinic)
        .length;

    final mappedCount = facilityData.where((f) => f.hasCoordinates).length;

    final displayedFacilities = _currentPosition != null
        ? _nearestFacilities.take(3).toList()
        : facilityData.where((f) => f.hasCoordinates).take(3).toList();

    final nearestTitle = _currentPosition != null
        ? 'Fasilitas Terdekat'
        : 'Fasilitas Tersedia';

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadCurrentLocation,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.health_and_safety,
                    color: Color(0xFF1976D2),
                    size: 30,
                  ),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SMART VILLAGE',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF123B64),
                        ),
                      ),
                      Text(
                        'Health Information System',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  onPressed: _loadCurrentLocation,
                  tooltip: 'Perbarui lokasi',
                  icon: const Icon(Icons.my_location, color: Color(0xFF1976D2)),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // ==================================================
            // WELCOME BANNER
            // ==================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(21),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selamat Datang!',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Smart Village Health',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Temukan rumah sakit, puskesmas, dan klinik '
                    'di Kecamatan Kebon Jeruk, Jakarta Barat.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        selectedIndex = 2;
                      });
                    },
                    icon: const Icon(Icons.map_outlined, size: 18),
                    label: const Text('Lihat Peta'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ==================================================
            // LOCATION STATUS
            // ==================================================
            _buildLocationCard(),

            const SizedBox(height: 24),

            // ==================================================
            // FACILITY STATISTICS
            // ==================================================
            const Text(
              'Ringkasan Fasilitas',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF123B64),
              ),
            ),

            const SizedBox(height: 5),

            Text(
              '$mappedCount dari ${facilityData.length} fasilitas '
              'memiliki koordinat untuk ditampilkan pada peta.',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 13),

            Row(
              children: [
                _buildHomeStatCard(
                  title: 'Rumah Sakit',
                  count: hospitalCount,
                  icon: Icons.local_hospital,
                  color: Colors.red,
                ),

                const SizedBox(width: 9),

                _buildHomeStatCard(
                  title: 'Puskesmas',
                  count: puskesmasCount,
                  icon: Icons.health_and_safety,
                  color: Colors.green,
                ),

                const SizedBox(width: 9),

                _buildHomeStatCard(
                  title: 'Klinik',
                  count: clinicCount,
                  icon: Icons.medical_services,
                  color: Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 25),

            // ==================================================
            // SEARCH
            // ==================================================
            const Text(
              'Cari Fasilitas Kesehatan',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF123B64),
              ),
            ),

            const SizedBox(height: 11),

            TextField(
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Cari rumah sakit, puskesmas, klinik...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Cari fasilitas',
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    setState(() {
                      _selectedType = null;
                      selectedIndex = 1;
                    });
                  },
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                _searchQuery = value;
              },
              onSubmitted: (value) {
                setState(() {
                  _searchQuery = value;
                  _selectedType = null;
                  selectedIndex = 1;
                });
              },
            ),

            const SizedBox(height: 24),

            // ==================================================
            // CATEGORY
            // ==================================================
            const Text(
              'Kategori Fasilitas',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF123B64),
              ),
            ),

            const SizedBox(height: 13),

            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.55,
              children: [
                _category(
                  'Rumah Sakit',
                  Icons.local_hospital,
                  Colors.blue,
                  FacilityType.hospital,
                ),

                _category(
                  'Puskesmas',
                  Icons.health_and_safety,
                  Colors.green,
                  FacilityType.puskesmas,
                ),

                _category(
                  'Klinik',
                  Icons.medical_services,
                  Colors.purple,
                  FacilityType.clinic,
                ),

                _category(
                  'Semua Fasilitas',
                  Icons.medical_information,
                  Colors.orange,
                  null,
                ),
              ],
            ),

            const SizedBox(height: 25),

            // ==================================================
            // NEAREST FACILITIES
            // ==================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    nearestTitle,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF123B64),
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedType = null;
                      selectedIndex = 1;
                    });
                  },
                  child: const Text('Lihat Semua'),
                ),
              ],
            ),

            const SizedBox(height: 9),

            if (displayedFacilities.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: _cardDecoration(),
                child: const Column(
                  children: [
                    Icon(
                      Icons.location_searching,
                      color: Colors.grey,
                      size: 38,
                    ),
                    SizedBox(height: 9),
                    Text(
                      'Fasilitas belum dapat ditampilkan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Periksa data koordinat atau aktifkan GPS '
                      'perangkat.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              ...displayedFacilities.map((facility) => _facilityCard(facility)),

            const SizedBox(height: 20),

            // ==================================================
            // FOOTER
            // ==================================================
            Center(
              child: Text(
                'Smart Village Health • Kecamatan Kebon Jeruk',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeStatCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 25),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF123B64),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // LOCATION CARD
  // ==========================================

  Widget _buildLocationCard() {
    if (_isLoadingLocation) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: const Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 14),
            Expanded(child: Text('Sedang mengambil lokasi GPS...')),
          ],
        ),
      );
    }

    if (_locationError != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.location_off, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Lokasi belum tersedia',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _locationError!,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                TextButton.icon(
                  onPressed: _loadCurrentLocation,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
                if (_locationError!.contains('permanen'))
                  TextButton(
                    onPressed: () {
                      _locationService.openAppSettings();
                    },
                    child: const Text('Pengaturan Izin'),
                  )
                else
                  TextButton(
                    onPressed: () {
                      _locationService.openLocationSettings();
                    },
                    child: const Text('Pengaturan GPS'),
                  ),
              ],
            ),
          ],
        ),
      );
    }

    if (_currentPosition != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on, color: Colors.green, size: 27),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lokasi Anda Terdeteksi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    'Long: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'GPS berhasil mengambil posisi perangkat.',
                    style: TextStyle(color: Colors.green, fontSize: 11),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _loadCurrentLocation,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // ==========================================
  // CATEGORY CARD
  // ==========================================

  Widget _category(
    String title,
    IconData icon,
    Color color,
    FacilityType? type,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        setState(() {
          _selectedType = type;
          selectedIndex = 1;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // FACILITY CARD
  // ==========================================


  Widget _facilityCard(HealthFacility facility) {
    final distance = _getDistance(facility);

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => FacilityDetailScreen(
                facility: facility,
                currentPosition: _currentPosition,
              ),
            ),
          );
        },

        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE3F2FD),
          child: Icon(
            facility.type == FacilityType.hospital
                ? Icons.local_hospital
                : facility.type == FacilityType.puskesmas
                ? Icons.health_and_safety
                : Icons.medical_services,
            color: Colors.blue,
          ),
        ),

        title: Text(
          facility.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),

            Text(facility.type.label),

            Text(
              facility.kelurahan,
              style: const TextStyle(fontSize: 11),
            ),

            const SizedBox(height: 5),

            Row(
              children: [
                const Icon(
                  Icons.near_me,
                  size: 14,
                  color: Colors.green,
                ),

                const SizedBox(width: 4),

                Expanded(
                  child: Text(
                    facility.hasCoordinates
                        ? _formatDistance(distance)
                        : 'Koordinat belum tersedia',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        // FAVORITE BUTTON
        trailing: AnimatedBuilder(
          animation: FavoriteService.instance,
          builder: (context, child) {
            final isFavorite =
            FavoriteService.instance.isFavorite(facility.id);

            return IconButton(
              tooltip: isFavorite
                  ? 'Hapus dari Favorit'
                  : 'Tambahkan ke Favorit',
              onPressed: () => _toggleFavorite(facility),
              icon: Icon(
                isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey,
              ),
            );
          },
        ),

        isThreeLine: true,
      ),
    );
  }

  // ==========================================
  // FACILITY LIST PAGE
  // ==========================================

  Widget _buildFacilityPage() {
    return HospitalListScreen(
      facilities: facilityData,
      currentPosition: _currentPosition,
      initialType: _selectedType,
      initialQuery: _searchQuery,

      onTypeChanged: (type) {
        if (_selectedType != type) {
          setState(() {
            _selectedType = type;
          });
        }
      },

      onSearchChanged: (query) {
        _searchQuery = query;
      },
    );
  }

  // ==========================================
  // MAP PLACEHOLDER
  // ==========================================

  Widget _buildMapPage() {
    return const MapScreen();
  }

  // ==========================================
  // PROFILE PAGE
  // ==========================================

  Widget _buildProfilePage() {
    return const ProfileScreen();
  }

  Widget _buildFavoritesPage() {
    return FavoritesScreen(
      facilities: facilityData,
      currentPosition: _currentPosition,
    );
  }

  // ==========================================
  // CARD DECORATION
  // ==========================================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  // ==========================================
  // MAIN BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: [
          _buildHome(),
          _buildFacilityPage(),
          _buildMapPage(),
          _buildFavoritesPage(),
          _buildProfilePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_hospital_outlined),
            selectedIcon: Icon(Icons.local_hospital),
            label: 'Fasilitas',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Peta',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorit',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
