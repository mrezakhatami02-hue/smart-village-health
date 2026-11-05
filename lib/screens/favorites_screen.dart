import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/health_facility.dart';
import '../services/favorite_service.dart';
import 'facility_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final List<HealthFacility> facilities;
  final Position? currentPosition;

  const FavoritesScreen({
    super.key,
    required this.facilities,
    this.currentPosition,
  });

  IconData _getIcon(FacilityType type) {
    switch (type) {
      case FacilityType.hospital:
        return Icons.local_hospital;

      case FacilityType.puskesmas:
        return Icons.health_and_safety;

      case FacilityType.clinic:
        return Icons.medical_services;
    }
  }

  Color _getColor(FacilityType type) {
    switch (type) {
      case FacilityType.hospital:
        return Colors.red;

      case FacilityType.puskesmas:
        return Colors.green;

      case FacilityType.clinic:
        return Colors.orange;
    }
  }

  Future<void> _removeFavorite(
      BuildContext context,
      HealthFacility facility,
      ) async {
    try {
      await FavoriteService.instance.remove(facility.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${facility.name} dihapus dari Favorit.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menghapus fasilitas dari Favorit.'),
        ),
      );
    }
  }

  void _openDetail(
      BuildContext context,
      HealthFacility facility,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => FacilityDetailScreen(
          facility: facility,
          currentPosition: currentPosition,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoriteService = FavoriteService.instance;

    return AnimatedBuilder(
      animation: favoriteService,
      builder: (context, child) {
        if (!favoriteService.isInitialized) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final favoriteFacilities = facilities
            .where(
              (facility) =>
              favoriteService.isFavorite(facility.id),
        )
            .toList();

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // HEADER
              const Text(
                'Fasilitas Favorit',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF123B64),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Daftar fasilitas kesehatan yang Anda simpan.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 20),

              // JUMLAH FAVORIT
              Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.favorite,
                      color: Color(0xFF1976D2),
                      size: 29,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${favoriteFacilities.length} fasilitas tersimpan',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF123B64),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // EMPTY STATE
              if (favoriteFacilities.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 45,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 60,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Belum Ada Favorit',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF123B64),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'Tambahkan fasilitas kesehatan '
                            'ke daftar favorit agar lebih mudah ditemukan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.6,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )

              // FAVORITE LIST
              else
                ...favoriteFacilities.map((facility) {
                  final color = _getColor(facility.type);

                  return Card(
                    color: Colors.white,
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),

                      onTap: () {
                        _openDetail(context, facility);
                      },

                      leading: CircleAvatar(
                        backgroundColor: color.withValues(
                          alpha: 0.12,
                        ),
                        child: Icon(
                          _getIcon(facility.type),
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

                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          '${facility.type.label}\n'
                              '${facility.kelurahan}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                      ),

                      trailing: IconButton(
                        tooltip: 'Hapus dari Favorit',
                        onPressed: () {
                          _removeFavorite(context, facility);
                        },
                        icon: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
