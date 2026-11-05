import 'package:flutter/material.dart';

import '../data/facility_data.dart';
import '../models/health_facility.dart';
import '../services/location_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color primaryColor = Color(0xFF1976D2);
  static const Color darkBlue = Color(0xFF123B64);
  static const Color backgroundColor = Color(0xFFF5F8FC);

  static final LocationService _locationService = LocationService();

  int get _hospitalCount => facilityData
      .where((facility) => facility.type == FacilityType.hospital)
      .length;

  int get _puskesmasCount => facilityData
      .where((facility) => facility.type == FacilityType.puskesmas)
      .length;

  int get _clinicCount => facilityData
      .where((facility) => facility.type == FacilityType.clinic)
      .length;

  int get _mappedCount =>
      facilityData.where((facility) => facility.hasCoordinates).length;

  // ============================================================
  // PENGATURAN PERANGKAT
  // ============================================================

  Future<void> _openLocationSettings(BuildContext context) async {
    try {
      await _locationService.openLocationSettings();
    } catch (_) {
      if (!context.mounted) return;

      _showMessage(context, 'Tidak dapat membuka pengaturan lokasi.');
    }
  }

  Future<void> _openAppSettings(BuildContext context) async {
    try {
      await _locationService.openAppSettings();
    } catch (_) {
      if (!context.mounted) return;

      _showMessage(context, 'Tidak dapat membuka pengaturan aplikasi.');
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  // ============================================================
  // KOMPONEN TAMPILAN
  // ============================================================

  Widget _buildSectionTitle(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: darkBlue,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 25),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: darkBlue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformationTile({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      leading: Icon(icon, color: primaryColor),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  // ============================================================
  // TENTANG APLIKASI
  // ============================================================

  void _showAboutApp(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 25, 22, 30),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const CircleAvatar(
                    radius: 34,
                    backgroundColor: Color(0xFFE3F2FD),
                    child: Icon(
                      Icons.health_and_safety,
                      size: 38,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Smart Village Health',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: darkBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Aplikasi informasi fasilitas kesehatan '
                    'yang dirancang untuk membantu masyarakat '
                    'menemukan rumah sakit, puskesmas, dan klinik '
                    'di wilayah Kecamatan Kebon Jeruk, Jakarta Barat.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, height: 1.6),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7E6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Informasi fasilitas pada aplikasi merupakan '
                      'data awal untuk demonstrasi. Alamat, nomor '
                      'telepon, jam operasional, dan layanan perlu '
                      'diverifikasi sebelum digunakan sebagai '
                      'referensi layanan kesehatan.',
                      style: TextStyle(fontSize: 11, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aplikasi demonstrasi Location Based Service '
                    'dan Geofencing.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // MAIN UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header halaman.
          const Text(
            'Profil Aplikasi',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: darkBlue,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Informasi dan pengaturan Smart Village Health',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),

          const SizedBox(height: 20),

          // Identitas aplikasi.
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.health_and_safety,
                    color: primaryColor,
                    size: 39,
                  ),
                ),
                SizedBox(height: 13),
                Text(
                  'SMART VILLAGE HEALTH',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 19,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Health Information System',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // Statistik fasilitas.
          _buildSectionTitle(
            'Data Fasilitas',
            subtitle: 'Ringkasan data yang tersedia di aplikasi',
          ),

          Row(
            children: [
              _buildMetricCard(
                title: 'Rumah Sakit',
                value: _hospitalCount,
                icon: Icons.local_hospital,
                color: Colors.red,
              ),
              const SizedBox(width: 9),
              _buildMetricCard(
                title: 'Puskesmas',
                value: _puskesmasCount,
                icon: Icons.health_and_safety,
                color: Colors.green,
              ),
              const SizedBox(width: 9),
              _buildMetricCard(
                title: 'Klinik',
                value: _clinicCount,
                icon: Icons.medical_services,
                color: Colors.orange,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.map_outlined, color: primaryColor, size: 25),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Koordinat tersedia',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '$_mappedCount dari ${facilityData.length} fasilitas dapat ditampilkan pada peta.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // Informasi cakupan wilayah.
          _buildSectionTitle('Cakupan Wilayah'),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildInformationTile(
                  icon: Icons.location_city,
                  color: primaryColor,
                  title: 'Kecamatan Kebon Jeruk',
                  description:
                      'Kota Administrasi Jakarta Barat, '
                      'Provinsi DKI Jakarta.',
                ),
                _buildInformationTile(
                  icon: Icons.local_hospital,
                  color: Colors.red,
                  title: 'Fasilitas Kesehatan',
                  description:
                      'Rumah sakit, puskesmas, dan klinik '
                      'dalam cakupan data aplikasi.',
                ),
                _buildInformationTile(
                  icon: Icons.my_location,
                  color: Colors.green,
                  title: 'Lokasi Pengguna',
                  description:
                      'Menggunakan GPS perangkat untuk '
                      'menentukan posisi dan menghitung jarak '
                      'menuju fasilitas kesehatan.',
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // Teknologi.
          _buildSectionTitle(
            'Teknologi Aplikasi',
            subtitle: 'Fitur utama yang digunakan',
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildInformationTile(
                  icon: Icons.gps_fixed,
                  color: Colors.blue,
                  title: 'Location Based Service',
                  description:
                      'Menampilkan lokasi pengguna dan '
                      'fasilitas kesehatan berdasarkan koordinat GPS.',
                ),
                _buildInformationTile(
                  icon: Icons.map,
                  color: Colors.green,
                  title: 'OpenStreetMap',
                  description:
                      'Menampilkan peta dan lokasi fasilitas '
                      'kesehatan menggunakan peta digital.',
                ),
                _buildInformationTile(
                  icon: Icons.radar,
                  color: Colors.orange,
                  title: 'Geofencing',
                  description:
                      'Memantau pengguna ketika memasuki '
                      'atau meninggalkan area fasilitas '
                      'dengan radius 250 meter saat pemantauan aktif.',
                ),
                _buildInformationTile(
                  icon: Icons.route,
                  color: Colors.purple,
                  title: 'Navigasi',
                  description:
                      'Membantu pengguna membuka petunjuk '
                      'arah menuju fasilitas kesehatan melalui Google Maps.',
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // Pengaturan perangkat.
          _buildSectionTitle('Pengaturan Perangkat'),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildSettingTile(
                  icon: Icons.location_on,
                  title: 'Pengaturan Lokasi',
                  subtitle: 'Aktifkan atau nonaktifkan GPS perangkat',
                  onTap: () => _openLocationSettings(context),
                ),
                Divider(
                  height: 1,
                  indent: 55,
                  endIndent: 15,
                  color: Colors.grey.shade200,
                ),
                _buildSettingTile(
                  icon: Icons.app_settings_alt,
                  title: 'Izin Aplikasi',
                  subtitle: 'Kelola izin lokasi Smart Village Health',
                  onTap: () => _openAppSettings(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // Tentang aplikasi.
          _buildSectionTitle('Informasi Aplikasi'),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: _buildSettingTile(
              icon: Icons.info_outline,
              title: 'Tentang Smart Village Health',
              subtitle: 'Tujuan, fungsi, dan batasan aplikasi',
              onTap: () => _showAboutApp(context),
            ),
          ),

          const SizedBox(height: 22),

          Center(
            child: Column(
              children: [
                Text(
                  'SMART VILLAGE HEALTH',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Health Information System',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 5),
                Text(
                  'Data demonstrasi untuk Kecamatan Kebon Jeruk',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),
        ],
      ),
    );
  }
}
