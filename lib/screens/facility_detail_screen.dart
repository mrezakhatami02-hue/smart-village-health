import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/health_facility.dart';
import '../services/favorite_service.dart';

class FacilityDetailScreen extends StatelessWidget {
  final HealthFacility facility;
  final Position? currentPosition;

  const FacilityDetailScreen({
    super.key,
    required this.facility,
    this.currentPosition,
  });

  Color get _facilityColor {
    switch (facility.type) {
      case FacilityType.hospital:
        return Colors.red;

      case FacilityType.puskesmas:
        return Colors.green;

      case FacilityType.clinic:
        return Colors.orange;
    }
  }

  IconData get _facilityIcon {
    switch (facility.type) {
      case FacilityType.hospital:
        return Icons.local_hospital;

      case FacilityType.puskesmas:
        return Icons.health_and_safety;

      case FacilityType.clinic:
        return Icons.medical_services;
    }
  }

  double? get _distance {
    if (currentPosition == null || !facility.hasCoordinates) {
      return null;
    }

    return Geolocator.distanceBetween(
      currentPosition!.latitude,
      currentPosition!.longitude,
      facility.latitude!,
      facility.longitude!,
    );
  }

  String _formatDistance(double? distance) {
    if (distance == null) {
      return 'Jarak belum tersedia';
    }

    if (distance < 1000) {
      return '${distance.round()} meter';
    }

    return '${(distance / 1000).toStringAsFixed(1)} km';
  }

  // ============================================================
  // TELEPON FASILITAS
  // ============================================================

  Future<void> _callFacility(BuildContext context) async {
    final phone = facility.phone?.trim();

    if (phone == null || phone.isEmpty) {
      _showMessage(context, 'Nomor telepon fasilitas belum tersedia.');
      return;
    }

    final uri = Uri(scheme: 'tel', path: phone);

    try {
      final success = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!success && context.mounted) {
        _showMessage(context, 'Tidak dapat membuka aplikasi telepon.');
      }
    } catch (_) {
      if (context.mounted) {
        _showMessage(context, 'Terjadi kesalahan saat membuka telepon.');
      }
    }
  }

  // ============================================================
  // PETUNJUK ARAH
  // ============================================================

  Future<void> _openDirections(BuildContext context) async {
    if (!facility.hasCoordinates) {
      _showMessage(context, 'Koordinat fasilitas belum tersedia.');
      return;
    }

    final parameters = <String, String>{
      'api': '1',
      'destination': '${facility.latitude},${facility.longitude}',
      'travelmode': 'driving',
    };

    if (currentPosition != null) {
      parameters['origin'] =
          '${currentPosition!.latitude},'
          '${currentPosition!.longitude}';
    }

    final uri = Uri.https('www.google.com', '/maps/dir/', parameters);

    try {
      final success = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!success && context.mounted) {
        _showMessage(context, 'Tidak dapat membuka petunjuk arah.');
      }
    } catch (_) {
      if (context.mounted) {
        _showMessage(context, 'Terjadi kesalahan saat membuka peta.');
      }
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  // ==========================================
  // TOGGLE FAVORIT
  // ==========================================

  Future<void> _toggleFavorite(BuildContext context) async {
    try {
      final added =
      await FavoriteService.instance.toggle(facility);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            added
                ? 'Ditambahkan ke Favorit.'
                : 'Dihapus dari Favorit.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memperbarui daftar Favorit.'),
        ),
      );
    }
  }

  // ============================================================
  // INFORMASI FASILITAS
  // ============================================================

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF123B64),
            ),
          ),

          const SizedBox(height: 15),

          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _facilityColor, size: 21),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 4),

                Text(
                  value.isEmpty ? 'Informasi belum tersedia' : value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceList() {
    if (facility.services.isEmpty) {
      return Text(
        'Informasi layanan belum tersedia.',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: facility.services.map((service) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: _facilityColor.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, color: _facilityColor, size: 15),

              const SizedBox(width: 6),

              Text(
                service,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // MAIN UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),

      appBar: AppBar(
        title: const Text(
          'Detail Fasilitas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF123B64),
        elevation: 0,
        actions: [
          AnimatedBuilder(
            animation: FavoriteService.instance,
            builder: (context, child) {
              final isFavorite =
              FavoriteService.instance.isFavorite(facility.id);

              return IconButton(
                tooltip: isFavorite
                    ? 'Hapus dari Favorit'
                    : 'Tambahkan ke Favorit',
                onPressed: () => _toggleFavorite(context),
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey,
                ),
              );
            },
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // Identitas fasilitas.
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: _facilityColor.withValues(alpha: 0.12),
                  child: Icon(_facilityIcon, color: _facilityColor, size: 40),
                ),

                const SizedBox(height: 15),

                Text(
                  facility.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF123B64),
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _facilityColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    facility.type.label,
                    style: TextStyle(
                      color: _facilityColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.near_me, color: Colors.green, size: 17),

                    const SizedBox(width: 6),

                    Text(
                      _formatDistance(_distance),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 17),

          // Alamat dan lokasi.
          _buildInfoCard(
            title: 'Informasi Lokasi',
            children: [
              _buildInfoRow(
                icon: Icons.location_on_outlined,
                title: 'Alamat',
                value: facility.address,
              ),

              _buildInfoRow(
                icon: Icons.map_outlined,
                title: 'Kelurahan',
                value: facility.kelurahan,
              ),

              if (facility.hasCoordinates)
                _buildInfoRow(
                  icon: Icons.my_location,
                  title: 'Koordinat',
                  value:
                      '${facility.latitude!.toStringAsFixed(6)}, '
                      '${facility.longitude!.toStringAsFixed(6)}',
                )
              else
                _buildInfoRow(
                  icon: Icons.location_disabled,
                  title: 'Koordinat',
                  value: 'Belum tersedia',
                ),

              if (facility.coordinateNote != null)
                _buildInfoRow(
                  icon: Icons.info_outline,
                  title: 'Catatan Lokasi',
                  value: facility.coordinateNote!,
                ),
            ],
          ),

          // Informasi operasional.
          _buildInfoCard(
            title: 'Informasi Operasional',
            children: [
              _buildInfoRow(
                icon: Icons.access_time,
                title: 'Jam Operasional',
                value: facility.openingHours,
              ),

              _buildInfoRow(
                icon: Icons.phone_outlined,
                title: 'Nomor Telepon',
                value: facility.phone ?? '',
              ),
            ],
          ),

          // Layanan kesehatan.
          _buildInfoCard(
            title: 'Layanan Kesehatan',
            children: [_buildServiceList()],
          ),

          // Tombol tindakan.
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      facility.phone != null &&
                          facility.phone!.trim().isNotEmpty
                      ? () => _callFacility(context)
                      : null,
                  icon: const Icon(Icons.phone),
                  label: const Text('Telepon'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: FilledButton.icon(
                  onPressed: facility.hasCoordinates
                      ? () => _openDirections(context)
                      : null,
                  icon: const Icon(Icons.directions),
                  label: const Text('Petunjuk Arah'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),
        ],
      ),
    );
  }
}
